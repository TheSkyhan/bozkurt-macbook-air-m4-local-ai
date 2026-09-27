#!/usr/bin/env python3
# WeasyPrint render yardımcısı — Bozkurt .venv-pdf python'u ile çağrılır
# (Xcode /usr/bin/python3, Homebrew pango/cairo kütüphanelerini SIP nedeniyle yükleyemez).
# Kullanım: wp_render.py <girdi.html> <çıktı.pdf>  → stdout'a sayfa sayısını yazar.
import sys
from weasyprint import HTML

if len(sys.argv) < 3:
    raise SystemExit("Kullanım: wp_render.py <html> <pdf>")
doc = HTML(filename=sys.argv[1]).render()
doc.write_pdf(sys.argv[2])
print(len(doc.pages))
