# Workstation Secrets Specification for Infisical

This document specifies the exact environment variables and secrets that should be stored in your self-hosted Infisical instance (`https://secrets.natdanai.dev`) under a dedicated project (recommended name: `workstation` or `dotfiles`).

---

## 📋 Secrets to Add in Infisical

Create a project in Infisical (e.g. `workstation`) with environment `dev` or `prod`, and add the following keys:

| Secret Key | Description | Example / Current Pattern |
| :--- | :--- | :--- |
| `OPENCODE_API_KEY` | OpenCode API token for model routing | `sk-Wicn...` |
| `OPENROUTER_API_KEY` | OpenRouter API token for LLMs | `sk-or-v1-...` |
| `DEEPSEEK_API_KEY` | DeepSeek API key | `sk-c022...` |
| `AWS_ACCESS_KEY_ID` | AWS IAM programmatic access key ID | `AKIA4KYDP...` |
| `AWS_SECRET_ACCESS_KEY` | AWS IAM secret access key | `3w5bNq...` |
| `GH_PAT` | GitHub Personal Access Token | `ghp_9Xh...` |
| `DOCKER_PAT` | Docker Hub Personal Access Token | `dckr_pat_...` |

*(Optional / If Used in the future)*:
| `ANTHROPIC_API_KEY` | Anthropic Claude API key | `sk-ant-...` |
| `OPENAI_API_KEY` | OpenAI API key | `sk-proj-...` |
| `GEMINI_API_KEY` | Google Gemini API key | `AIzaSy...` |

---

## 🔑 Bootstrap Pre-requisites (Keep in Bitwarden / 1Password)

The following items **cannot** be stored in Infisical because they are required to authenticate and connect *to* Infisical and Git in the first place:

### 1. Cloudflare Access Service Token
Your Infisical instance (`https://secrets.natdanai.dev`) sits behind Cloudflare Zero Trust. To allow the CLI to communicate with it, keep these in your password manager:
- `CF_ACCESS_CLIENT_ID`
- `CF_ACCESS_CLIENT_SECRET`

On a new machine, export them before logging into Infisical:
```sh
set -x INFISICAL_DOMAIN https://secrets.natdanai.dev
set -x CF_ACCESS_CLIENT_ID <your-id>
set -x CF_ACCESS_CLIENT_SECRET <your-secret>
set -x INFISICAL_CUSTOM_HEADERS "CF-Access-Client-Id=$CF_ACCESS_CLIENT_ID CF-Access-Client-Secret=$CF_ACCESS_CLIENT_SECRET"
```

### 2. SSH Private Keys
Store your `~/.ssh/` private keys in your password manager or encrypted offline archive:
- `github`
- `deploy_homelab`
- `home`
- `google_compute_engine`
- `ssh-oci-key.key`

---

## 🚀 CLI Bulk Import Helper

### 1. Import Environment Secrets
```fish
# Bulk import API keys from ~/.config/fish/conf.d/secrets.fish
grep '^set -x' ~/.config/fish/conf.d/secrets.fish | grep -v 'CF_' | grep -v 'INFISICAL_' | while read -r _ _ key val
    infisical secrets set "$key=$val" --env=dev
end
```

### 2. Import SSH Private Keys
Infisical supports file paths directly via the `@/path/to/file` syntax:

```fish
# Upload all 5 SSH private keys
for key in deploy_homelab github google_compute_engine home ssh-oci-key.key
    set var_name (string upper "SSH_KEY_"(string replace -a '-' '_' (string replace -a '.' '_' $key)))
    echo "Uploading $key as $var_name..."
    infisical secrets set "$var_name=@$HOME/.ssh/$key" --env=dev
end
```

### 3. Restore SSH Keys on a New Machine
```fish
mkdir -p ~/.ssh; and chmod 700 ~/.ssh
for key in deploy_homelab github google_compute_engine home ssh-oci-key.key
    set var_name (string upper "SSH_KEY_"(string replace -a '-' '_' (string replace -a '.' '_' $key)))
    echo "Restoring $key..."
    infisical secrets get $var_name --plain > ~/.ssh/$key
end
chmod 600 ~/.ssh/*
```

