# Natdanai's Dotfiles

Cross-platform development environment and Fedora workstation setup managed via [chezmoi](https://www.chezmoi.io/).

---

## ⚡ Quick Start (New Machine Bootstrap)

On any fresh Linux machine (Fedora, Debian, Ubuntu, Arch, or cloud/WSL):

```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply NatdanaiKhe
```

Chezmoi will:
1. Prompt whether the machine is **headless** (`true` for server/VM, `false` for full desktop workstation).
2. Install base CLI packages, development tools, and shell utilities.
3. Set **Fish** as default shell and configure Ghostty and Zed.
4. *(If Desktop)* Install Flatpaks, restore curated GNOME shortcuts/extensions via `dconf`, and install WhiteSur theme and Apple fonts.

---

## 🔐 Secret Management

Zero secrets or API keys are stored in Git.
1. Secrets are managed in self-hosted **Infisical** (`secrets.natdanai.dev`).
2. After bootstrapping a new machine, run:
   ```sh
   infisical login
   chezmoi apply
   ```
   This automatically generates `~/.config/fish/conf.d/secrets.fish` (with `chmod 600`) so all terminal sessions load tokens with zero shell latency.
3. Import your SSH keys (`~/.ssh/`) from your encrypted password manager or offline key backup.

See [SECRETS.md](SECRETS.md) for the complete list of secret keys to add to Infisical and the Cloudflare Access bootstrap requirements.


---

## 📦 What's Managed

| Layer | Tools Included |
| :--- | :--- |
| **Shell & CLI** | Fish, Starship/Fisher plugins, Zoxide, Fzf, Ripgrep, fd, eza, bat, btop, Lazygit |
| **Containers & Runtimes** | Podman, Podman Compose, Bun, uv, asdf |
| **Terminals & Editors** | Ghostty, Zed, VS Code settings |
| **GUI & Flatpaks** | Obsidian, Spotify, Beekeeper Studio, Podman Desktop, Gear Lever, Dev Toolbox, GitFourchette |
| **Desktop Environment** | GNOME Shell extensions, curated `dconf` keybindings (`<Super>space`, `<Alt>Shift`), WhiteSur GTK theme, Apple/Sukhumvit fonts |
| **Hardware** | ThinkPad P14s Gen 3 boot/power optimizations under `hardware/thinkpad-p14s/` |

---

## 🛠️ Day-to-Day Maintenance

```sh
# View pending diffs between your live machine and chezmoi
chezmoi diff

# Pull latest changes and apply
chezmoi update

# Edit a managed file
chezmoi edit ~/.config/fish/config.fish

# Commit and push changes
chezmoi git add .
chezmoi git commit -m "feat: update fish aliases"
chezmoi git push
```
