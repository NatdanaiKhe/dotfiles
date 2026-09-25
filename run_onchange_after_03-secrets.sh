#!/usr/bin/env bash
set -euo pipefail

# Ensure ~/.config/fish/conf.d exists
mkdir -p "$HOME/.config/fish/conf.d"

SECRETS_FISH="$HOME/.config/fish/conf.d/secrets.fish"

if [ ! -f "$SECRETS_FISH" ]; then
  echo "==> Setting up secrets.fish..."
  if command -v infisical >/dev/null 2>&1 && [ -f "$HOME/.infisical/infisical-config.json" ]; then
    echo "--> Infisical detected. Exporting secrets to $SECRETS_FISH..."
    {
      echo "# Auto-generated from Infisical on $(date)"
      echo "# Permissions: 600"
      infisical export --format=dotenv --silent 2>/dev/null | while IFS= read -r line || [ -n "$line" ]; do
        [ -z "$line" ] && continue
        [[ "$line" =~ ^# ]] && continue
        key="${line%%=*}"
        val="${line#*=}"
        # escape single quotes for fish
        safe_val=$(printf '%s' "$val" | sed "s/'/'\\\\''/g")
        echo "set -gx $key '$safe_val'"
      done
    } > "$SECRETS_FISH"
    chmod 600 "$SECRETS_FISH"
    echo "--> Secrets successfully exported to $SECRETS_FISH."
  else
    echo "--> [Notice] Infisical not authenticated yet."
    echo "--> Run 'infisical login' on this machine, then rerun 'chezmoi apply' to export secrets to Fish."
    touch "$SECRETS_FISH"
    chmod 600 "$SECRETS_FISH"
  fi
fi
