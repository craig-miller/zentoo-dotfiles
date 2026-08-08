# papis python config — auto-maintain the shared Typst bibliography.
#
# Regenerates ~/research/bib.yml (Hayagriva format, referenced from Typst notes as
# `#bibliography("/bib.yml")`) whenever the library changes through papis's add/edit paths:
#   * `papis add`  -> fires on_add_done   (bib's add also calls add.run, so it fires too)
#   * `papis edit` -> fires on_edit_done
# NOTE: bib's in-app edit/delete and `papis rm` bypass papis hooks, so a periodic re-export
# is the catch-all for those (see the personal crontab / manual
#   papis export --all --format typst --out ~/research/bib.yml
import os

_BIB_OUT = os.path.expanduser("~/research/bib.yml")


def _regen_shared_bib(*_args, **_kwargs):
    """Export the whole library to the shared Hayagriva bib. Best-effort: never raises, so a
    failure here can't break the add/edit that triggered it."""
    try:
        import papis.database
        from papis.commands.export import run as export_run
        docs = papis.database.get().get_all_documents()
        text = export_run(docs, "typst")
        with open(_BIB_OUT, "w", encoding="utf-8") as fd:
            fd.write(text)
    except Exception:
        pass


import papis.hooks

papis.hooks.add("on_add_done", _regen_shared_bib)
papis.hooks.add("on_edit_done", _regen_shared_bib)
