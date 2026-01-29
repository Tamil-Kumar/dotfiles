# config.nu
#
# Installed by:
# version = "0.102.0"
#
# This file is used to override default Nushell settings, define
# (or import) custom commands, or run any other startup tasks.
# See https://www.nushell.sh/book/configuration.html
#
# This file is loaded after env.nu and before login.nu
#
# You can open this file in your default editor using:
# config nu
#
# See `help config nu` for more options
#
# You can remove these comments if you want or leave
# them for future reference.

## ~/.config/nushell/env.nu
$env.CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense' # optional
mkdir ~/.cache/carapace
carapace _carapace nushell | save --force ~/.cache/carapace/init.nu

#~/.config/nushell/config.nu
source ~/.cache/carapace/init.nu

$env.config.buffer_editor = "hx"
$env.config.show_banner = false
$env.PROMPT_MULTILINE_INDICATOR = "> "
$env.PROMPT_COMMAND_RIGHT = { starship prompt --right --status $env.LAST_EXIT_CODE | str trim }
$env.config.table.mode = 'rounded'
def create_left_prompt [] {
    $env.PWD
}
$env.PROMPT_COMMAND = { create_left_prompt }

# Aliases
alias "type" = describe
alias "pwsh" = ^pwsh -command
alias "code" = code-insiders
alias "y" = yazi
alias "ll" = eza --header -l --color=always --icons=always -T -L 1 --time-style='+%m-%d-%Y %I:%M %p' -m -a --hyperlink
alias "bat" = bat --theme 'Catppuccin Mocha' --color=always -P
alias "ff" = fastfetch -l C:\Users\tamil\.config\fastfetch\ascii.txt
alias "hi" = fzf --preview "bat --color=always --style=numbers --line-range=:500 {}" --list-border=rounded --input-border=rounded --preview-border=rounded --header-border=rounded --footer-border=rounded --wrap --no-scrollbar --preview-window=wrap
alias "lg" = lazygit
source ~/.zoxide.nu

def --env y [...args] {
	let tmp = (mktemp -t "yazi-cwd.XXXXXX")
	yazi ...$args --cwd-file $tmp
	let cwd = (open $tmp)
	if $cwd != "" and $cwd != $env.PWD {
		cd $cwd
	}
	rm -fp $tmp
}

def fzf [] {
    let files = (ls | where type == file | get name | to text | str trim)
    if $files == [] { return }
    let selection = (echo $files | hi | str trim)
    if $selection != "" {
        hx $selection
    }
}

def fzfc [] {
    let files = (ls | where type in ["file", "dir"] | get name | to text | str trim)
    if $files == [] { return }
    let selection = (echo $files | hi | str trim)
    if $selection != "" {
        code $selection
    }
}

mkdir ($nu.data-dir | path join "vendor/autoload")
starship init nu | save -f ($nu.data-dir | path join "vendor/autoload/starship.nu")

cd ~
ff
