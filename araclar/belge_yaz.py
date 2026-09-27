#!/usr/bin/env python3
"""Uzun metni mevcut çalışma alanı içindeki Markdown dosyasında biriktir."""
import json,sys
from pathlib import Path

def write_section(spec,base=None):
    base=Path(base or Path.cwd()).resolve()
    name=str(spec.get('dosya') or 'makale').strip()
    if not name.lower().endswith('.md'):name+='.md'
    path=(base/name).resolve()
    if not path.is_relative_to(base):raise ValueError('Belge yolu çalışma alanı dışında olamaz.')
    if not isinstance(spec.get('metin'),str) or not spec['metin'].strip():raise ValueError('Bölüm metni boş olamaz.')
    path.parent.mkdir(parents=True,exist_ok=True)
    with path.open('w' if spec.get('sifirla') else 'a',encoding='utf-8') as f:f.write(spec['metin'].rstrip()+'\n\n')
    return {'durum':'ok','dosya':str(path),'toplam_bayt':path.stat().st_size,'eklenen_karakter':len(spec['metin'])}
if __name__=='__main__':
    try:print(json.dumps(write_section(json.loads(sys.argv[1])),ensure_ascii=False))
    except Exception as e:print(json.dumps({'hata':str(e)},ensure_ascii=False));sys.exit(1)
