#!/bin/zsh
source "${0:A:h}/../motorlar/lib/ortam.zsh"
# Ternary Bonsai 2 27B: M4 Air 16 GB için dengeli yerel profil.
set -euo pipefail

ROOT="$BOZKURT_ROOT/motorlar/Bonsai-demo"
MODEL="$ROOT/models/bonsai2-gguf/27B/Ternary-Bonsai-2-27B-PQ2_0.gguf"
HELPER="$BOZKURT_ROOT/motorlar/lib/sunucu-yardimcisi.zsh"

if [[ ! -f "$MODEL" ]]; then
  print "Bonsai 2 model indirmesi henüz tamamlanmadı. Bu pencereyi kapatıp tekrar deneyin."
  exit 1
fi

source "$HELPER"
bozkurt_sunucuyu_durdur

cd "$ROOT"
export BONSAI_HOST=127.0.0.1
export PORT=8080
export BONSAI_FAMILY=bonsai2
export BONSAI_MODEL=27B
# 24K bağlam, q8_0 KV önbelleğiyle birlikte 16 GB Air'de sığar (KV ~yarıya iner).
# Swap belirgin artarsa BONSAI_CTX=16384 ile başlatın.
export BONSAI_CTX="${BONSAI_CTX:-24576}"
export BONSAI_MMPROJ_CPU=1
# Uzun proje ajanında prompt önbelleği, ham decode hızından daha değerlidir.
export BONSAI_SPECULATIVE=0
# 16 GB Air'de araç döngülerini çevik tut; uzun planlama yerine küçük doğrulanabilir adımlar.
# Sıfır bütçe, yalnızca sayısal sınır değildir: şablonda düşünmeyi de açıkça
# kapatır. Aksi hâlde kısa isteklerde bütün çıktı düşünme kanalına gidebilir.
REASONING_BUDGET="${BONSAI_REASONING_BUDGET:-384}"
if [[ "$REASONING_BUDGET" == "0" ]]; then
  REASONING_MODE="off"
else
  REASONING_MODE="on"
fi
# KV önbelleği q8_0: 24K bağlamın bellek maliyetini yarıya indirir, kalite kaybı
# ihmal edilebilir. ctx-checkpoints + cache-reuse, ajan turlarında prompt cache
# tahliye edilse bile bağlamın sıfırdan yeniden işlenmesini ("başa sarma") önler.
# cache-ram 4096: varsayılan 8192, modelle birlikte 16 GB'da swap'e taşıyordu.
exec ./scripts/start_llama_server.sh --parallel 1 --reasoning-budget "$REASONING_BUDGET" \
  --reasoning "$REASONING_MODE" --no-reasoning-preserve \
  --cache-type-k q8_0 --cache-type-v q8_0 \
  --ctx-checkpoints 128 --checkpoint-min-step 128 --cache-reuse 256 --cache-ram 4096 \
  --cors-origins localhost --no-cors-credentials
