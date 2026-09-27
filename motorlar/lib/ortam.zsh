#!/bin/zsh
export BOZKURT_ROOT="${BOZKURT_ROOT:-${${(%):-%N}:A:h:h:h}}"
export BOZKURT_WORKSPACE="${BOZKURT_WORKSPACE:-$HOME/Bozkurt-Workspace}"
export PI_CODING_AGENT_DIR="${PI_CODING_AGENT_DIR:-$BOZKURT_ROOT/.runtime/pi}"
mkdir -p "$BOZKURT_WORKSPACE" "$PI_CODING_AGENT_DIR"
for name in models settings; do
  [[ -f "$PI_CODING_AGENT_DIR/$name.json" ]] || cp "$BOZKURT_ROOT/yapilandirma/$name.example.json" "$PI_CODING_AGENT_DIR/$name.json"
done
