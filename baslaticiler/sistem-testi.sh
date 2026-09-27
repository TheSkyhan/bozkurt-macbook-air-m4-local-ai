#!/bin/zsh
source "${0:A:h}/../motorlar/lib/ortam.zsh"
set -euo pipefail
exec python3 "$BOZKURT_ROOT/araclar/sistem_dogrula.py" "$@"
