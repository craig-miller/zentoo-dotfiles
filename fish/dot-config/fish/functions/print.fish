function print --description "Pick a CUPS queue with fzf, then lp the file"
    set -l file $argv[1]
    if test -z "$file"; or not test -e "$file"
        echo "usage: print <file>" >&2
        return 1
    end

    set -l default (lpstat -d 2>/dev/null \
        | string match -rg 'destination: (\S+)')

    set -l rows
    for q in (lpstat -p | string match -rg '^printer (\S+) ')
        set -l loc (lpoptions -p $q 2>/dev/null \
            | string match -rg "printer-location='([^']*)'")
        set -l mm (lpoptions -p $q 2>/dev/null \
            | string match -rg "printer-make-and-model='([^']*)'" \
            | string replace -r ' - IPP Everywhere$' '')
        test -z "$loc"; and set loc '—'
        test -z "$mm"; and set mm '—'
        set -a rows (printf '%-30s  %-25s  %s' $loc $mm $q)
    end

    set -l pick (printf '%s\n' $rows \
        | fzf --prompt 'Printer ▸ ' \
              --header "default: $default" \
              --query "$default" \
              --exit-0)
    test -z "$pick"; and return 1
    set -l printer (string match -rg '(\S+)$' -- $pick)

    set -l duplex_opts (lpoptions -p $printer -l \
        | string match -r '^Duplex/.*' \
        | string replace -r '^Duplex/[^:]*:\s*' '' \
        | string split ' ' \
        | string replace -r '^\*' '')

    set -l current_duplex (lpoptions -p $printer 2>/dev/null \
        | string match -rg "Duplex=(\S+)")

    set -l duplex_rows
    for opt in $duplex_opts
        set -l label
        switch $opt
            case None
                set label None
            case DuplexNoTumble
                set label 'Double Sided'
            case DuplexTumble
                set label 'Double Sided (Short Edge)'
            case '*'
                set label $opt
        end
        set -a duplex_rows (printf '%-30s  %s' $label $opt)
    end

    set -l duplex_pick (printf '%s\n' $duplex_rows \
        | fzf --prompt 'Duplex ▸ ' \
              --query "$current_duplex" \
              --exit-0)
    test -z "$duplex_pick"; and return 1
    set -l duplex (string match -rg '(\S+)$' -- $duplex_pick)

    set -l orient_rows \
        (printf '%-30s  %s' Portrait Portrait) \
        (printf '%-30s  %s' Landscape Landscape)

    set -l orient_pick (printf '%s\n' $orient_rows \
        | fzf --prompt 'Orientation ▸ ' --exit-0)
    test -z "$orient_pick"; and return 1
    set -l orient (string match -rg '(\S+)$' -- $orient_pick)

    read -lP 'Copies [1] ▸ ' copies
    or return 1
    test -z "$copies"; and set copies 1

    set -l args -d "$printer" -n "$copies" -o "Duplex=$duplex"
    switch $orient
        case Portrait
            set -a args -o orientation-requested=3
        case Landscape
            set -a args -o landscape
    end
    lp $args -- "$file"
end
