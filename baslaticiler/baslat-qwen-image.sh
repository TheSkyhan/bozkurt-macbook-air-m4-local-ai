#!/bin/zsh
source "${0:A:h}/../motorlar/lib/ortam.zsh"
# Qwen Image 2.1 için M4 / 16 GB birleşik bellek odaklı yerel başlatıcı.
set -euo pipefail
# Kutu çizgileri (─) çok baytlıdır; LANG'sız bağlamlarda (boru, otomasyon) bozulur.
export LANG="${LANG:-en_US.UTF-8}"

ROOT="$BOZKURT_ROOT"
WORKSPACE="$BOZKURT_WORKSPACE"
SD_CLI="$ROOT/motorlar/qwen-image-backend/build-metal/bin/sd-cli"
# Q8 çekirdek, Qwen3-VL kodlayıcıyla birlikte M4 16 GB'ta yoğun swap oluşturur.
# Q4_K aynı mimariyi güvenli çalışma alanıyla çalıştırmak için varsayılandır.
DIFFUSION_MODEL="$ROOT/modeller/model-arsivi/qwen-image-2.1/diffusion_models/qwen_image_2.1-Q4_K.gguf"
TEXT_ENCODER="$ROOT/modeller/model-arsivi/qwen-image-2.1/text_encoders/Qwen3VL-8B-Instruct-Q4_K_M.gguf"
VISION_PROJECTOR="$ROOT/modeller/model-arsivi/qwen-image-2.1/text_encoders/mmproj-Qwen3VL-8B-Instruct-Q8_0.gguf"
VAE_MODEL="$ROOT/modeller/model-arsivi/qwen-image-2.1/vae/qwen_image_2.1_vae_bf16.safetensors"
LORA_DIR="$ROOT/modeller/model-arsivi/qwen-image-2.1/loras"
OUTPUT_DIR="$WORKSPACE/Bozkurt-Gorseller"
LOG_DIR="$ROOT/gunlukler"

# Ölçekleme ve efektler ffmpeg'in yerleşik filtrelerine dayanır; eksikse üretim
# ya tamamlanamaz ya da efektler sessizce atlanır. Baştan açık hata vermek daha sağlıklı.
if ! command -v ffmpeg >/dev/null 2>&1; then
  print -u2 "ffmpeg bulunamadı. Kurulum: brew install ffmpeg"
  exit 1
fi

# LoRA güvenlik denetimi: safetensors başlığındaki metadata, dosya adından daha
# güvenilirdir. NSFW/NCII işaretli LoRA'lar Qwen Image'a uygulanmaz; üretim
# LoRA'sız sürer ve dosyanın kendisine dokunulmaz.
lora_guvenli() {
  /usr/bin/python3 - "$1" <<'PYEOF'
import json, struct, sys
try:
    with open(sys.argv[1], 'rb') as f:
        n = struct.unpack('<Q', f.read(8))[0]
        if n > 16_000_000: raise ValueError('header too large')
        hdr = json.loads(f.read(n))
    meta = json.dumps(hdr.get('__metadata__', {}), ensure_ascii=False).lower()
    kotu = any(k in meta for k in ('nsfw', 'ncii', 'nude', 'explicit', 'porn'))
    print('GUVENLI' if not kotu else 'NSFW')
except Exception:
    print('HATA')
PYEOF
}

source "$ROOT/motorlar/lib/sunucu-yardimcisi.zsh"
# Sunucu burada durdurulmaz: İşlem 3 (efekt) AI kullanmaz ve metin modeli
# çalışırken de kullanılabilmelidir. Üretim yolları (İşlem 1/2) sd-cli'den
# hemen önce ayrıca durdurur; böylece menüde gezinmek veya yalnız efekt basmak
# 8080'deki sohbet/ajan oturumunu öldürmez.

mkdir -p "$OUTPUT_DIR"
mkdir -p "$LOG_DIR"

RENK_AKSAN=$'\033[38;5;39m'
RENK_BASARI=$'\033[38;5;42m'
RENK_SOLUK=$'\033[38;5;245m'
RENK_SIFIR=$'\033[0m'
gorsel_satir() { printf '%s│%s  %-66s  %s│%s\n' "$RENK_AKSAN" "$RENK_SIFIR" "$1" "$RENK_AKSAN" "$RENK_SIFIR"; }
gorsel_kart() {
  local baslik="$1" ayrac=''
  ayrac=${(l:70::─:)ayrac}
  printf '%s╭%s╮%s\n' "$RENK_AKSAN" "$ayrac" "$RENK_SIFIR"
  gorsel_satir "$baslik"
  printf '%s├%s┤%s\n' "$RENK_AKSAN" "$ayrac" "$RENK_SIFIR"
}
ADIM=0
gorsel_bolum() {
  (( ADIM += 1 ))
  printf '\n%s── ADIM %d  •  %s%s\n' "$RENK_AKSAN" "$ADIM" "$1" "$RENK_SIFIR"
}

gorsel_kart "QWEN IMAGE 2.1  •  YEREL METAL ÜRETİM"
gorsel_satir "Q4_K  •  Instagram oranları  •  Türkçe istem  •  renk efektleri"
gorsel_satir "Çıktı klasörü: $OUTPUT_DIR"
printf '%s╰%s╯%s\n' "$RENK_AKSAN" "${(l:70::─:)${:-}}" "$RENK_SIFIR"
print "${RENK_SOLUK}Not: Aynı anda başka yerel model çalıştırmayın. İlk üretim uzun sürebilir.${RENK_SIFIR}"

# Efekt kataloğu: ad → ffmpeg zinciri. Instagram/VSCO tarzı ve sinematik renk
# derecelerinin yerleşik renk filtreleriyle dürüst yaklaştırmalarıdır; birebir
# lisanslı LUT değildir. Tek kaynak: hem düzenlemedeki tek efekt seçiminde hem
# İşlem 3'teki toplu uygulamada kullanılır.
typeset -A EFEKT_LISTESI
EFEKT_LISTESI=(
  clarendon   "eq=contrast=1.12:brightness=0.04:saturation=1.08:gamma=1.03,colorbalance=bs=0.04:bh=0.03"
  valencia    "colortemperature=temperature=4800,curves=lighter,eq=brightness=0.05:contrast=0.94:saturation=1.06:gamma=1.02,vignette=PI/5.5"
  gingham     "eq=contrast=0.85:saturation=0.7:brightness=0.06:gamma=1.04,curves=vintage"
  juno        "eq=saturation=1.25:contrast=1.05:gamma=1.02,colorbalance=rs=0.05:rh=0.04:gs=0.02"
  lark        "eq=brightness=0.04:contrast=0.96:saturation=0.88:gamma=1.02,colorbalance=bs=0.03:bh=0.02"
  sinematik   "colorbalance=rs=-0.03:gs=0.02:bs=0.06:rm=0.0:gm=0.0:bm=-0.02:rh=0.06:gh=0.02:bh=-0.04,curves=medium_contrast,eq=saturation=1.12:contrast=1.06:brightness=0.01,vignette=PI/5"
  film-portra "colortemperature=temperature=5000,curves=lighter,eq=contrast=0.9:saturation=0.98:brightness=0.03,vignette=PI/5"
  siyah-beyaz "hue=s=0,curves=strong_contrast,eq=contrast=1.1:gamma=1.02"
  vsco-a6     "eq=brightness=0.05:contrast=0.94:saturation=0.88:gamma=1.04,colorbalance=rh=0.02:gh=0.01"
  vsco-c1     "eq=saturation=1.28:contrast=1.1:gamma=1.0,colorbalance=rh=0.03:gh=0.01"
  vsco-m5     "eq=saturation=0.7:contrast=0.88:brightness=0.02,colorbalance=gs=0.04:bs=0.01,curves=lighter"
  kodak-ektar "eq=saturation=1.3:contrast=1.14:gamma=1.02,colorbalance=rs=0.04:rh=0.03"
  altin-saat  "colortemperature=temperature=4500,eq=saturation=1.12:contrast=1.03:brightness=0.03:gamma=1.03,colorbalance=rh=0.05:gh=0.02,vignette=PI/4.8"
  noir        "colorchannelmixer=rr=.92:gg=.95:bb=1.06,curves=strong_contrast,eq=contrast=1.15:gamma=0.97"
)
EFEKT_SIRASI=(clarendon valencia gingham juno lark sinematik film-portra siyah-beyaz vsco-a6 vsco-c1 vsco-m5 kodak-ektar altin-saat noir)

gorsel_bolum "İŞLEM"
print "  1) Yeni görsel oluştur"
print "  2) Bir görseli düzenle (tişört rengi, saç, arka plan vb.)"
print "  3) Fotoğrafa efekt uygula (AI üretimi yok; tüm efektleri tek seferde basar)"
while true; do
  print -n "İşlem (1-3, varsayılan 1): "
  read -r ISLEM
  ISLEM="${ISLEM:-1}"
  [[ "$ISLEM" == "1" || "$ISLEM" == "2" || "$ISLEM" == "3" ]] && break
  print -u2 "Geçersiz seçim: 1, 2 veya 3 girin."
done
ISLEM_ADI="yeni görsel"
[[ "$ISLEM" == "2" ]] && ISLEM_ADI="düzenleme"
[[ "$ISLEM" == "3" ]] && ISLEM_ADI="efekt"

EDIT_ARGS=()
BACKEND_ARGS=()
INIT_IMAGE=""
USER_PROMPT=""

# ────────────────────────────────────────────────────────────────
# İşlem 2 veya 3 için kaynak görsel
# ────────────────────────────────────────────────────────────────
if [[ "$ISLEM" == "2" || "$ISLEM" == "3" ]]; then
  gorsel_bolum "KAYNAK GÖRSEL"
  print "${RENK_SOLUK}İpucu: Finder’dan görseli bu Terminal penceresine sürükleyip bırakabilirsiniz.${RENK_SIFIR}"
  while true; do
    print -n "Görselin yolu: "
    read -r INIT_IMAGE
    # Terminal'e sürükle-bırak ile gelen boşluk kaçışlarını ve tırnakları temizle.
    INIT_IMAGE="${INIT_IMAGE#\"}"
    INIT_IMAGE="${INIT_IMAGE%\"}"
    INIT_IMAGE="${INIT_IMAGE#\'}"
    INIT_IMAGE="${INIT_IMAGE%\'}"
    INIT_IMAGE="${INIT_IMAGE//\\ / }"
    if [[ -n "${INIT_IMAGE//[[:space:]]/}" && -f "$INIT_IMAGE" ]]; then
      break
    fi
    print -u2 "Görsel dosyası bulunamadı: ${INIT_IMAGE:-boş giriş}"
  done
  if [[ "$ISLEM" == "2" ]]; then
    if [[ ! -s "$VISION_PROJECTOR" ]]; then
      print -u2 "Görsel kimlik projektörü hazır değil: $VISION_PROJECTOR"
      print -u2 "Düzenleme modu yüzleri korumak için bu dosyaya ihtiyaç duyar."
      exit 1
    fi
    # Qwen 2.1 düzenlemesinde --init-img genel img2img yoluna gider ve tüm kareyi
    # yeniden üretir. Resmî yol --ref-image + --llm_vision'dır; görsel kimlik,
    # poz ve kadraj koşullamasını Qwen3-VL projektörü üzerinden taşır.
    EDIT_ARGS=(--llm_vision "$VISION_PROJECTOR" --ref-image "$INIT_IMAGE" --ref-image-args "preset=qwen")
    # Projektör eklenince Metal'de VAE çözümlemesine çok az pay kalır. Sadece VAE'yi
    # CPU'da çalıştırmak, kimlik projektörü ve DiT'i Metal'de tutarak bu taşmayı
    # önler; bu son aşama daha yavaştır ama M4 16 GB'da doğrulanmış şekilde tamamlanır.
    BACKEND_ARGS=(--backend "diffusion=MTL0,te=MTL0,vae=cpu")
    print -n "İsteğe bağlı siyah/beyaz düzenleme maskesi (boş bırak = model seçer): "
    read -r MASK_IMAGE
    MASK_IMAGE="${MASK_IMAGE#\"}"
    MASK_IMAGE="${MASK_IMAGE%\"}"
    MASK_IMAGE="${MASK_IMAGE#\'}"
    MASK_IMAGE="${MASK_IMAGE%\'}"
    MASK_IMAGE="${MASK_IMAGE//\\ / }"
    if [[ -n "${MASK_IMAGE//[[:space:]]/}" ]]; then
      if [[ ! -f "$MASK_IMAGE" ]]; then
        print -u2 "Maske dosyası bulunamadı: $MASK_IMAGE"
        exit 1
      fi
      EDIT_ARGS+=(--mask "$MASK_IMAGE")
    fi
  fi
fi

if [[ "$ISLEM" == "3" ]]; then
  gorsel_bolum "EFEKT UYGULAMA"
  gorsel_kart "EFEKTLER HAZIRLANIYOR"
  gorsel_satir "Kaynak: ${INIT_IMAGE:t}"
  gorsel_satir "AI üretimi yok; fotoğrafın kendisi değişmez, ${#EFEKT_SIRASI[@]} efekt ayrı dosya basılır."
  printf '%s╰%s╯%s\n' "$RENK_AKSAN" "${(l:70::─:)${:-}}" "$RENK_SIFIR"
  STAMP="$(date +%Y%m%d-%H%M%S)"
  LOG_FILE="$LOG_DIR/efekt-$STAMP.log"
  # sips önce HEIC/HEIF'i çözer ve EXIF yönünü piksele işler (iPhone fotoğrafları
  # dik durur); başarısız olursa ffmpeg kaynağı doğrudan okumayı dener.
  # PNG'nin EXIF yönü olmadığından dönüşüme gerek yoktur.
  CALISILAN="$OUTPUT_DIR/.efekt-kaynak-$STAMP.png"
  if [[ "${INIT_IMAGE:e:l}" == "png" ]]; then
    CALISILAN="$INIT_IMAGE"
  elif ! sips -s format png "$INIT_IMAGE" --out "$CALISILAN" >>"$LOG_FILE" 2>&1; then
    CALISILAN="$INIT_IMAGE"
  fi
  TEMEL="${INIT_IMAGE:t:r}"
  URETILEN=0
  for AD in "${EFEKT_SIRASI[@]}"; do
    CIKTI="$OUTPUT_DIR/efekt-$STAMP-$AD-$TEMEL.png"
    if ffmpeg -nostdin -y -hide_banner -loglevel error -i "$CALISILAN" \
      -vf "${EFEKT_LISTESI[$AD]}" -frames:v 1 "$CIKTI" >>"$LOG_FILE" 2>&1; then
      (( URETILEN += 1 ))
      print "${RENK_SOLUK}  ✓ ${AD} → ${CIKTI:t}${RENK_SIFIR}"
    else
      print -u2 "  ✗ ${AD} üretilemedi (günlük: $LOG_FILE)"
    fi
  done
  [[ "$CALISILAN" != "$INIT_IMAGE" ]] && rm -f "$CALISILAN"
  print
  gorsel_kart "✓ EFEKTLER HAZIR"
  gorsel_satir "$URETILEN/${#EFEKT_SIRASI[@]} dosya: $OUTPUT_DIR"
  gorsel_satir "Teknik günlük: $LOG_FILE"
  printf '%s╰%s╯%s\n' "$RENK_BASARI" "${(l:70::─:)${:-}}" "$RENK_SIFIR"
  open "$OUTPUT_DIR"
  (( URETILEN == ${#EFEKT_SIRASI[@]} )) || exit 1
  exit 0
fi

for required in "$SD_CLI" "$TEXT_ENCODER" "$VAE_MODEL"; do
  if [[ ! -s "$required" ]]; then
    print -u2 "Qwen Image 2.1 henüz hazır değil: $required"
    print -u2 "M4 16 GB için Q4_K çekirdeği gereklidir; Q8 model varsayılan olarak kullanılmaz."
    exit 1
  fi
done
if [[ ! -f "$DIFFUSION_MODEL" || "$(stat -f %z "$DIFFUSION_MODEL" 2>/dev/null || print 0)" -lt 4100000000 ]]; then
  print -u2 "Qwen Image 2.1 çekirdeği hâlâ indiriliyor: $DIFFUSION_MODEL"
  exit 1
fi
gorsel_bolum "KANVAS"
print "${RENK_SOLUK}M4 / 16 GB güvenli kanvaslar seçilir; nihai dosya Instagram ölçüsüne ölçeklenir.${RENK_SIFIR}"
print "  1) Kare                 512×512  → Instagram 1080×1080"
print "  2) Instagram gönderisi  512×640  → Instagram 1080×1350"
print "  3) Hikâye / Reel        432×768  → Instagram 1080×1920"
if [[ "$ISLEM" == "2" ]]; then
  print "  4) Kaynak oranını koru  → yüz/kadraj korunması için önerilen"
  KANVAS_VARSAYILAN=4
else
  KANVAS_VARSAYILAN=2
fi
while true; do
  print -n "Kanvas (1-4, varsayılan $KANVAS_VARSAYILAN): "
  read -r KANVAS
  KANVAS="${KANVAS:-$KANVAS_VARSAYILAN}"
  [[ "$KANVAS" == "1" || "$KANVAS" == "2" || "$KANVAS" == "3" || "$KANVAS" == "4" ]] && break
  print -u2 "Geçersiz seçim: 1-4 arası girin."
done
case "$KANVAS" in
  1) WIDTH=512; HEIGHT=512; FINAL_WIDTH=1080; FINAL_HEIGHT=1080; KANVAS_ADI="kare" ;;
  # Qwen 2.1'in üç bileşeni M4 16 GB'da yaklaşık 9 GB Metal ağırlığı tutar.
  # 640×800, örnekleme tamamlanmasına rağmen VAE decode'da bellek yetersizliği
  # verdiği için kanvaslar bu doğrulanmış güvenli sınıra çekilir.
  2) WIDTH=512; HEIGHT=640; FINAL_WIDTH=1080; FINAL_HEIGHT=1350; KANVAS_ADI="gonderi-4x5" ;;
  3) WIDTH=432; HEIGHT=768; FINAL_WIDTH=1080; FINAL_HEIGHT=1920; KANVAS_ADI="hikaye-9x16" ;;
  4)
    if [[ "$ISLEM" != "2" ]]; then
      print -u2 "Kaynak oranı yalnızca düzenleme modunda kullanılabilir."
      exit 1
    fi
    INPUT_WIDTH="$(sips -g pixelWidth "$INIT_IMAGE" | awk '/pixelWidth/{print $2}')"
    INPUT_HEIGHT="$(sips -g pixelHeight "$INIT_IMAGE" | awk '/pixelHeight/{print $2}')"
    if [[ -z "$INPUT_WIDTH" || -z "$INPUT_HEIGHT" || "$INPUT_WIDTH" -le 0 || "$INPUT_HEIGHT" -le 0 ]]; then
      print -u2 "Kaynak görselin boyutları okunamadı."
      exit 1
    fi
    if (( INPUT_WIDTH >= INPUT_HEIGHT )); then
      WIDTH=640
      HEIGHT=$(( INPUT_HEIGHT * WIDTH / INPUT_WIDTH / 32 * 32 ))
    else
      HEIGHT=640
      WIDTH=$(( INPUT_WIDTH * HEIGHT / INPUT_HEIGHT / 32 * 32 ))
    fi
    if (( WIDTH < 32 || HEIGHT < 32 )); then
      print -u2 "Kaynak görsel güvenli üretim boyutuna dönüştürülemedi."
      exit 1
    fi
    if (( INPUT_WIDTH >= INPUT_HEIGHT )); then
      FINAL_WIDTH=1440
      FINAL_HEIGHT=$(( INPUT_HEIGHT * FINAL_WIDTH / INPUT_WIDTH / 2 * 2 ))
    else
      FINAL_HEIGHT=1440
      FINAL_WIDTH=$(( INPUT_WIDTH * FINAL_HEIGHT / INPUT_HEIGHT / 2 * 2 ))
    fi
    KANVAS_ADI="kaynak-orani"
    ;;
  *) print -u2 "Geçersiz kanvas seçimi."; exit 1 ;;
esac

gorsel_bolum "KALİTE"
print "  1) Hızlı taslak        16 adım"
print "  2) Dengeli             24 adım  (önerilen)"
print "  3) Ayrıntılı           32 adım  (daha yavaş)"
while true; do
  print -n "Kalite (1-3, varsayılan 2): "
  read -r KALITE
  KALITE="${KALITE:-2}"
  [[ "$KALITE" == "1" || "$KALITE" == "2" || "$KALITE" == "3" ]] && break
  print -u2 "Geçersiz seçim: 1-3 arası girin."
done
case "$KALITE" in
  1) STEPS=16; KALITE_ADI="hizli" ;;
  2) STEPS=24; KALITE_ADI="dengeli" ;;
  3) STEPS=32; KALITE_ADI="ayrintili" ;;
  *) print -u2 "Geçersiz kalite seçimi."; exit 1 ;;
esac

gorsel_bolum "STİL ÖN AYARI"
print "${RENK_SOLUK}Profesyonel stil ön ayarı: betiminize otomatik uzman yönerge ekler.${RENK_SIFIR}"
print "  0) Stil yok            kendi betimim yeterli"
print "  1) Stüdyo portresi     yumuşak ışık, net yüz, doğal cilt"
print "  2) Ürün / e-ticaret    temiz arka plan, doğru renkler, keskin detay"
print "  3) Yemek fotoğrafı     doğal ışık, iştah açıcı doku, sığ alan derinliği"
print "  4) Manzara / seyahat   altın saat, derinlik, zengin ama doğal renk"
print "  5) Mimari / iç mekân   düzgün perspektif, dengeli ışık, malzeme dokusu"
print "  6) Moda editoryal      dergi kalitesi, güçlü kompozisyon, kumaş detayı"
print "  7) Sinematik kare      film ışığı, atmosfer, 35mm görünüm"
print "  8) Logo / minimal      sade vektör görünüm, düz renk, negatif alan"
while true; do
  print -n "Stil (0-8, varsayılan 0): "
  read -r STIL
  STIL="${STIL:-0}"
  case "$STIL" in
    0|1|2|3|4|5|6|7|8) break ;;
    *) print -u2 "Geçersiz seçim: 0-8 arası girin." ;;
  esac
done
STIL_METNI=''
case "$STIL" in
  0) STIL_ADI="stilsiz" ;;
  1) STIL_ADI="portre"
     STIL_METNI="Professional studio portrait photography: single subject, soft key light with gentle fill, shallow depth of field at f/2.0, sharp focus on eyes, natural skin texture with visible pores, accurate skin tones, clean uncluttered background, 85mm lens look." ;;
  2) STIL_ADI="urun"
     STIL_METNI="Professional e-commerce product photography: hero product centered, clean neutral background, softbox-style even lighting with subtle shadow, true-to-life colors, crisp macro-level detail on materials and edges, no clutter, catalog quality." ;;
  3) STIL_ADI="yemek"
     STIL_METNI="Professional food photography: appetizing fresh ingredients, soft directional natural window light, shallow depth of field, rich true-to-life colors, visible texture and steam or moisture where natural, styled but not overcrowded scene, overhead or 45-degree angle as fits." ;;
  4) STIL_ADI="manzara"
     STIL_METNI="Professional landscape photography: golden hour or soft overcast light, strong foreground-midground-background depth, rich but natural color grading, crisp detail across the frame, wide-angle composition with a clear focal point, dramatic yet realistic sky." ;;
  5) STIL_ADI="mimari"
     STIL_METNI="Professional architectural photography: corrected vertical lines and accurate perspective, balanced ambient and natural light, clean geometric composition, realistic material textures of concrete glass wood and metal, wide lens without distracting distortion." ;;
  6) STIL_ADI="moda"
     STIL_METNI="High-end fashion editorial photography: confident model pose, magazine-quality composition, directional studio or natural light shaping the garment, detailed realistic fabric texture drape and folds, refined color palette, tasteful and fully clothed styling." ;;
  7) STIL_ADI="sinematik"
     STIL_METNI="Cinematic film still: motivated dramatic lighting with clear key and rim light, atmospheric depth and subtle haze, 35mm anamorphic look with natural lens characteristics, muted teal-and-amber grade, storytelling composition with a single clear subject." ;;
  8) STIL_ADI="logo"
     STIL_METNI="Minimal vector-style logo design: simple bold geometric mark, flat colors, generous negative space, perfectly centered on a clean background, crisp edges, no gradients unless subtle, no text unless explicitly requested." ;;
  *) print -u2 "Geçersiz stil seçimi."; exit 1 ;;
esac

# İşlem 1 ve 2 için kullanıcıdan betim al.
  gorsel_bolum "BETİM"
  while true; do
    print -n "Ne üretmek ya da neyi değiştirmek istiyorsun? "
    read -r USER_PROMPT
    [[ -n "${USER_PROMPT//[[:space:]]/}" ]] && break
    print -u2 "Görsel betimi boş olamaz."
  done

# Qwen Türkçe istemleri anlayabilir. Bu çift dilli yönlendirme çeviri iddiasında
# bulunmaz; kullanıcının Türkçe niyetini korurken kompozisyon ve netlik sinyallerini
# görüntü modelinin en güçlü olduğu İngilizce biçimde ekler. İkinci bir LLM açılmaz.
if [[ "$ISLEM" == "2" ]]; then
  PROMPT="$USER_PROMPT

Image-editing direction: Apply exactly the changes requested by the user to the supplied image. Preserve all unmentioned subjects, identity, objects, composition, lighting and background. Keep edits localized where the request is local; allow broader changes only when requested. Maintain realistic boundaries, shadows and occlusion."

else
  PROMPT="$USER_PROMPT

Professional visual direction: Create one clear primary subject with intentional composition, coherent perspective and lighting, realistic anatomy and proportions, crisp focus on the main subject, fine natural textures, clean details and balanced color grading. No accidental text, watermark, logo, blur or low-resolution artifacts."
fi
if [[ -n "$STIL_METNI" ]]; then
  PROMPT="$PROMPT

Style preset: $STIL_METNI"
fi

# Kalite odaklı genel negatif: anatomik bozulma ve üretim artıklarını bastırır.
# Düzenleme modunda kimliği korumak için negatif daha dar tutulur.
if [[ "$ISLEM" == "2" ]]; then
  NEGATIVE="blurry, lowres, watermark, signature, deformed hands, extra limbs, bad anatomy, changed face, identity drift, different face, face mismatch"
else
  NEGATIVE="blurry, lowres, jpeg artifacts, watermark, signature, text overlay, logo, deformed hands, extra fingers, extra limbs, bad anatomy, crossed eyes, oversaturated, plastic skin, cropped subject"
fi

# Düzenleme modunda nihai çıktıya seçilen renk efekti uygulanır (katalog yukarıda).
EFEKT_FILTRE=''
EFEKT_ADI="efektsiz"
if [[ "$ISLEM" == "2" ]]; then
  gorsel_bolum "EFEKTLER"
  print "${RENK_SOLUK}Instagram'ın en popüler filtreleri + VSCO/film tarzı ve sinematik derecelerin yerel yaklaştırmaları. Tümünü tek seferde basmak için İşlem 3'ü kullanın.${RENK_SIFIR}"
  print "  0) Efekt yok          fotoğraf olduğu gibi kalsın"
  print "  1) Clarendon tarzı    Instagram #1: kontrast + canlı, hafif soğuk"
  print "  2) Valencia tarzı     sıcak sarı ışık, yumuşak gölgeler, nostaljik"
  print "  3) Gingham tarzı      soluk renkler, pastel vintage"
  print "  4) Juno tarzı         zengin sıcak tonlar, derin gölgeler"
  print "  5) Lark tarzı         aydınlık, pastel, editoryal"
  print "  6) Sinematik          teal-turuncu film derecesi, vinyet"
  print "  7) Film / Portra      yumuşak sıcak film, kalkık siyahlar"
  print "  8) Siyah-beyaz        klasik monokrom, güçlü kontrast"
  print "  9) VSCO A6 tarzı      temiz, aydınlık, sade — premium paket klasiği"
  print " 10) VSCO C1 tarzı      canlı ve doygun, enerjik"
  print " 11) VSCO M5 tarzı      mat, soluk yeşil-kahve — moody"
  print " 12) Kodak Ektar        doygun film, parlak kırmızılar"
  print " 13) Altın saat         sıcak gün batımı parlaması"
  print " 14) Film noir          yüksek kontrast soğuk monokrom"
  while true; do
    print -n "Efekt (0-14, varsayılan 0): "
    read -r EFEKT
    EFEKT="${EFEKT:-0}"
    case "$EFEKT" in
      0|1|2|3|4|5|6|7|8|9|10|11|12|13|14) break ;;
      *) print -u2 "Geçersiz seçim: 0-14 arası girin." ;;
    esac
  done
  if [[ "$EFEKT" != "0" ]]; then
    EFEKT_ADI="${EFEKT_SIRASI[$EFEKT]}"
    EFEKT_FILTRE="${EFEKT_LISTESI[$EFEKT_ADI]}"
  fi
fi

gorsel_bolum "SEÇENEKLER"
# Sabit seed her üretimi birebir aynı yapar; rastgele seed çeşitlilik sağlar.
# Yeniden üretilebilirlik isteyenler aynı seed'i elle verebilir.
while true; do
  print -n "Seed (boş = rastgele): "
  read -r SEED_GIRIS
  if [[ -z "${SEED_GIRIS//[[:space:]]/}" ]]; then
    SEED=-1
    SEED_GOSTERIM="rastgele"
    break
  elif [[ "$SEED_GIRIS" =~ ^[0-9]+$ ]]; then
    SEED="$SEED_GIRIS"
    SEED_GOSTERIM="$SEED_GIRIS"
    break
  fi
  print -u2 "Seed sayı olmalıdır (veya boş bırakın)."
done

# LoRA seçimi: loras klasöründeki tüm .safetensors dosyalarını listeler.
# Yalnız doğrulanabilir ve yetişkin içerik olarak işaretlenmemiş metadata kabul edilir.
LORA_ARGS=()
LORA_GOSTERIM="kapalı"
typeset -a LORA_LISTESI LORA_YOLLARI LORA_DURUMLARI
LORA_LISTESI=()
LORA_YOLLARI=()
LORA_DURUMLARI=()

if [[ -d "$LORA_DIR" ]]; then
  # Boşluklu dosya adlarını doğru yakalamak için null-delimited + while read
  while IFS= read -r -d '' f; do
    [[ "$(lora_guvenli "$f")" == "GUVENLI" ]] || continue
    LORA_YOLLARI+=("$f")
    LORA_LISTESI+=("${f:t}")
    LORA_DURUMLARI+=("$(lora_guvenli "$f")")
  done < <(find "$LORA_DIR" -maxdepth 1 -type f -name "*.safetensors" -print0 2>/dev/null | sort -z)
fi

if (( ${#LORA_LISTESI[@]} > 0 )); then
  print
  print "${RENK_SOLUK}Mevcut LoRA dosyaları:${RENK_SIFIR}"
  print "  0) LoRA kullanma (kapalı)"
  for i in {1..${#LORA_LISTESI[@]}}; do
    DURUM_ETIKET=""
    [[ "${LORA_DURUMLARI[$i]}" == "NSFW" ]] && DURUM_ETIKET=" ${RENK_SOLUK}[NSFW metadata]${RENK_SIFIR}"
    [[ "${LORA_DURUMLARI[$i]}" == "HATA" ]] && DURUM_ETIKET=" ${RENK_SOLUK}[metadata okunamadı]${RENK_SIFIR}"
    print "  $i) ${LORA_LISTESI[$i]}$DURUM_ETIKET"
  done
  while true; do
    print -n "LoRA seç (0-${#LORA_LISTESI[@]}, varsayılan 0): "
    read -r LORA_SECIM
    LORA_SECIM="${LORA_SECIM:-0}"
    if [[ "$LORA_SECIM" == "0" ]]; then
      break
    elif [[ "$LORA_SECIM" =~ ^[0-9]+$ ]] && (( LORA_SECIM >= 1 && LORA_SECIM <= ${#LORA_LISTESI[@]} )); then
      SECILEN_LORA_YOL="${LORA_YOLLARI[$LORA_SECIM]}"
      SECILEN_LORA_AD="${LORA_LISTESI[$LORA_SECIM]}"
      # Dosya adından uzantıyı ve boşlukları temizleyerek <lora:...> etiketi için isim üret
      LORA_TRIGGER_AD="${SECILEN_LORA_AD%.safetensors}"
      # Keep the actual filename; spaces are supported inside the quoted prompt.
      while true; do
        print -n "LoRA gücü (0.1–1.5, varsayılan 0.8): "
        read -r LORA_GUCU
        LORA_GUCU="${LORA_GUCU:-0.8}"
        [[ "$LORA_GUCU" =~ ^[0-9]+([.][0-9]+)?$ ]] && (( LORA_GUCU >= 0.1 && LORA_GUCU <= 1.5 )) && break
        print -u2 "LoRA gücü 0.1 ile 1.5 arasında olmalıdır (örnek: 0.8)."
      done
      # Prompt'a LoRA trigger ekle + sd-cli'ye dizin ver
      PROMPT="$PROMPT <lora:${LORA_TRIGGER_AD}:${LORA_GUCU}>"
      LORA_ARGS=(--lora-model-dir "$LORA_DIR" --lora-apply-mode at_runtime)
      LORA_GOSTERIM="${SECILEN_LORA_AD} @ ${LORA_GUCU}"
      break
    else
      print -u2 "Geçersiz seçim: 0-${#LORA_LISTESI[@]} arası girin."
    fi
  done
else
  print "${RENK_SOLUK}LoRA klasöründe .safetensors dosyası bulunamadı: $LORA_DIR${RENK_SIFIR}"
fi

STAMP="$(date +%Y%m%d-%H%M%S)"
# Tek çıktı: ham üretim geçici adla üretilir, Instagram ölçeğine alınınca ham dosya
# silinir. Kullanıcıya yalnız nihai tek dosya kalır (önceki çift çıktı karmaşası yok).
EFEKT_EK=''
[[ -n "$EFEKT_FILTRE" ]] && EFEKT_EK="-$EFEKT_ADI"
OUTPUT="$OUTPUT_DIR/qwen-image-$STAMP-$KANVAS_ADI-$STIL_ADI-$KALITE_ADI$EFEKT_EK.png"
HAM_OUTPUT="$OUTPUT_DIR/.ham-qwen-image-$STAMP.png"
LOG_FILE="$LOG_DIR/qwen-image-$STAMP.log"

BETIM_GOSTERIM="${USER_PROMPT:0:56}"
(( ${#USER_PROMPT} > 56 )) && BETIM_GOSTERIM="${BETIM_GOSTERIM}…"
print
gorsel_kart "ÖZET VE ONAY"
gorsel_satir "İşlem: $ISLEM_ADI  •  kanvas: $KANVAS_ADI (${WIDTH}×${HEIGHT} → ${FINAL_WIDTH}×${FINAL_HEIGHT})"
gorsel_satir "Kalite: $KALITE_ADI ($STEPS adım)  •  stil: $STIL_ADI  •  seed: $SEED_GOSTERIM  •  LoRA: $LORA_GOSTERIM"
gorsel_satir "Betim: $BETIM_GOSTERIM"
[[ -n "$EFEKT_FILTRE" ]] && gorsel_satir "Efekt: $EFEKT_ADI  •  renk filtresi nihai çıktıya uygulanacak"
printf '%s╰%s╯%s\n' "$RENK_AKSAN" "${(l:70::─:)${:-}}" "$RENK_SIFIR"
print -n "Onaylıyor musun? (E = üret, h = iptal): "
read -r ONAY
if [[ "$ONAY" == "h" || "$ONAY" == "H" ]]; then
  print "Üretim iptal edildi."
  exit 0
fi

print
gorsel_kart "GÖRSEL HAZIRLANIYOR"
gorsel_satir "$KANVAS_ADI  •  ${WIDTH}×${HEIGHT}  •  $STEPS adım  •  stil: $STIL_ADI"
gorsel_satir "Türkçe niyet + profesyonel stil yönergesi + kalite negatifi uygulanıyor."
[[ -n "$EFEKT_FILTRE" ]] && gorsel_satir "Efekt: $EFEKT_ADI  •  ölçekleme sonrası renk filtresi uygulanacak"
printf '%s╰%s╯%s\n' "$RENK_AKSAN" "${(l:70::─:)${:-}}" "$RENK_SIFIR"

# Bu modelde CPU offload denendiğinde Apple Silicon'da adım ilerlemesi kilitlenebildi.
# Metal auto-fit, M4'ün birleşik belleğini doğru bileşen önceliğiyle kullanır;
# bu nedenle model özellikle Metal'de bırakılır. Büyük çözünürlükler bilinçli
# olarak varsayılan yapılmaz.
bozkurt_sunucuyu_durdur
"$SD_CLI" \
  --diffusion-model "$DIFFUSION_MODEL" \
  --vae "$VAE_MODEL" \
  --llm "$TEXT_ENCODER" \
  "${EDIT_ARGS[@]}" \
  "${BACKEND_ARGS[@]}" \
  "${LORA_ARGS[@]}" \
  --cfg-scale 6.0 \
  --sampling-method euler \
  --steps "$STEPS" \
  --seed "$SEED" \
  --negative-prompt "$NEGATIVE" \
  --width "$WIDTH" \
  --height "$HEIGHT" \
  --diffusion-fa \
  --vae-tiling \
  --vae-tile-size 64x64 \
  --prompt "$PROMPT" \
  --output "$HAM_OUTPUT" >"$LOG_FILE" 2>&1 &
GEN_PID=$!

temizle() {
  if kill -0 "$GEN_PID" 2>/dev/null; then
    kill -TERM "$GEN_PID" 2>/dev/null || true
    wait "$GEN_PID" 2>/dev/null || true
  fi
  print "\n${RENK_SOLUK}Üretim durduruldu. Teknik günlük: $LOG_FILE${RENK_SIFIR}"
  exit 130
}
trap temizle INT TERM

SPINNER=("◐" "◓" "◑" "◒")
INDEX=1
SURE=0
while kill -0 "$GEN_PID" 2>/dev/null; do
  if grep -q "generating image" "$LOG_FILE" 2>/dev/null; then
    ASAMA="Görsel çiziliyor"
  elif grep -q "get_learned_condition completed" "$LOG_FILE" 2>/dev/null; then
    ASAMA="Sahne ve prompt işleniyor"
  elif grep -q "auto-fit plan" "$LOG_FILE" 2>/dev/null; then
    ASAMA="Metal bellek planı hazırlanıyor"
  else
    ASAMA="Model bileşenleri yükleniyor"
  fi
  printf '\r%s %s  %s  %02d:%02d' "$RENK_AKSAN" "${SPINNER[$INDEX]}" "$ASAMA" $((SURE / 60)) $((SURE % 60))
  INDEX=$((INDEX % ${#SPINNER[@]} + 1))
  sleep 2
  SURE=$((SURE + 2))
done
print
if ! wait "$GEN_PID"; then
  trap - INT TERM
  print -u2 "${RENK_SOLUK}Üretim tamamlanamadı. Teknik günlük: $LOG_FILE${RENK_SIFIR}"
  exit 1
fi
trap - INT TERM

if [[ -s "$HAM_OUTPUT" ]]; then
  # Final dosya Instagram'ın tam piksel ölçüsündedir. Lanczos ölçekleme ve hafif
  # unsharp filtre görüntüye yapay ayrıntı eklemez; küçüklükten gelen yumuşamayı
  # bastırır. Seçilen renk efekti aynı ffmpeg zincirinin sonuna eklenir; böylece
  # tek geçişte hem ölçeklenir hem derecelenir. Ölçekleme sonrası ham dosya
  # silinir; kullanıcıya tek çıktı kalır.
  OLC_VF="scale=${FINAL_WIDTH}:${FINAL_HEIGHT}:flags=lanczos,unsharp=5:5:0.35:5:5:0.0"
  [[ -n "$EFEKT_FILTRE" ]] && OLC_VF="${OLC_VF},${EFEKT_FILTRE}"
  if command -v ffmpeg >/dev/null 2>&1; then
    if ffmpeg -nostdin -y -hide_banner -loglevel error -i "$HAM_OUTPUT" \
      -vf "$OLC_VF" \
      -frames:v 1 "$OUTPUT" >>"$LOG_FILE" 2>&1; then
      rm -f "$HAM_OUTPUT"
    else
      print -u2 "Ölçekleme/efekt başarısız; ham görsel korunuyor: $HAM_OUTPUT"
      exit 1
    fi
  else
    cp "$HAM_OUTPUT" "$OUTPUT"
    sips -z "$FINAL_HEIGHT" "$FINAL_WIDTH" "$OUTPUT" >>"$LOG_FILE" 2>&1 || true
    rm -f "$HAM_OUTPUT"
    [[ -n "$EFEKT_FILTRE" ]] && print "${RENK_SOLUK}Not: ffmpeg bulunamadığı için renk efekti uygulanamadı; görsel yalnız ölçeklendi.${RENK_SIFIR}"
  fi
  print
  gorsel_kart "✓ GÖRSEL HAZIR"
  gorsel_satir "Çıktı: $OUTPUT"
  gorsel_satir "Teknik günlük: $LOG_FILE"
  printf '%s╰%s╯%s\n' "$RENK_BASARI" "${(l:70::─:)${:-}}" "$RENK_SIFIR"
  open -R "$OUTPUT"
else
  print -u2 "Görsel dosyası oluşturulamadı. Teknik günlük: $LOG_FILE"
  exit 1
fi
