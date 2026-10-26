#!/bin/bash
# Pitch Ally library unlock. Usage: bash unlock.sh 'ACCESS-CODE' /destination/folder
CODE="$1"; DEST="$2"; LIB="$(cd "$(dirname "$0")" && pwd)/library"
if [ -z "$CODE" ] || [ -z "$DEST" ]; then echo "ACCESS CODE NOT VALID"; exit 3; fi
K=""
for f in "$LIB"/keys/*.enc; do
  out=$(openssl enc -d -aes-256-cbc -pbkdf2 -iter 200000 -md sha256 -in "$f" -pass "pass:$CODE" 2>/dev/null | tr -d "\000" | head -c 100 || true)
  case "$out" in PAK1:*) K="${out#PAK1:}"; K="${K%%[[:space:]]*}"; break;; esac
done
if [ -z "$K" ]; then echo "ACCESS CODE NOT VALID"; exit 3; fi
rm -rf "$DEST"; mkdir -p "$DEST"
if openssl enc -d -aes-256-cbc -pbkdf2 -iter 100000 -md sha256 -in "$LIB/core.tgz.enc" -pass "pass:$K" 2>/dev/null | tar -xz -C "$DEST" 2>/dev/null; then
  echo "UNLOCKED"
else
  echo "UNLOCK FAILED"; exit 4
fi
