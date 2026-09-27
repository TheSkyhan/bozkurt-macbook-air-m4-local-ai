#!/usr/bin/env python3
# Explicit city or user-configured coordinates only.
import json, os, re, subprocess, sys, urllib.parse, urllib.request

ROOT = str(__import__("pathlib").Path(__file__).resolve().parents[1])
UA = {"User-Agent": "Bozkurt/1.0"}
sure = (sys.argv[1] if len(sys.argv) > 1 else "bugun").strip().lower().replace("bu ", "bu_")
sure = sure.translate(str.maketrans("ıüğşöç", "iugsoc"))
sure = re.sub(r"\s+", "_", sure)
sure = {"bugun_hava": "bugun", "yarin_hava": "yarin", "haftalik": "hafta"}.get(sure, sure)
if sure in ("hafta", "haftalik", "bu_hafta", "7gun", "7_gun", "haftanin_havasi"):
    gun_sayisi, cok_gun = 7, True
else:
    mnum = re.match(r"^(\d+)\s*_?gun", sure)
    if mnum:
        gun_sayisi, cok_gun = min(max(int(mnum.group(1)), 1), 14), True
    elif sure in ("bugun", "yarin"):
        gun_sayisi, cok_gun = (1 if sure == "bugun" else 2), False
    else:
        sure, gun_sayisi, cok_gun = "bugun", 1, False

# Kullanıcının yazdığı şehir/ilçe (varsa) — argv[2]. Verilirse geocoding ile koordinat alınır,
# verilmezse aşağıdaki otomatik konum zincirine (env/kısayol/config/IP) düşülür.
sehir_istenen = (sys.argv[2] if len(sys.argv) > 2 else "").strip()


def _konum_config():
    cfg = os.path.join(ROOT, "yapilandirma", "konum.conf")
    if not os.path.isfile(cfg):
        return None
    vals = {}
    for line in open(cfg, encoding="utf-8"):
        line = line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        k, v = line.split("=", 1)
        vals[k.strip().upper()] = v.strip()
    if vals.get("LAT") and vals.get("LON"):
        try:
            return float(vals["LAT"]), float(vals["LON"]), vals.get("SEHIR", "")
        except Exception:
            return None
    return None


def _sehir_koordinat(ad):
    """Kullanıcının yazdığı şehir/ilçe adını open-meteo geocoding ile koordinata çevirir."""
    url = "https://geocoding-api.open-meteo.com/v1/search?" + urllib.parse.urlencode(
        {"name": ad, "count": 1, "language": "tr", "format": "json"})
    with urllib.request.urlopen(urllib.request.Request(url, headers=UA), timeout=15) as r:
        d = json.load(r)
    res = d.get("results") or []
    if not res:
        raise RuntimeError(f"'{ad}' adlı bir konum bulunamadı.")
    g = res[0]
    ad_coz = ", ".join(x for x in [g.get("name"), g.get("admin1")] if x)
    return float(g["latitude"]), float(g["longitude"]), ad_coz, "kullanici-sehir"


def konum_al():
    lat = os.environ.get("BOZKURT_KONUM_LAT")
    lon = os.environ.get("BOZKURT_KONUM_LON")
    if lat and lon:
        return float(lat), float(lon), os.environ.get("BOZKURT_KONUM_SEHIR", "manuel"), "manuel"
    c = _konum_config()
    if c:
        return c[0], c[1], c[2], "config"
    raise RuntimeError("Şehir belirtin veya yerel konum ayarını kendiniz yapılandırın.")


try:
    if sehir_istenen:
        lat, lon, sehir, yontem = _sehir_koordinat(sehir_istenen)
    else:
        lat, lon, sehir, yontem = konum_al()
except Exception as e:
    raise SystemExit("Konum alınamadı: " + str(e))

q = urllib.parse.urlencode({
    "latitude": lat, "longitude": lon, "timezone": "auto", "forecast_days": gun_sayisi,
    "daily": "weather_code,temperature_2m_max,temperature_2m_min,"
             "precipitation_probability_max,precipitation_sum"})
url = "https://api.open-meteo.com/v1/forecast?" + q
with urllib.request.urlopen(urllib.request.Request(url, headers=UA), timeout=20) as r:
    d = json.load(r)

w = {0: "açık", 1: "çoğunlukla açık", 2: "parçalı bulutlu", 3: "kapalı", 45: "sisli",
     48: "kırağılı sis", 51: "hafif çisenti", 53: "çisentili", 55: "yoğun çisenti",
     61: "hafif yağmurlu", 63: "yağmurlu", 65: "kuvvetli yağmurlu", 66: "donan yağmur",
     67: "kuvvetli donan yağmur", 71: "hafif karlı", 73: "karlı", 75: "yoğun karlı",
     77: "kar taneli", 80: "hafif sağanak", 81: "sağanak yağışlı", 82: "kuvvetli sağanak",
     85: "hafif kar sağanağı", 86: "kar sağanağı", 95: "gök gürültülü sağanak",
     96: "dolulu gök gürültülü sağanak", 99: "kuvvetli dolu sağanak"}
z = d["daily"]
taban = {"sehir": sehir, "konum_yontemi": yontem, "koordinat": [round(lat, 5), round(lon, 5)],
         "sure": sure, "kaynak": url}

if cok_gun:
    gunlukler = [{
        "gun": z["time"][j],
        "durum": w.get(z["weather_code"][j], str(z["weather_code"][j])),
        "en_dusuk_c": z["temperature_2m_min"][j], "en_yuksek_c": z["temperature_2m_max"][j],
        "yagis_olasiligi_yuzde": z["precipitation_probability_max"][j],
        "yagis_mm": z["precipitation_sum"][j],
    } for j in range(len(z["time"]))]
    taban["gunlukler"] = gunlukler
    print(json.dumps(taban, ensure_ascii=False, indent=2))
else:
    i = 0 if sure == "bugun" else 1
    taban.update({
        "gun": z["time"][i],
        "durum": w.get(z["weather_code"][i], str(z["weather_code"][i])),
        "en_dusuk_c": z["temperature_2m_min"][i], "en_yuksek_c": z["temperature_2m_max"][i],
        "yagis_olasiligi_yuzde": z["precipitation_probability_max"][i],
        "yagis_mm": z["precipitation_sum"][i]})
    print(json.dumps(taban, ensure_ascii=False, indent=2))
