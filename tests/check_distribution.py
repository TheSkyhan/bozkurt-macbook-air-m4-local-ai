#!/usr/bin/env python3
"""Check tracked sources (or a fresh source tree) without loading models."""
import ast,json,re,subprocess,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
run=subprocess.run(['git','-C',str(ROOT),'ls-files','-z'],capture_output=True)
files=[ROOT/p for p in run.stdout.decode().split('\0') if p] if run.returncode==0 else [p for p in ROOT.rglob('*') if p.is_file() and not any(x in p.parts for x in ('.git','__pycache__','.runtime','gunlukler','modeller','.venv-pdf'))]
errors=[]
for p in files:
    rel=p.relative_to(ROOT)
    if p.suffix in ('.gguf','.safetensors','.bin','.png','.jpg','.pdf','.zip','.pyc') or any(x in rel.parts for x in ('sessions','gunlukler','yedekler','node_modules','.runtime')):
        errors.append(f'Excluded file: {rel}');continue
    try:s=p.read_text()
    except UnicodeError:errors.append(f'Binary file: {rel}');continue
    if p.stat().st_size>500_000:errors.append(f'Oversized source: {rel}')
    patterns=[r'/'+'Users/[^/\\s]+/',r'gh[pousr]_[A-Za-z0-9]{20,}',r'github_pat_[A-Za-z0-9_]{20,}',r'-----BEGIN (?:RSA |OPENSSH )?PRIVATE KEY-----']
    for pattern in patterns:
        if re.search(pattern,s):errors.append(f'Private path/credential pattern: {rel}')
    if p.suffix=='.py':
        try:ast.parse(s)
        except SyntaxError as e:errors.append(f'Python syntax: {rel}: {e}')
    if p.suffix in ('.sh','.zsh') or p.name=='bozkurt':
        q=subprocess.run(['zsh','-n',str(p)],capture_output=True,text=True)
        if q.returncode:errors.append(f'Shell syntax: {rel}: {q.stderr}')
    if p.suffix=='.json':
        try:json.loads(s)
        except ValueError:errors.append(f'JSON: {rel}')
    if p.suffix=='.md':
        for link in re.findall(r'\]\(([^)]+)\)',re.sub(r'`[^`]*`','',s)):
            if '://' not in link and not link.startswith('#') and not (p.parent/link.split('#')[0]).exists():errors.append(f'Broken local link: {rel}: {link}')
image=(ROOT/'baslaticiler/baslat-qwen-image.sh').read_text()
for forbidden in ('FACE_'+'DESC','V2_'+'PROMPTS','V2_'+'TITLES','"$ISLEM" == "4"'):
    if forbidden in image:errors.append('Private image mode remains')
if 'OUTPUT="$OUTPUT_DIR/qwen-image-' not in image:errors.append('Missing image output path')
models=json.loads((ROOT/'yapilandirma/models.example.json').read_text())
for provider in models['providers'].values():
    if provider.get('baseUrl')!='http://127.0.0.1:8080/v1' or provider.get('apiKey')!='yerel':errors.append('Nonlocal provider or credential')
if errors:
    print('\n'.join(errors));sys.exit(1)
print(f'PASS: {len(files)} source files; syntax, links, local providers and exclusion checks.')
