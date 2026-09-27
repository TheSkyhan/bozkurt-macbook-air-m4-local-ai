#!/usr/bin/env python3
# web_arama aracı: Google otomatik istekleri captcha'ya düşürdüğü için
# scraper-dostu DuckDuckGo HTML uç noktası kullanılır (yedek: lite + Bing).
# Çıktı sözleşmesi korunur: {"sorgu","kaynak","sonuclar":[{baslik,url}]}
import base64, html, json, re, sys, urllib.parse, urllib.request

UA = {"User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) "
                    "AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0 Safari/537.36",
      "Accept-Language": "tr-TR,tr;q=0.9,en;q=0.8"}

q = " ".join(sys.argv[1:]).strip()
if not q:
    raise SystemExit("Kullanım: google_arama.py <sorgu>")


def fetch(url, timeout=12):
    req = urllib.request.Request(url, headers=UA)
    with urllib.request.urlopen(req, timeout=timeout) as r:
        return r.read(2_000_000).decode("utf-8", "replace")


def clean_title(t):
    return re.sub(r"\s+", " ", re.sub(r"<.*?>", "", html.unescape(t))).strip()


def ddg_unwrap(href):
    # DuckDuckGo sonuç bağlantıları /l/?uddg=<urlencoded> yönlendirmesidir.
    if "uddg=" in href:
        enc = urllib.parse.urlparse(href).query or href.split("?", 1)[-1]
        for kv in enc.split("&"):
            if kv.startswith("uddg="):
                return urllib.parse.unquote(kv[5:])
    return href


def from_duckduckgo(query, endpoint):
    url = endpoint + "?" + urllib.parse.urlencode({"q": query, "kl": "tr-tr"})
    page = fetch(url)
    items = []
    pat = r'<a[^>]+class="(?:result__a|result-link)"[^>]+href="([^"]+)"[^>]*>(.*?)</a>'
    for href, title in re.findall(pat, page, re.S):
        u = ddg_unwrap(html.unescape(href))
        t = clean_title(title)
        if t and u.startswith("http") and "duckduckgo." not in urllib.parse.urlparse(u).netloc:
            items.append({"baslik": t, "url": u})
    return items


def from_bing(query):
    url = "https://www.bing.com/search?" + urllib.parse.urlencode({"q": query, "setlang": "tr", "count": 10})
    page = fetch(url)
    items = []
    for block in re.findall(r'<li class="b_algo".*?</li>', page, re.S):
        m = re.search(r'<h2[^>]*>\s*<a[^>]+href="([^"]+)"[^>]*>(.*?)</a></h2>', block, re.S)
        if not m:
            continue
        u, t = html.unescape(m.group(1)), clean_title(m.group(2))
        if urllib.parse.urlparse(u).hostname in ("www.bing.com", "bing.com"):
            encoded = urllib.parse.parse_qs(urllib.parse.urlparse(u).query).get("u", [""])[0]
            if encoded.startswith("a1"):
                try:
                    payload = encoded[2:]
                    u = base64.urlsafe_b64decode(payload + "=" * (-len(payload) % 4)).decode("utf-8")
                except (ValueError, UnicodeError):
                    continue
        if t and u.startswith("http") and "bing." not in urllib.parse.urlparse(u).netloc:
            items.append({"baslik": t, "url": u})
    return items


sonuclar, kaynak = [], None
for fn, name in (
    (lambda: from_duckduckgo(q, "https://html.duckduckgo.com/html/"), "DuckDuckGo"),
    (lambda: from_duckduckgo(q, "https://lite.duckduckgo.com/lite/"), "DuckDuckGo Lite"),
    (lambda: from_bing(q), "Bing"),
):
    try:
        sonuclar = fn()
    except Exception:
        sonuclar = []
    if sonuclar:
        kaynak = name
        break

out = {"sorgu": q, "kaynak": kaynak or "yok", "sonuclar": sonuclar[:8]}
if not sonuclar:
    out["uyari"] = ("Hiçbir arama motorundan sonuç alınamadı (ağ erişimi yok veya motorlar "
                    "otomatik isteği engelledi). Sonuç uydurma; kullanıcıya web aramasının "
                    "şu an kullanılamadığını söyle.")
print(json.dumps(out, ensure_ascii=False, indent=2))
