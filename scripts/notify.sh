#!/usr/bin/env bash
# Notification hook: route notifications to ntfy.sh, Slack, or email
# Reads notification data from stdin JSON.
# Configuration via environment variables:
#   NTFY_TOPIC      — ntfy.sh topic name (free, no account needed)
#   SLACK_WEBHOOK_URL — Slack incoming webhook URL
#   NOTIFICATION_EMAIL — email address for sendmail/msmtp
#
# If no notification method is configured, exits silently.

set -uo pipefail

# Read notification from stdin
input=$(cat)
title=$(echo "$input" | jq -r '.title // "Claude Code Notification"' 2>/dev/null)
message=$(echo "$input" | jq -r '.message // .body // "Task completed"' 2>/dev/null)

# Load .env if present (check common locations)
for env_file in ".env" "$HOME/.env" "$HOME/dev/phd-data-engine/.env"; do
    if [ -f "$env_file" ]; then
        set -a
        # shellcheck disable=SC1090
        source "$env_file" 2>/dev/null || true
        set +a
        break
    fi
done

sent=false

# Method 1: ntfy.sh
if [ -n "${NTFY_TOPIC:-}" ]; then
    curl -s \
        -H "Title: $title" \
        -d "$message" \
        "https://ntfy.sh/$NTFY_TOPIC" >/dev/null 2>&1 && sent=true
fi

# Method 2: Slack webhook
if [ -n "${SLACK_WEBHOOK_URL:-}" ]; then
    payload=$(jq -n --arg text "*$title*\n$message" '{"text": $text}')
    curl -s -X POST \
        -H 'Content-type: application/json' \
        -d "$payload" \
        "$SLACK_WEBHOOK_URL" >/dev/null 2>&1 && sent=true
fi

# Method 3: Email
if [ -n "${NOTIFICATION_EMAIL:-}" ]; then
    if command -v msmtp >/dev/null 2>&1; then
        echo -e "Subject: $title\n\n$message" | msmtp "$NOTIFICATION_EMAIL" 2>/dev/null && sent=true
    elif command -v sendmail >/dev/null 2>&1; then
        echo -e "Subject: $title\n\n$message" | sendmail "$NOTIFICATION_EMAIL" 2>/dev/null && sent=true
    fi
fi

exit 0
