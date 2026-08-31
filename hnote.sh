#!/data/data/com.termux/files/usr/bin/bash
# hnote — Quick note from phone to Dell Harley
# Usage: hnote "message text here"
# Pushes to GitHub → Dell picks up within 30 seconds

REPO="JimmyLee80601/harley-opencode-config"
BRANCH="main"
INBOX="HarleyBrain/inbox"
TOKEN_FILE="$HOME/.gh_token"

# Get token
if [ ! -f "$TOKEN_FILE" ]; then
    echo "No GitHub token. Run: echo 'ghp_YOUR_TOKEN' > $TOKEN_FILE"
    exit 1
fi
TOKEN=$(cat "$TOKEN_FILE" | tr -d '\n')

if [ -z "$1" ]; then
    echo "Usage: hnote \"message text\""
    echo "  hnote --status    Check Dell status"
    echo "  hnote --list      List recent notes"
    exit 0
fi

MSG="$1"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
FILENAME="note_${TIMESTAMP}.md"
FILEPATH="${INBOX}/${FILENAME}"

# Create note content
CONTENT="---
from: phone
time: $(date -Iseconds)
read: false
---

$MSG"

# Base64 encode
B64=$(echo -n "$CONTENT" | base64 -w 0)

# Check if inbox dir exists, create if not
CREATE_DIR=$(curl -s -o /dev/null -w "%{http_code}" \
    -H "Authorization: token $TOKEN" \
    "https://api.github.com/repos/$REPO/contents/$INBOX")

if [ "$CREATE_DIR" = "404" ]; then
    # Create .gitkeep in inbox
    curl -s -X PUT \
        -H "Authorization: token $TOKEN" \
        -H "Content-Type: application/json" \
        "https://api.github.com/repos/$REPO/contents/${INBOX}/.gitkeep" \
        -d "{\"message\":\"Create inbox\",\"content\":\"$(echo -n '' | base64 -w 0)\",\"branch\":\"$BRANCH\"}" > /dev/null
fi

# Push note
RESP=$(curl -s -X PUT \
    -H "Authorization: token $TOKEN" \
    -H "Content-Type: application/json" \
    "https://api.github.com/repos/$REPO/contents/${FILEPATH}" \
    -d "{\"message\":\"hnote: $MSG\",\"content\":\"$B64\",\"branch\":\"$BRANCH\"}")

# Check result
if echo "$RESP" | grep -q '"content"'; then
    echo "✓ Note sent to Dell — $(date +%H:%M:%S)"
    echo "  File: $FILENAME"
else
    echo "✗ Failed to send note"
    echo "$RESP" | grep -o '"message":"[^"]*"' | head -1
fi
