#!/usr/bin/env python3
"""papis fetch — pick an entry, discover candidate PDFs across sources, pick one, attach it.

Run interactively:      papis exec ~/.config/papis/scripts/papis-fetch.py
Non-interactive test:    FETCH_REF=Egenhofer1991 FETCH_LIST=1 papis exec .../papis-fetch.py
                         FETCH_REF=Egenhofer1991 FETCH_INDEX=0 papis exec .../papis-fetch.py  (auto-pick + attach)

Discovery tiers (free first, paid last):
  arXiv eprint -> Unpaywall / OpenAlex / Semantic Scholar (by DOI) -> Kagi web search (filetype:pdf)
Every candidate is pre-verified by range-fetching its first bytes and checking for %PDF.
"""
import concurrent.futures as cf
import colorama
import json, os, shutil, subprocess, sys, tempfile, threading, time, urllib.parse, urllib.request
from urllib.error import HTTPError, URLError

EMAIL = "redacted@example.invalid"
UA = "Mozilla/5.0 (X11; Linux aarch64) AppleWebKit/537.36 papis-fetch/1.0"
KAGI_LENS = os.environ.get("FETCH_LENS")  # e.g. "academic"; default None = plain search

import papis.api, papis.database, papis.commands.addto


# ---------- helpers ----------
def _get_json(url, headers=None, data=None, method="GET", timeout=40):
    req = urllib.request.Request(url, data=data, method=method,
                                 headers={"User-Agent": UA, **(headers or {})})
    return json.load(urllib.request.urlopen(req, timeout=timeout))


def kagi_token():
    return subprocess.run(["pass", "show", "api/kagi/token"],
                          capture_output=True, text=True, check=True).stdout.strip()


# ---------- discovery ----------
def from_arxiv(doc):
    if (doc.get("eprinttype") or "").lower() == "arxiv" and doc.get("eprint"):
        eid = doc["eprint"].split("v")[0]
        return [("arxiv", f"https://arxiv.org/pdf/{eid}.pdf", "arXiv:" + eid)]
    return []


def from_unpaywall(doi):
    m = _get_json(f"https://api.unpaywall.org/v2/{doi}?email={EMAIL}")
    return [("unpaywall", l["url_for_pdf"], "") for l in m.get("oa_locations", []) if l.get("url_for_pdf")]


def from_openalex(doi):
    m = _get_json(f"https://api.openalex.org/works/doi:{doi}?mailto={EMAIL}")
    urls = [m.get("open_access", {}).get("oa_url")]
    urls += [loc.get("pdf_url") for loc in m.get("locations", [])]
    return [("openalex", u, "") for u in urls if u]


def from_s2(doi):
    m = _get_json(f"https://api.semanticscholar.org/graph/v1/paper/DOI:{doi}?fields=openAccessPdf")
    oa = m.get("openAccessPdf")
    return [("s2", oa["url"], "")] if oa and oa.get("url") else []


def from_kagi(doc):
    title = doc.get("title", "")
    fam = ""
    if doc.get("author_list"):
        fam = doc["author_list"][0].get("family", "")
    query = f'"{title}" {fam} filetype:pdf'.strip()
    payload = json.dumps({"query": query}).encode()
    headers = {"Authorization": "Bearer " + kagi_token(), "Content-Type": "application/json"}
    if KAGI_LENS:
        payload = json.dumps({"query": query, "lens_id": KAGI_LENS}).encode()
    m = _get_json("https://kagi.com/api/v1/search", headers=headers, data=payload, method="POST", timeout=60)
    out = []
    for it in m.get("data", {}).get("search", []):
        if isinstance(it, dict) and it.get("url"):
            out.append(("kagi", it["url"], it.get("title", "")))
    return out


def gather(doc):
    cands, seen = [], set()
    tiers = list(from_arxiv(doc))
    doi = doc.get("doi")
    if doi:
        for fn in (from_unpaywall, from_openalex, from_s2):
            try:
                tiers += fn(doi)
            except Exception:
                pass
    try:
        tiers += from_kagi(doc)
    except Exception as e:
        print(f"  (kagi search failed: {e})", file=sys.stderr)
    for src, url, title in tiers:
        key = url.split("?")[0]
        if key not in seen:
            seen.add(key)
            cands.append({"source": src, "url": url, "title": " ".join((title or "").split())})
    return cands


# ---------- verification ----------
def verify(url):
    """Return (ok, status, size). Range-fetch first 2KB, check for %PDF magic.
    status is the check result (✓ PDF / ✗ html / ✗ http403 / …); size is the
    file size for real PDFs only (blank otherwise, so it gets its own column)."""
    try:
        req = urllib.request.Request(url, headers={"User-Agent": UA, "Range": "bytes=0-2047"})
        with urllib.request.urlopen(req, timeout=8) as r:
            head = r.read(2048)
            ctype = r.headers.get("Content-Type", "")
            cr = r.headers.get("Content-Range", "")   # "bytes 0-2047/115575"
            total = cr.rsplit("/", 1)[-1] if "/" in cr else r.headers.get("Content-Length", "")
        if head[:4] == b"%PDF":
            size = f"{int(total)//1024}KB" if str(total).isdigit() else "?"
            return True, "✓ PDF", size
        if b"<html" in head.lower() or "html" in ctype:
            return False, "✗ html", ""
        return False, "✗ " + (ctype.split(";")[0].split("/")[-1] or "?")[:7], ""
    except HTTPError as e:
        return False, f"✗ http{e.code}", ""
    except (URLError, Exception):
        return False, "✗ timeout", ""


def verify_all(cands):
    with cf.ThreadPoolExecutor(max_workers=8) as ex:
        results = list(ex.map(lambda c: verify(c["url"]), cands))
    for c, (ok, status, size) in zip(cands, results):
        c["ok"], c["status"], c["size"] = ok, status, size
    cands.sort(key=lambda c: (not c["ok"], c["source"] != "kagi"))
    return cands


# ---------- selection + attach ----------
def host(url):
    return urllib.parse.urlparse(url).netloc.replace("www.", "")


# Space-padded fixed-width columns so alignment never depends on fzf tab stops.
# status | host | title (fixed, ellipsized) | size (right-aligned, last)
STATUS_W, HOST_W, TITLE_W, SIZE_W = 9, 24, 60, 7


def _display(c):
    # Pad each field to its fixed width FIRST, then wrap in ANSI — the color codes
    # are zero-width, so the columns stay aligned. All colors are palette indices
    # (theme-aware), matching the picker's author column.
    status = f"{c['status'][:STATUS_W]:<{STATUS_W}}"
    hostc = f"{host(c['url'])[:HOST_W]:<{HOST_W}}"
    t = c["title"] or ""
    t = (t[:TITLE_W - 1] + "…") if len(t) > TITLE_W else t
    title = f"{t:<{TITLE_W}}"
    size = f"{c['size']:>{SIZE_W}}"

    G = colorama.Fore.GREEN
    GREY = colorama.Fore.LIGHTBLACK_EX
    DIM = colorama.Style.DIM
    X = colorama.Style.RESET_ALL

    if not c.get("ok"):                       # unusable (non-PDF): whole row grey
        return GREY + f"{status}  {hostc}  {title}  {size}" + X
    return (f"{G}{status}{X}  "               # ✓ status → green
            f"{G}{hostc}{X}  "                # host    → green
            f"{title}  "                      # title   → default (fixed width)
            f"{DIM}{size}{X}")                # size    → dim, last column


def fzf_pick(cands):
    # URL is a hidden trailing tab-field (not displayed), parsed back out on select.
    lines = [f"{_display(c)}\t{c['url']}" for c in cands]
    p = subprocess.run(
        ["fzf", "--ansi", "--delimiter", "\t", "--with-nth", "1", "--nth", "1",
         "--header", "select a PDF to attach (verified first)",
         "--prompt", "pdf> "],
        input="\n".join(lines), capture_output=True, text=True)
    if p.returncode != 0 or not p.stdout.strip():
        return None
    return p.stdout.strip().split("\t")[-1]


def download(url, dest):
    req = urllib.request.Request(url, headers={"User-Agent": UA})
    with urllib.request.urlopen(req, timeout=60) as r:
        data = r.read()
    if data[:4] != b"%PDF":
        raise ValueError("not a PDF (got HTML/other)")
    with open(dest, "wb") as f:
        f.write(data)
    return len(data)


def attach(doc, url):
    ref = doc.get("ref", "document")
    tmp = os.path.join(tempfile.mkdtemp(), ref + ".pdf")
    size = download(url, tmp)
    papis.commands.addto.run(doc, [tmp], file_name=ref)
    print(f"attached {size//1024}KB -> {ref}  (from {host(url)})")


# ---------- progress UI ----------
def _with_spinner(work, label="Researching..."):
    """Run work() while showing a centered rounded card + braille spinner on a
    full-screen alternate buffer. No-op (just runs work) when stdout isn't a TTY."""
    if not sys.stdout.isatty():
        return work()

    result, error = {}, {}

    def runner():
        try:
            result["v"] = work()
        except BaseException as e:   # noqa: BLE001 - re-raised after cleanup
            error["v"] = e

    frames = "⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"
    # ANSI palette green (same call as the fzf picker's author column) — a palette
    # INDEX, so it re-themes with the terminal; NOT a fixed RGB.
    G, X = colorama.Fore.GREEN, colorama.Style.RESET_ALL
    cols, rows = shutil.get_terminal_size((80, 24))
    inner_w = len(label) + 6
    box_w = inner_w + 2
    r0 = max(1, rows // 2 - 2)          # 1-based top row of the 5-line card
    c0 = max(1, cols // 2 - box_w // 2)
    horiz = "─" * inner_w
    side = G + "│" + X                  # green border, default-color interior

    def at(r, c, s):
        sys.stdout.write(f"\x1b[{r};{c}H{s}")

    sys.stdout.write("\x1b[?1049h\x1b[?25l\x1b[2J")   # alt screen, hide cursor, clear
    at(r0,     c0, G + "╭" + horiz + "╮" + X)
    at(r0 + 1, c0, side + " " * inner_w + side)
    at(r0 + 3, c0, side + " " * inner_w + side)
    at(r0 + 4, c0, G + "╰" + horiz + "╯" + X)
    sys.stdout.flush()

    t = threading.Thread(target=runner)
    t.start()
    i = 0
    try:
        while t.is_alive():
            content = f"{frames[i % len(frames)]} {label}".center(inner_w)
            at(r0 + 2, c0, side + content + side)
            sys.stdout.flush()
            i += 1
            time.sleep(0.08)
        t.join()
    finally:
        sys.stdout.write("\x1b[?25h\x1b[?1049l")      # show cursor, leave alt screen
        sys.stdout.flush()

    if "v" in error:
        raise error["v"]
    return result.get("v")


# ---------- main ----------
def pick_document():
    db = papis.database.get()
    docs = db.get_all_documents()
    ref = os.environ.get("FETCH_REF")
    if ref:
        for d in docs:
            if d.get("ref") == ref:
                return d
        sys.exit(f"no document with ref={ref}")
    picked = papis.api.pick_doc(docs)
    return picked[0] if picked else None


def main():
    doc = pick_document()
    if not doc:
        sys.exit("no document selected")
    cands = _with_spinner(lambda: verify_all(gather(doc)))
    if not cands:
        sys.exit("no candidate URLs found (would fall back to browser-watch here)")

    if os.environ.get("FETCH_LIST"):
        for i, c in enumerate(cands):
            print(f"{i:>2}  {_display(c)}")
        return

    idx = os.environ.get("FETCH_INDEX")
    url = cands[int(idx)]["url"] if idx is not None else fzf_pick(cands)
    if not url:
        sys.exit("nothing picked")
    attach(doc, url)


main()
