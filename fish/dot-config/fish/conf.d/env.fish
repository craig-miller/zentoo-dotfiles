# Default editor — nvim everywhere
set -gx EDITOR nvim
set -gx VISUAL nvim

# ripgrep — also feeds fzf as a file source
# (respects .gitignore, hidden files explicit, .git itself excluded).
set -gx FZF_DEFAULT_COMMAND "rg --files --hidden --strip-cwd-prefix --glob '!.git'"
set -gx FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"

# bat — ANSI theme follows the terminal palette (foot pulls noctalia's M3
# colors via include), so bat retints with the wallpaper.
set -gx BAT_THEME ansi
set -gx MANPAGER "sh -c 'col -bx | bat -l man -p'"

# gpg-agent — unified SSH+GPG agent (see ~/.gnupg/gpg-agent.conf)
set -gx SSH_AUTH_SOCK (gpgconf --list-dirs agent-ssh-socket)
