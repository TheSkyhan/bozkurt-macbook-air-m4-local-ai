#!/usr/bin/env python3
"""Bozkurt kurulumunu model yüklemeden ve kullanıcı dosyalarını değiştirmeden denetle."""
import ast,json,subprocess,sys,urllib.request
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
def main():
    checks=[]
    def check(name,ok,detail=''):checks.append({'denetim':name,'basarili':bool(ok),'ayrinti':detail})
    for folder,pattern in [('baslaticiler','*.sh'),('motorlar/lib','*.zsh')]:
        for p in sorted((ROOT/folder).glob(pattern)):
            run=subprocess.run(['zsh','-n',str(p)],capture_output=True,text=True)
            check('Kabuk: '+p.name,run.returncode==0,run.stderr.strip())
    for p in (ROOT/'araclar').glob('*.py'):
        try:ast.parse(p.read_text());check('Python: '+p.name,True)
        except Exception as e:check('Python: '+p.name,False,str(e))
    home=Path(__import__('os').environ.get('PI_CODING_AGENT_DIR',str(ROOT/'.runtime/pi')))
    data={}
    for name in ('models','settings'):
        try:data[name]=json.loads((home/(name+'.json')).read_text());check(name+' JSON',True)
        except Exception as e:check(name+' JSON',False,str(e))
    for source in data.get('settings',{}).get('packages',[]):
        if isinstance(source,str) and source.startswith(('/','.')):
            check('Pi paketi '+source,(home/source/'package.json').is_file())
    for provider,obj in data.get('models',{}).get('providers',{}).items():
        check(provider+' yalnız yerel API',obj.get('baseUrl','').startswith('http://127.0.0.1:8080/'))
        for model in obj.get('models',[]):
            c=model['contextWindow'];m=model['maxTokens']
            co=data.get('settings',{}).get('compaction',{})
            reserve=co.get('modelOverrides',{}).get(provider+'/'+model['id'],{}).get('reserveTokens',co.get('reserveTokens',0))
            check(provider+' bağlam/yanıt payı',0<m<c and 1024<=reserve<c,f'bağlam={c}, yanıt={m}, rezerv={reserve}')
    for line in (ROOT/'yapilandirma/etkin-beceriler.conf').read_text().splitlines():
        if not line or line.startswith('#') or '=' not in line:continue
        name,enabled=line.split('=',1)
        if enabled.strip()!='1':continue
        p=ROOT/'beceriler'/name/'SKILL.md'
        check('Beceri: '+name,p.is_file() and p.read_text().startswith('---\nname:'))
    for path in ['/opt/homebrew/bin/pi','/opt/homebrew/bin/llama-server',str(ROOT/'motorlar/Bonsai-demo/bin/mac/llama-server'),str(ROOT/'motorlar/qwen-image-backend/build-metal/bin/sd-cli')]:
        check('Motor: '+path,Path(path).is_file())
    model_paths = list((ROOT/'modeller').rglob('*.gguf')) + list((ROOT/'motorlar/Bonsai-demo/models/bonsai2-gguf/27B').glob('*.gguf'))
    for p in model_paths:
        if '.cache' in p.parts:continue
        with p.open('rb') as f:magic=f.read(4)
        check('GGUF: '+p.name,magic==b'GGUF' and p.stat().st_size>1000)
    import struct
    for p in (ROOT/'modeller/model-arsivi/qwen-image-2.1').rglob('*.safetensors'):
        try:
            with p.open('rb') as f:
                n=struct.unpack('<Q',f.read(8))[0]
                if n>16_000_000:raise ValueError('başlık çok büyük')
                header=json.loads(f.read(n))
            tensors=[v for k,v in header.items() if k!='__metadata__']
            check('Safetensors: '+p.name,bool(tensors) and max(v['data_offsets'][1] for v in tensors)+n+8==p.stat().st_size)
        except Exception as e:check('Safetensors: '+p.name,False,str(e))
    try:
        with urllib.request.urlopen('http://127.0.0.1:8080/health',timeout=2) as r:health=json.load(r)
        status='hazır' if health.get('status')=='ok' else str(health)
    except Exception:status='çalışan sunucu yok veya erişilemiyor; model yüklenmedi'
    result={'basarili':all(c['basarili'] for c in checks),'sunucu':status,'denetimler':checks}
    if '--json' in sys.argv:print(json.dumps(result,ensure_ascii=False,indent=2))
    else:
        for c in checks:print(('✓ ' if c['basarili'] else '✗ ')+c['denetim']+(' — '+c['ayrinti'] if c['ayrinti'] else ''))
        print('Sunucu:',status);print('Sonuç:', 'başarılı' if result['basarili'] else 'düzeltme gerekiyor')
    return 0 if result['basarili'] else 1
if __name__=='__main__':sys.exit(main())
