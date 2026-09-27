#!/bin/zsh
# Initialize an isolated configuration without modifying your existing Pi profile.
set -euo pipefail
source "${0:A:h}/motorlar/lib/ortam.zsh"
if [[ "$(uname -s)" != Darwin || "$(uname -m)" != arm64 ]]; then
  print -u2 "Bu dağıtım macOS Apple Silicon içindir / macOS Apple Silicon required."
  exit 1
fi
for tool in python3 pi; do
  command -v "$tool" >/dev/null || { print -u2 "Eksik / missing: $tool (docs/INSTALL.tr.md)"; exit 1; }
done
mkdir -p "$BOZKURT_ROOT/gunlukler" "$BOZKURT_ROOT/modeller"
print "Yapılandırma hazır / Configuration ready: $PI_CODING_AGENT_DIR"
print "Çalışma alanı / Workspace: $BOZKURT_WORKSPACE"
print "Modelleri kurun / Install models: docs/MODELS.md"
print "Başlat / Start: $BOZKURT_ROOT/baslaticiler/bozkurt"
