#!/bin/zsh
source "${0:A:h}/../motorlar/lib/ortam.zsh"
# Eski doğrudan başlatıcı; güncel Bozkurt menüsüne yönlendirir.
set -euo pipefail

exec "$BOZKURT_ROOT/baslaticiler/baslat-asistan.sh"
