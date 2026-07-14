#!/usr/bin/env bash
# fzf preview for papis picker.
# Args: $1=year $2=title $3=author $4=abstract (from fzf's --delimiter '|' fields)
# fzf shell-quotes each field; strip outer ' if present.
strip_q() { local s="${1#\'}"; echo "${s%\'}"; }
YEAR=$(strip_q "$1")
TITLE=$(strip_q "$2")
AUTHOR=$(strip_q "$3")
ABSTRACT=$(strip_q "$4")

COLS=${FZF_PREVIEW_COLUMNS:-80}
printf '\033[33m%s\033[0m \033[34m%s\033[0m\n\n\033[32m%s\033[0m\n\n%s\n' \
    "$YEAR" \
    "$(echo "$TITLE" | fold -s -w "$COLS")" \
    "$(echo "$AUTHOR" | fold -s -w "$COLS")" \
    "$(echo "$ABSTRACT" | fold -s -w "$COLS")"
