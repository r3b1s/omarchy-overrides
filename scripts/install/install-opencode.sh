#!/bin/bash

USER_HOME=$(eval echo "~${SUDO_USER:-$USER}")
CONFIG_DIR="$USER_HOME/.config/opencode"
SPINNER="pulse"

# 1. Install opencode and bun
echo "Installing opencode and bun..."
gum spin --spinner "$SPINNER" --title "Installing opencode and bun..." -- \
  yay -S --needed --noconfirm opencode bun-bin

# 2. Clone and install Context Analysis Plugin
echo "Installing Context Analysis Plugin..."
gum spin --spinner "$SPINNER" --title "Installing Context Analysis Plugin..." -- bash -c "
  rm -rf /tmp/Opencode-Context-Analysis-Plugin
  git clone https://github.com/IgorWarzocha/Opencode-Context-Analysis-Plugin /tmp/Opencode-Context-Analysis-Plugin
  mkdir -p $CONFIG_DIR
  cp -r /tmp/Opencode-Context-Analysis-Plugin/.opencode/* $CONFIG_DIR/
  rm -rf /tmp/Opencode-Context-Analysis-Plugin
"

# 3. Clone and install OpenRTK plugin
echo "Installing OpenRTK plugin..."
gum spin --spinner "$SPINNER" --title "Installing OpenRTK plugin..." -- bash -c "
  rm -rf /tmp/openrtk
  git clone https://github.com/martinstannard/openrtk /tmp/openrtk
  mkdir -p $CONFIG_DIR/plugins
  cp -r /tmp/openrtk/src/* $CONFIG_DIR/plugins/
  rm -rf /tmp/openrtk
"

# 4. Install opencode-openai-codex-auth (backs up existing config, clears plugin cache)
echo "Installing opencode-openai-codex-auth..."
gum spin --spinner "$SPINNER" --title "Installing opencode-openai-codex-auth..." -- \
  bunx opencode-openai-codex-auth@latest

# 4. Create/merge opencode.jsonc with plugins and provider models
OPENCODE_JSONC="$CONFIG_DIR/opencode.jsonc"

BASE_CONFIG=$(cat <<'JSONEOF'
{
  "$schema": "https://opencode.ai/config.json",
  "plugin": [
    "@bastiangx/opencode-unmoji",
    "@tarquinen/opencode-dcp@latest",
    "@pantheon-ai/opencode-warcraft-notifications",
    "opencode-antigravity-auth@latest",
    "opencode-openai-codex-auth"
  ],
  "provider": {
    "google": {
      "models": {
        "antigravity-gemini-3-pro": {
          "name": "Gemini 3 Pro (Antigravity)",
          "limit": { "context": 1048576, "output": 65535 },
          "modalities": { "input": ["text", "image", "pdf"], "output": ["text"] },
          "variants": {
            "low": { "thinkingLevel": "low" },
            "high": { "thinkingLevel": "high" }
          }
        },
        "antigravity-gemini-3.1-pro": {
          "name": "Gemini 3.1 Pro (Antigravity)",
          "limit": { "context": 1048576, "output": 65535 },
          "modalities": { "input": ["text", "image", "pdf"], "output": ["text"] },
          "variants": {
            "low": { "thinkingLevel": "low" },
            "high": { "thinkingLevel": "high" }
          }
        },
        "antigravity-gemini-3-flash": {
          "name": "Gemini 3 Flash (Antigravity)",
          "limit": { "context": 1048576, "output": 65536 },
          "modalities": { "input": ["text", "image", "pdf"], "output": ["text"] },
          "variants": {
            "minimal": { "thinkingLevel": "minimal" },
            "low": { "thinkingLevel": "low" },
            "medium": { "thinkingLevel": "medium" },
            "high": { "thinkingLevel": "high" }
          }
        },
        "antigravity-claude-sonnet-4-6": {
          "name": "Claude Sonnet 4.6 (Antigravity)",
          "limit": { "context": 200000, "output": 64000 },
          "modalities": { "input": ["text", "image", "pdf"], "output": ["text"] }
        },
        "antigravity-claude-opus-4-6-thinking": {
          "name": "Claude Opus 4.6 Thinking (Antigravity)",
          "limit": { "context": 200000, "output": 64000 },
          "modalities": { "input": ["text", "image", "pdf"], "output": ["text"] },
          "variants": {
            "low": { "thinkingConfig": { "thinkingBudget": 8192 } },
            "max": { "thinkingConfig": { "thinkingBudget": 32768 } }
          }
        },
        "gemini-2.5-flash": {
          "name": "Gemini 2.5 Flash (Gemini CLI)",
          "limit": { "context": 1048576, "output": 65536 },
          "modalities": { "input": ["text", "image", "pdf"], "output": ["text"] }
        },
        "gemini-2.5-pro": {
          "name": "Gemini 2.5 Pro (Gemini CLI)",
          "limit": { "context": 1048576, "output": 65536 },
          "modalities": { "input": ["text", "image", "pdf"], "output": ["text"] }
        },
        "gemini-3-flash-preview": {
          "name": "Gemini 3 Flash Preview (Gemini CLI)",
          "limit": { "context": 1048576, "output": 65536 },
          "modalities": { "input": ["text", "image", "pdf"], "output": ["text"] }
        },
        "gemini-3-pro-preview": {
          "name": "Gemini 3 Pro Preview (Gemini CLI)",
          "limit": { "context": 1048576, "output": 65535 },
          "modalities": { "input": ["text", "image", "pdf"], "output": ["text"] }
        },
        "gemini-3.1-pro-preview": {
          "name": "Gemini 3.1 Pro Preview (Gemini CLI)",
          "limit": { "context": 1048576, "output": 65535 },
          "modalities": { "input": ["text", "image", "pdf"], "output": ["text"] }
        },
        "gemini-3.1-pro-preview-customtools": {
          "name": "Gemini 3.1 Pro Preview Custom Tools (Gemini CLI)",
          "limit": { "context": 1048576, "output": 65535 },
          "modalities": { "input": ["text", "image", "pdf"], "output": ["text"] }
        }
      }
    },
    "openai": {
      "options": {
        "reasoningEffort": "medium",
        "reasoningSummary": "auto",
        "textVerbosity": "medium",
        "include": ["reasoning.encrypted_content"],
        "store": false
      },
      "models": {
        "gpt-5.2": {
          "name": "GPT 5.2 (OAuth)",
          "limit": { "context": 272000, "output": 128000 },
          "modalities": { "input": ["text", "image"], "output": ["text"] },
          "variants": {
            "none": { "reasoningEffort": "none", "reasoningSummary": "auto", "textVerbosity": "medium" },
            "low": { "reasoningEffort": "low", "reasoningSummary": "auto", "textVerbosity": "medium" },
            "medium": { "reasoningEffort": "medium", "reasoningSummary": "auto", "textVerbosity": "medium" },
            "high": { "reasoningEffort": "high", "reasoningSummary": "detailed", "textVerbosity": "medium" },
            "xhigh": { "reasoningEffort": "xhigh", "reasoningSummary": "detailed", "textVerbosity": "medium" }
          }
        },
        "gpt-5.2-codex": {
          "name": "GPT 5.2 Codex (OAuth)",
          "limit": { "context": 272000, "output": 128000 },
          "modalities": { "input": ["text", "image"], "output": ["text"] },
          "variants": {
            "low": { "reasoningEffort": "low", "reasoningSummary": "auto", "textVerbosity": "medium" },
            "medium": { "reasoningEffort": "medium", "reasoningSummary": "auto", "textVerbosity": "medium" },
            "high": { "reasoningEffort": "high", "reasoningSummary": "detailed", "textVerbosity": "medium" },
            "xhigh": { "reasoningEffort": "xhigh", "reasoningSummary": "detailed", "textVerbosity": "medium" }
          }
        },
        "gpt-5.1-codex-max": {
          "name": "GPT 5.1 Codex Max (OAuth)",
          "limit": { "context": 272000, "output": 128000 },
          "modalities": { "input": ["text", "image"], "output": ["text"] },
          "variants": {
            "low": { "reasoningEffort": "low", "reasoningSummary": "detailed", "textVerbosity": "medium" },
            "medium": { "reasoningEffort": "medium", "reasoningSummary": "detailed", "textVerbosity": "medium" },
            "high": { "reasoningEffort": "high", "reasoningSummary": "detailed", "textVerbosity": "medium" },
            "xhigh": { "reasoningEffort": "xhigh", "reasoningSummary": "detailed", "textVerbosity": "medium" }
          }
        },
        "gpt-5.1-codex": {
          "name": "GPT 5.1 Codex (OAuth)",
          "limit": { "context": 272000, "output": 128000 },
          "modalities": { "input": ["text", "image"], "output": ["text"] },
          "variants": {
            "low": { "reasoningEffort": "low", "reasoningSummary": "auto", "textVerbosity": "medium" },
            "medium": { "reasoningEffort": "medium", "reasoningSummary": "auto", "textVerbosity": "medium" },
            "high": { "reasoningEffort": "high", "reasoningSummary": "detailed", "textVerbosity": "medium" }
          }
        },
        "gpt-5.1-codex-mini": {
          "name": "GPT 5.1 Codex Mini (OAuth)",
          "limit": { "context": 272000, "output": 128000 },
          "modalities": { "input": ["text", "image"], "output": ["text"] },
          "variants": {
            "medium": { "reasoningEffort": "medium", "reasoningSummary": "auto", "textVerbosity": "medium" },
            "high": { "reasoningEffort": "high", "reasoningSummary": "detailed", "textVerbosity": "medium" }
          }
        },
        "gpt-5.1": {
          "name": "GPT 5.1 (OAuth)",
          "limit": { "context": 272000, "output": 128000 },
          "modalities": { "input": ["text", "image"], "output": ["text"] },
          "variants": {
            "none": { "reasoningEffort": "none", "reasoningSummary": "auto", "textVerbosity": "medium" },
            "low": { "reasoningEffort": "low", "reasoningSummary": "auto", "textVerbosity": "low" },
            "medium": { "reasoningEffort": "medium", "reasoningSummary": "auto", "textVerbosity": "medium" },
            "high": { "reasoningEffort": "high", "reasoningSummary": "detailed", "textVerbosity": "high" }
          }
        }
      }
    }
  }
}
JSONEOF
)

if [ -f "$OPENCODE_JSONC" ]; then
  echo "Backing up existing opencode.jsonc..."
  cp "$OPENCODE_JSONC" "$OPENCODE_JSONC.bak"
  echo "Merging config into existing opencode.jsonc..."
  tmp=$(mktemp)
  jq -s '.[0] * .[1]' "$OPENCODE_JSONC" <(echo "$BASE_CONFIG") > "$tmp" && mv "$tmp" "$OPENCODE_JSONC"
else
  mkdir -p "$CONFIG_DIR"
  echo "$BASE_CONFIG" | jq '.' > "$OPENCODE_JSONC"
fi

echo "OpenCode base install complete."

# 4. Prompt for distro selection
distros=$(gum choose --limit 1 --header "Install an OpenCode distro? (Conflicting packages -- pick 1)" \
  'No' \
  'oh-my-opencode' \
  'oh-my-opencode-slim')

while IFS= read -r distro <&3; do
  case $distro in
    'oh-my-opencode')
      echo "Installing oh-my-opencode..."
      bunx oh-my-opencode install
      echo "oh-my-opencode installed. Use 'omoc' to launch."
      ;;
    'oh-my-opencode-slim')
      echo "Installing oh-my-opencode-slim..."
      bunx oh-my-opencode-slim@latest install
      echo "oh-my-opencode-slim installed. Use 'omoc-slim' to launch."
      ;;
  esac
done 3<<< "$distros"

echo "OpenCode setup complete."
