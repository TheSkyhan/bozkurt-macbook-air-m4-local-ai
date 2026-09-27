#!/usr/bin/env python3
# pdf_uret aracı (v3): Markdown/HTML makale içeriğini A4, DERGİ düzeninde PDF'e
# çevirir. Motor önceliği: WeasyPrint (.venv-pdf; sayfa numarası + koşan başlık)
# → Chrome headless → cupsfilter düz-metin yedeği. Uzaktaki görseller indirilip gömülür.
# Tek parametre: JSON spec (argv[1]).
import html, json, os, re, shutil, subprocess, sys, tempfile, urllib.parse, urllib.request
from pathlib import Path

ROOT = str(__import__("pathlib").Path(__file__).resolve().parents[1])

CHROME_CANDIDATES = [
    "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",
    "/Applications/Chromium.app/Contents/MacOS/Chromium",
    "/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge",
]
UA = {"User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 Chrome/124 Safari/537.36"}


def chrome_yolu():
    for c in CHROME_CANDIDATES:
        if os.path.exists(c):
            return c
    return shutil.which("google-chrome") or shutil.which("chromium") or None


def md_to_html(md: str) -> str:
    """Küçük, güvenli Markdown→HTML (başlık, paragraf, liste, alıntı, görsel, kalın/italik)."""
    md = md.replace("\r\n", "\n").replace("\r", "\n")
    out, in_ul = [], False

    def inline(s):
        s = re.sub(r"!\[([^\]]*)\]\(([^)\s]+)[^)]*\)",
                   lambda m: f"<figure><img src=\"{m.group(2).strip()}\" "
                             f"alt=\"{html_escape(m.group(1))}\">"
                             + (f"<figcaption>{html_escape(m.group(1))}</figcaption>" if m.group(1).strip() else "")
                             + "</figure>", s)
        s = re.sub(r"\[([^\]]+)\]\(([^)\s]+)[^)]*\)", lambda m: f"<a href=\"{m.group(2).strip()}\">{html_escape(m.group(1))}</a>", s)
        s = re.sub(r"\*\*(.+?)\*\*", r"<strong>\1</strong>", s)
        s = re.sub(r"(?<!\*)\*(?!\s)(.+?)(?<!\s)\*(?!\*)", r"<em>\1</em>", s)
        s = re.sub(r"`([^`]+)`", r"<code>\1</code>", s)
        return s

    def html_escape(t):
        return (t.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;"))

    def close_ul():
        nonlocal in_ul
        if in_ul:
            out.append("</ul>"); in_ul = False

    for block in re.split(r"\n\s*\n", md):
        for line in block.split("\n"):
            l = line.rstrip()
            if not l.strip():
                continue
            if re.match(r"^!\[.*\]\(.*\)\s*$", l.strip()):  # tek başına görsel
                close_ul(); out.append(inline(l.strip())); continue
            m = re.match(r"^(#{1,4})\s+(.*)$", l)
            if m:
                close_ul(); lvl = len(m.group(1)); out.append(f"<h{lvl}>{inline(html_escape(m.group(2)))}</h{lvl}>"); continue
            if re.match(r"^(---|\*\*\*)\s*$", l):
                close_ul(); out.append("<hr>"); continue
            if re.match(r"^>\s?", l):
                close_ul(); q = re.sub(r"^>\s?", "", l); out.append(f"<blockquote>{inline(html_escape(q))}</blockquote>"); continue
            if re.match(r"^\s*[-*+]\s+", l):
                if not in_ul:
                    out.append("<ul>"); in_ul = True
                item = re.sub(r"^\s*[-*+]\s+", "", l); out.append(f"<li>{inline(html_escape(item))}</li>"); continue
            close_ul(); out.append(f"<p>{inline(html_escape(l))}</p>")
    close_ul()
    return "\n".join(out)


def commons_gorsel(kelime: str) -> str:
    """Wikimedia Commons API'sinden anahtar kelimeye ait ilk uygun görselin doğrudan
    URL'sini döndürür (serbest/alaçatılı içerik). Bulunamazsa boş dize."""
    try:
        q = urllib.parse.urlencode({
            "action": "query", "format": "json", "generator": "search",
            "gsrsearch": f"filetype:bitmap {kelime}", "gsrnamespace": "6", "gsrlimit": "6",
            "prop": "imageinfo", "iiprop": "url|mime|size", "iiurlwidth": "1200",
        })
        req = urllib.request.Request("https://commons.wikimedia.org/w/api.php?" + q,
                                     headers={**UA, "Accept": "application/json"})
        with urllib.request.urlopen(req, timeout=25) as r:
            data = json.load(r)
        pages = sorted((data.get("query", {}).get("pages", {}) or {}).values(),
                       key=lambda p: p.get("index", 99))
        for p in pages:
            for info in p.get("imageinfo", []) or []:
                mime = info.get("mime", "")
                if mime in ("image/jpeg", "image/png", "image/webp"):
                    url = info.get("thumburl") or info.get("url")
                    if url:
                        return url
    except Exception:
        pass
    return ""


def gorsel_isaretlerini_ac(govde: str) -> str:
    """Metindeki [görsel: anahtar kelime] işaretlerini gerçek Commons görsellerine çevirir."""
    def repl(m):
        kelime = m.group(1).strip()
        url = commons_gorsel(kelime)
        if url:
            return f"\n![{kelime}]({url})\n"
        return ""  # bulunamadı: işareti sessizce kaldır
    return re.sub(r"\[g[öo]rsel:\s*([^\]]+)\]", repl, govde, flags=re.I)


def gorselleri_indir(html: str, tmpdir: str) -> str:
    """<img src=http(s)://...> dosyalarını indirip file:// yollarıyla değiştirir."""
    def repl(m):
        src = m.group(1)
        if src.startswith("data:") or src.startswith("file://"):
            return m.group(0)
        try:
            if src.startswith("http://") or src.startswith("https://"):
                h = re.sub(r"[^A-Za-z0-9.]", "_", urllib.parse.urlparse(src).path.split("/")[-1]) or "img"
                hedef = os.path.join(tmpdir, h)
                with urllib.request.urlopen(urllib.request.Request(src, headers=UA), timeout=25) as r:
                    data = r.read()
                with open(hedef, "wb") as f:
                    f.write(data)
                return m.group(0).replace(m.group(1), "file://" + hedef)
            if not src.startswith("/"):
                src = os.path.abspath(src)
            return m.group(0).replace(m.group(1), "file://" + src)
        except Exception:
            return m.group(0)  # indirilemezse orijinal bırak (Chrome ağdan çekmeyi dener)
    return re.sub(r'<img[^>]+src="([^"]+)"', repl, html)


CSS = """
@page { size: A4; margin: 16mm 15mm 18mm 15mm; @bottom-center { content: string(baslik) "  ·  sayfa " counter(page) " / " counter(pages); font: 9px Helvetica, Arial, sans-serif; color: #999; } }
* { box-sizing: border-box; }
html,body{margin:0;padding:0;color:#1a1a1a;font-family:Georgia,'Times New Roman',serif;}
.masthead{border-bottom:3px solid #b5482d;padding-bottom:8px;margin-bottom:6px;}
.kulak{font-family:Helvetica,Arial,sans-serif;font-size:10px;letter-spacing:2px;text-transform:uppercase;color:#b5482d;margin:0 0 6px;}
h1.baslik{font-size:33px;line-height:1.08;margin:0 0 8px;font-weight:800;string-set:baslik content();}
.spot{font-size:15px;line-height:1.4;font-style:italic;color:#444;margin:0 0 6px;}
.byline{font-family:Helvetica,Arial,sans-serif;font-size:11px;color:#666;border-top:1px solid #ddd;padding-top:6px;margin-bottom:12px;}
.govde{column-count:COLUMN_KAC;column-gap:9mm;column-rule:1px solid #e2e2e2;font-size:12.5px;line-height:1.55;text-align:justify;hyphens:auto;}
.govde p{margin:0 0 9px;}
.govde h2{font-size:16px;margin:14px 0 6px;color:#b5482d;break-after:avoid;}
.govde h3{font-size:13.5px;margin:10px 0 4px;break-after:avoid;}
.govde p:first-of-type::first-letter{font-size:34px;line-height:1.1;color:#b5482d;font-weight:800;}
figure{margin:10px 0;break-inside:avoid;}
figure img{width:100%;height:auto;border:1px solid #eee;border-radius:3px;}
figcaption{font-family:Helvetica,Arial,sans-serif;font-size:9.5px;color:#777;margin-top:4px;font-style:italic;}
blockquote{margin:12px 0;padding:6px 12px;border-left:4px solid #b5482d;background:#faf3ef;font-style:italic;color:#333;break-inside:avoid;}
ul{margin:0 0 9px;padding-left:18px;}
li{margin-bottom:3px;}
hr{border:none;border-top:1px solid #ddd;margin:12px 0;}
a{color:#1a5fb4;text-decoration:none;}
.footer{position:fixed;bottom:6mm;left:15mm;right:15mm;text-align:center;font-family:Helvetica,Arial,sans-serif;font-size:9px;color:#999;border-top:1px solid #eee;padding-top:4px;}
"""

HTML_ISKELET = """<!doctype html><html lang="tr"><head><meta charset="utf-8"><style>{css}</style></head>
<body>
<div class="masthead">
  <p class="kulak">{kulak}</p>
  <h1 class="baslik">{baslik}</h1>
  {spot_html}
</div>
<div class="byline">{byline}</div>
<div class="govde">{govde}</div>
</body></html>"""


def main():
    spec = json.loads(sys.argv[1]) if len(sys.argv) > 1 and sys.argv[1].strip() else {}
    baslik = (spec.get("baslik") or "Belge").strip()
    govde = spec.get("govde") or spec.get("icerik") or ""
    govde_dosya = (spec.get("govde_dosya") or "").strip()
    if govde_dosya and not Path(govde_dosya).resolve().is_relative_to(Path.cwd().resolve()):
        raise SystemExit("Gövde dosyası mevcut çalışma alanı içinde olmalıdır.")
    if os.environ.get("BOZKURT_WEB_DISABLED") == "1":
        if re.search(r"https?://|\[görsel:", govde, re.I):
            raise SystemExit("Bu mod çevrimdışı: uzak görsel veya web kaynağı olmadan belge oluşturun.")
    if not govde.strip() and govde_dosya and os.path.isfile(govde_dosya):
        with open(govde_dosya, encoding="utf-8") as f:
            govde = f.read()
    if not govde.strip():
        raise SystemExit("Hata: makale içeriği boş (govde veya govde_dosya ver).")
    spot = (spec.get("spot") or "").strip()
    yazar = (spec.get("yazar") or "").strip()
    tarih = (spec.get("tarih") or "").strip()
    kulak = (spec.get("kulak") or "BOZKURT • ARAŞTIRMA").strip()
    kolon = spec.get("kolon", 2)
    kolon = 1 if str(kolon) in ("1", "tek", "single") else 2
    try:
        hedef_sayfa = int(spec.get("hedef_sayfa")) if spec.get("hedef_sayfa") else None
    except Exception:
        hedef_sayfa = None

    dosya = re.sub(r"[^\w\-. ]", "", (spec.get("dosya") or "makale")).strip().replace(" ", "-") or "makale"
    if not dosya.lower().endswith(".pdf"):
        dosya += ".pdf"

    if os.environ.get("BOZKURT_WEB_DISABLED") == "1" and re.search(r"https?://|\[görsel:", govde, re.I):
        raise SystemExit("Bu mod çevrimdışı: uzak kaynak içeren gövde kullanılamaz.")
    govde = gorsel_isaretlerini_ac(govde)
    body = govde if re.search(r"<(p|h[1-6]|div|img|figure|ul)\b", govde, re.I) else md_to_html(govde)
    cwd = os.getcwd()
    cikti_dizin = cwd if os.access(cwd, os.W_OK) else os.path.expanduser("~/Desktop")
    os.makedirs(cikti_dizin, exist_ok=True)
    tmpdir = tempfile.mkdtemp(prefix="pdfuret-")

    try:
        body = gorselleri_indir(body, tmpdir)
        byline = " · ".join(x for x in (yazar, tarih) if x) or (yazar or tarih or "")
        venv_py = os.path.join(ROOT, ".venv-pdf", "bin", "python")
        wp = os.path.join(ROOT, "araclar", "wp_render.py")
        wp_ok = os.path.exists(venv_py) and os.path.exists(wp)

        def build_html(scale):
            ozel = ""
            if abs(scale - 1.0) > 0.01:
                ozel = ("<style>.govde{font-size:%.2fpx;line-height:%.3f}"
                        "figure{margin:%dpx 0}blockquote{margin:%dpx 0}</style>"
                        % (12.5 * scale, 1.55 * scale, round(10 * scale), round(12 * scale)))
            return HTML_ISKELET.format(
                css=CSS.replace("COLUMN_KAC", str(kolon)) + ozel,
                kulak=html.escape(kulak), baslik=html.escape(baslik),
                spot_html=(f'<p class="spot">{html.escape(spot)}</p>' if spot else ""),
                byline=html.escape(byline), govde=body)

        def render(scale, out_path):
            hp = os.path.join(tmpdir, "makale.html")
            with open(hp, "w", encoding="utf-8") as f:
                f.write(build_html(scale))
            if wp_ok:
                try:
                    r = subprocess.run([venv_py, wp, hp, out_path], capture_output=True, text=True, timeout=120)
                    if r.returncode == 0 and os.path.exists(out_path) and os.path.getsize(out_path) > 1000:
                        try:
                            pages = int(r.stdout.strip().splitlines()[-1])
                        except Exception:
                            pages = 0
                        return "weasyprint", pages
                except Exception:
                    pass
            chrome = chrome_yolu()
            if chrome:
                profil = os.path.join(tmpdir, "chrome-profil")
                cmd = [chrome, "--headless=new", "--disable-gpu", "--no-sandbox", "--no-first-run",
                       "--no-default-browser-check", f"--user-data-dir={profil}",
                       "--run-all-compositor-stages-before-draw", "--virtual-time-budget=25000",
                       "--no-pdf-header-footer", f"--print-to-pdf={out_path}", "file://" + hp]
                try:
                    p = subprocess.Popen(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
                    try:
                        p.wait(timeout=90)
                    except subprocess.TimeoutExpired:
                        pass
                except Exception:
                    pass
                if os.path.exists(out_path) and os.path.getsize(out_path) > 1000:
                    return "chrome", len(re.findall(rb"/Type\s*/Page[^s]", open(out_path, "rb").read()))
            return None, 0

        taban, uz = os.path.splitext(dosya)
        hedef = os.path.join(cikti_dizin, dosya)
        n = 1
        while os.path.exists(hedef):
            hedef = os.path.join(cikti_dizin, f"{taban}-{n}{uz}"); n += 1

        motor, pages = render(1.0, hedef)
        # hedef_sayfa: ölçekleyerek ~N sayfaya yakınsa (yalnız WeasyPrint'te sayım güvenilir).
        if hedef_sayfa and motor == "weasyprint" and pages > 0 and pages != hedef_sayfa:
            scale = 1.0
            best_scale, best_pages = 1.0, pages
            for _ in range(4):
                ratio = (hedef_sayfa / pages) ** 0.5
                new_scale = min(2.0, max(0.6, scale * ratio))
                if abs(new_scale - scale) < 0.02:
                    break
                m2, p2 = render(new_scale, os.path.join(tmpdir, "deneme.pdf"))
                if m2 != "weasyprint" or p2 == 0 or p2 == pages:
                    break
                scale, pages = new_scale, p2
                if abs(p2 - hedef_sayfa) < abs(best_pages - hedef_sayfa):
                    best_scale, best_pages = scale, p2
                if p2 == hedef_sayfa:
                    break
            if best_scale != 1.0:
                m3, p3 = render(best_scale, hedef)
                if m3 == "weasyprint" and p3 > 0:
                    motor, pages = m3, p3

        if motor is None:
            txt = re.sub(r"<[^>]+>", "\n", body)
            txt = re.sub(r"\n{2,}", "\n\n", txt).strip()
            plain = os.path.join(tmpdir, "belge.txt")
            with open(plain, "w", encoding="utf-8") as f:
                f.write(baslik + "\n" + ("=" * len(baslik) + "\n\n") + txt + "\n")
            with open(hedef, "wb") as out:
                subprocess.run(["/usr/sbin/cupsfilter", plain], stdout=out, stderr=subprocess.DEVNULL, timeout=120)
            if not (os.path.exists(hedef) and os.path.getsize(hedef) > 1000):
                raise RuntimeError("PDF üretilemedi (WeasyPrint, Chrome ve cupsfilter başarısız).")
            motor = "cupsfilter"
            pages = len(re.findall(rb"/Type\s*/Page[^s]", open(hedef, "rb").read()))

        print(json.dumps({"durum": "ok", "dosya": hedef, "bayt": os.path.getsize(hedef),
                          "motor": motor, "sayfa": pages, "hedef_sayfa": hedef_sayfa,
                          "baslik": baslik, "kolon": kolon}, ensure_ascii=False, indent=2))
    finally:
        shutil.rmtree(tmpdir, ignore_errors=True)


if __name__ == "__main__":
    main()
