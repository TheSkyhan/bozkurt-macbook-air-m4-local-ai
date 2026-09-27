#!/bin/zsh
source "${0:A:h}/../motorlar/lib/ortam.zsh"
# Bozkurt headless kod ajanı sarmalayıcısı.
#
# Sorun: `pi --print` uzun bir turun sonunda (ör. 180 sn'lik tek üretim) istemci
# tarafında "This operation was aborted" ile düşebiliyor; sunucu turu temiz
# bitirse bile son adımlar (kod düzeltmesi, AJAN_HAFIZA.md) yarım kalıyor.
# Çözüm: bu sarmalayıcı aynı session-id ile görev tamamlanana kadar otomatik
# devam eder. Tüm proje kodunu Bonsai yazar; sarmalayıcı yalnız süreci ayakta
# tutar ve kesinti sonrası kaldığı yerden sürdürür.
#
# Kullanım (ortam değişkenleriyle):
#   BOZKURT_GOREV_DOSYA=/yol/gorev.md BOZKURT_PROJE=/yol/proje \
#   BOZKURT_SID=<uuid> baslat-headless-ajan.sh
# İsteğe bağlı: BOZKURT_MODEL, BOZKURT_MAX_TUR, BOZKURT_DUSUNME, BOZKURT_GOREV.
set -uo pipefail

ROOT="$BOZKURT_ROOT"
LOG_DIR="$ROOT/gunlukler"
mkdir -p "$LOG_DIR"
export PATH="/opt/homebrew/bin:$PATH"
export BOZKURT_EARLY_COMPACT_AT=15000

SESSION_ID="${BOZKURT_SID:-$(uuidgen | tr 'A-Z' 'a-z')}"
PROJECT_DIR="${BOZKURT_PROJE:-$BOZKURT_WORKSPACE}"
MODEL="${BOZKURT_MODEL:-yerel-bonsai/Ternary-Bonsai-2-27B-PQ2_0.gguf}"
MAX_TUR="${BOZKURT_MAX_TUR:-8}"
DUSUNME="${BOZKURT_DUSUNME:-off}"
SENTINEL="GOREV_TAMAM"
ARACLAR="${BOZKURT_ARACLAR:---tools read,bash,edit,write,grep,find,ls}"
EKLENTI="$ROOT/eklentiler/otonom-calisma.ts"
# BOZKURT_EKLENTISIZ=1 → extension'ı yükleme. Tek dosyalık, reçeteli küçük
# görevlerde extension'ın uzun OTONOM PROTOKOL'ü prompt'u ~şişirip 24.5K bağlamı
# dolduruyor ve swap altında her tur baştan işleniyor. Bu anahtar prompt'u küçültür.
EKLENTI_ARG=(--extension "$EKLENTI")
if [[ "${BOZKURT_EKLENTISIZ:-0}" == "1" ]]; then
  EKLENTI_ARG=()
fi
LOG="$LOG_DIR/headless-$SESSION_ID.log"

EK="Türkçe konuş. Sen Bonsai, headless çalışan bir kod ajanısın. Varsayılan çalışma alanı $PROJECT_DIR. ÖNEMLİ ARAÇ KURALI: Pi araçları işlev çağrılarıdır; bir dosya oluşturmak/düzenlemek veya komut çalıştırmak gerekiyorsa ilgili aracı (write/edit/bash) GERÇEKTEN çağır. Dosya içeriğini, kodu veya komut çıktısını düz yanıt metni olarak ASLA yazma; uydurma araç sonucu üretme. Her turda ya somut bir araç çağrısı yap ya da görev bittiyse kısa sonuç bildir. Kod görevinde önce proje kökündeki AGENTS.md ve AJAN_HAFIZA.md dosyalarını, ardından ilgili kaynak dosyaları oku. AJAN_HAFIZA.md yoksa İLK adım olarak sen oluştur (Mevcut durum / Sıradaki adımlar / Kurallar bölümleriyle); kullanıcının elle yaratmasını bekleme. Doğrudan küçük, çalışan bir parça üret, sonra uygun test/lint/derleme komutuyla doğrula; doğrulama sonucu olmadan işi tamamlanmış ilan etme. Bağımlılık ve önbellek dizinlerine (venv, .venv, node_modules, site-packages, __pycache__, .pytest_cache, .git, build) ASLA girme. Dosyayı yeniden yazmadan önce oku; çok büyük tek dosyayı tek yanıtta yazmaya çalışma — gerekirse önce iskeleti write ile oluştur, sonra edit ile bölümleri ekle. Uzun iç muhakeme veya yeniden planlama yazma; yalnız kısa durum bilgisi ver. Her doğrulanmış aşamadan hemen sonra AJAN_HAFIZA.md dosyasını kısa ve somut biçimde güncelle; işi sona bırakma. Kullanıcının açıkça istemediği silme, yayınlama, ödeme ya da sipariş onayı yapma. Görev TAMAMEN bitip tüm doğrulamalar geçtiğinde, yanıtının SON satırına yalnız şunu yaz: $SENTINEL"

# Extension'sız mod: kısa sistem eki — tek dosyalık reçeteli görev için yeterli,
# prompt'u küçük tutar (AGENTS/AJAN_HAFIZA okuma zinciri gerekmez).
if [[ "${BOZKURT_EKLENTISIZ:-0}" == "1" ]]; then
  EK="Türkçe konuş. Sen Bonsai headless kod ajanısın. Çalışma alanı $PROJECT_DIR. ARAÇ KURALI: dosya yazmak/düzenlemek veya komut çalıştırmak için write/edit/bash aracını GERÇEKTEN çağır; kodu düz yanıt metni olarak ASLA yazma. Mevcut dosyayı değiştirmeden önce oku; istenen değişikliği uygula ve uygun testle doğrula. İş bitince yanıtının SON satırına yalnız şunu yaz: $SENTINEL"
fi

if [[ -n "${BOZKURT_GOREV_DOSYA:-}" && -f "${BOZKURT_GOREV_DOSYA}" ]]; then
  GOREV="$(<"$BOZKURT_GOREV_DOSYA")"
elif [[ -n "${BOZKURT_GOREV:-}" ]]; then
  GOREV="$BOZKURT_GOREV"
else
  print -u2 "Hata: BOZKURT_GOREV veya BOZKURT_GOREV_DOSYA gerekli."
  exit 1
fi

cd "$PROJECT_DIR" || { print -u2 "Proje dizini açılamadı: $PROJECT_DIR"; exit 1; }

print "Bozkurt headless ajan | oturum=$SESSION_ID | proje=$PROJECT_DIR" | tee -a "$LOG"
print "model=$MODEL | düşünme=$DUSUNME | en fazla tur=$MAX_TUR" | tee -a "$LOG"

DEVAM_PROMPT="AJAN_HAFIZA.md ve son doğrulama çıktısını oku; kaldığın yerden devam et. ÖNEMLİ: dosya oluşturmak/düzenlemek için write/edit aracını GERÇEKTEN çağır; kodu düz yanıt metni olarak yazma. Yalnız sıradaki en küçük doğrulanabilir adımı uygula ve test et. Her doğrulanmış aşamadan sonra AJAN_HAFIZA.md'yi güncelle. Tüm iş bitip doğrulamalar geçince yanıtının SON satırına yalnız '$SENTINEL' yaz."

PROMPT="$GOREV"
tur=1
while (( tur <= MAX_TUR )); do
  print "\n===== TUR $tur/$MAX_TUR =====" | tee -a "$LOG"
  out="$(pi --offline --no-extensions --no-skills --print --session-id "$SESSION_ID" --model "$MODEL" \
    --thinking "$DUSUNME" ${=ARACLAR} "${EKLENTI_ARG[@]}" \
    --append-system-prompt "$EK" "$PROMPT" 2>&1)"
  sonuc=$?
  print -r -- "$out" | tee -a "$LOG"
  if (( sonuc == 0 )) && [[ "$(print -r -- "$out" | sed '/^[[:space:]]*$/d' | tail -1)" == "$SENTINEL" ]]; then
    print "\nGörev tamamlandı (tur $tur). Sentinel görüldü: $SENTINEL" | tee -a "$LOG"
    exit 0
  fi
  if print "$out" | grep -qi "aborted"; then
    print "Tur $tur kesintiyle bitti (aborted); aynı oturum sürdürülüyor…" | tee -a "$LOG"
  else
    print "Tur $tur sentinel olmadan bitti; kalan iş için sürdürülüyor…" | tee -a "$LOG"
  fi
  PROMPT="$DEVAM_PROMPT"
  tur=$((tur + 1))
done

print -u2 "\nMaksimum tur ($MAX_TUR) doldu; görev sentinel ile tamamlanmadı. Oturum: $SESSION_ID" | tee -a "$LOG"
exit 2
