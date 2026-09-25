if status is-interactive
# Commands to run in interactive sessions can go here
end

# Better cd
zoxide init fish | source

# fzf integration
fzf --fish | source

# Aliases
alias ls="eza --icons"
alias ll="eza -lah --icons"
alias la="eza -a --icons"
alias tree="eza --tree"

alias cat="bat"
alias grep="rg"
alias top="btop"

alias lg="lazygit"
# docker 
alias docker="podman"
set -x DOCKER_HOST unix:///run/user/1000/podman/podman.sock
# uv
fish_add_path ~/bin
fish_add_path ~/cmd

# Secrets are loaded automatically from ~/.config/fish/conf.d/secrets.fish
# or injected via Infisical (secrets.natdanai.dev)

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH

# strix
fish_add_path /home/natdanai/.strix/bin


# Added by Antigravity CLI installer
set -gx PATH "/home/natdanai/.local/bin" $PATH
