#!/bin/zsh
# Yalnızca Bozkurt'un yerel model portunu güvenli biçimde yönetir.

bozkurt_sunucuyu_durdur() {
  local pids pid command
  if pgrep -f '[q]wen-image-backend/build-metal/bin/sd-cli' >/dev/null 2>&1; then
    print -u2 "Qwen Image üretimi sürüyor. 16 GB bellekte ikinci model açılmaz; üretimin bitmesini bekleyin."
    return 1
  fi
  pids="$(lsof -ti TCP:8080 -sTCP:LISTEN 2>/dev/null || true)"
  [[ -z "$pids" ]] && return 0

  for pid in ${(f)pids}; do
    command="$(ps -p "$pid" -o command= 2>/dev/null || true)"
    # 8080 yaygın bir geliştirme portudur. Bozkurt, başka bir uygulamanın
    # sunucusunu kapatmamalıdır; yalnız kendi yerel model süreçlerini yönetir.
    if [[ "$command" != *"llama-server"* || ( "$command" != *"$BOZKURT_ROOT"* ) ]]; then
      print -u2 "8080 portu Bozkurt'a ait olmayan bir süreç tarafından kullanılıyor (PID $pid). Önce o süreci kapatın veya başka port kullanın."
      return 1
    fi
    kill -TERM "$pid" 2>/dev/null || true
  done

  # Metal arka ucu kapanışta kaynaklarını serbest bırakabilsin diye bekle.
  # Aktif üretimde beş saniye bazen yetmez; ikinci kesme Metal tarafında
  # güvenli olmayan kapanışa yol açabildiği için son çareyi geciktiriyoruz.
  for _ in {1..120}; do
    lsof -ti TCP:8080 -sTCP:LISTEN >/dev/null 2>&1 || return 0
    sleep 0.25
  done

  # Sadece portu hâlâ tutan, doğrulanmış PID'ler için son çare.
  pids="$(lsof -ti TCP:8080 -sTCP:LISTEN 2>/dev/null || true)"
  for pid in ${(f)pids}; do
    command="$(ps -p "$pid" -o command= 2>/dev/null || true)"
    if [[ "$command" == *"llama-server"* && "$command" == *"$BOZKURT_ROOT/"* ]]; then
      kill -KILL "$pid" 2>/dev/null || true
    else
      print -u2 "Portun sahibi değişti; yeni sürece dokunulmadı."
      return 1
    fi
  done
}
