for cmd in \
git gh docker asdf \
node npm python python3 pip pip3 go \
bun uv zed \
zsh rg fd fzf jq curl wget unzip zip \
gcc g++ make cmake ninja \
bat eza zoxide delta tmux nvim lazygit \
btop htop ncdu just direnv shellcheck shfmt \
lsof dig nc tcpdump
do
    printf "%-12s" "$cmd"
    if command -v "$cmd" >/dev/null 2>&1; then
        echo "✓ $(command -v "$cmd")"
    else
        echo "✗"
    fi
done

for cmd in git gh docker asdf bun uv zed node npm python3 go rg fd jq zsh; do
    echo "=== $cmd ==="
    if command -v "$cmd" >/dev/null 2>&1; then
        "$cmd" --version 2>/dev/null || "$cmd" version 2>/dev/null || true
    else
        echo "Not installed"
    fi
    echo
done
