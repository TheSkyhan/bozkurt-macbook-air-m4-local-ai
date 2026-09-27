import importlib.util,json,os,shutil,subprocess,tempfile,unittest
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
def module(name):
    spec=importlib.util.spec_from_file_location(name,ROOT/'araclar'/f'{name}.py');m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m);return m
class Tools(unittest.TestCase):
    def test_arithmetic(self):
        m=module('hesapla');self.assertEqual(m.calculate('18*7-23'),103)
        for x in ('__import__("os")','2**101','1/0'):
            with self.assertRaises(Exception):m.calculate(x)
    def test_document_boundary(self):
        m=module('belge_yaz')
        with tempfile.TemporaryDirectory() as d:
            base=Path(d)/'workspace';base.mkdir();(base/'outside').symlink_to(Path(d),target_is_directory=True)
            for name in ('../escape','outside/escape'):
                with self.assertRaises(ValueError):m.write_section({'dosya':name,'metin':'test'},base)
            result=m.write_section({'dosya':'report','metin':'Hello','sifirla':True},base)
            m.write_section({'dosya':'report','metin':'World'},base)
            self.assertEqual(Path(result['dosya']).read_text(),'Hello\n\nWorld\n\n')
    def test_weather_requires_explicit_location(self):
        env={k:v for k,v in os.environ.items() if not k.startswith('BOZKURT_KONUM')}
        p=subprocess.run(['python3',str(ROOT/'araclar/hava_durumu.py'),'bugun'],env=env,capture_output=True,text=True,timeout=5)
        self.assertNotEqual(p.returncode,0);self.assertIn('Şehir belirtin',p.stderr)
    def test_portable_isolated_config(self):
        with tempfile.TemporaryDirectory(prefix='bozkurt test ') as d:
            dest=Path(d)/'source with spaces';shutil.copytree(ROOT,dest,ignore=shutil.ignore_patterns('.git','__pycache__','.runtime','gunlukler','modeller'))
            env=os.environ.copy();env.pop('BOZKURT_ROOT',None);env.pop('PI_CODING_AGENT_DIR',None);env['BOZKURT_WORKSPACE']=str(Path(d)/'workspace')
            script='source "$1/motorlar/lib/ortam.zsh"; print -r -- "$BOZKURT_ROOT"'
            p=subprocess.run(['zsh','-c',script,'test',str(dest)],env=env,capture_output=True,text=True)
            self.assertEqual(p.returncode,0,p.stderr);self.assertEqual(p.stdout.strip(),str(dest.resolve()))
            settings=dest/'.runtime/pi/settings.json';settings.write_text('{"custom":true}')
            subprocess.run(['zsh','-c',script,'test',str(dest)],env=env,capture_output=True,check=True)
            self.assertEqual(settings.read_text(),'{"custom":true}')
    @unittest.skipUnless(shutil.which('ffmpeg') and os.uname().sysname=='Darwin','macOS + ffmpeg required')
    def test_effects_without_models(self):
        with tempfile.TemporaryDirectory(prefix='bozkurt effects ') as d:
            base=Path(d);repo=base/'repo';shutil.copytree(ROOT,repo,ignore=shutil.ignore_patterns('.git','__pycache__','.runtime','gunlukler','modeller'))
            image=base/'sample.png'
            subprocess.run(['ffmpeg','-y','-v','error','-f','lavfi','-i','color=c=blue:s=64x64','-frames:v','1',str(image)],check=True)
            binpath=base/'bin';binpath.mkdir();op=binpath/'open';op.write_text('#!/bin/sh\nexit 0\n');op.chmod(0o755)
            env=os.environ.copy();env.pop('BOZKURT_ROOT',None);env.pop('PI_CODING_AGENT_DIR',None);env['BOZKURT_WORKSPACE']=str(base/'workspace');env['PATH']=str(binpath)+os.pathsep+env['PATH']
            p=subprocess.run(['zsh',str(repo/'baslaticiler/baslat-qwen-image.sh')],input=f'3\n{image}\n',text=True,capture_output=True,env=env,timeout=45)
            self.assertEqual(p.returncode,0,p.stdout+p.stderr)
            self.assertEqual(len(list((base/'workspace/Bozkurt-Gorseller').glob('efekt-*.png'))),14)
if __name__=='__main__':unittest.main()

class ImageLauncher(unittest.TestCase):
    def test_generation_pipeline_with_stub_engine(self):
        """Check menus, output paths and adapter filtering; does not run inference."""
        with tempfile.TemporaryDirectory(prefix='bozkurt generation ') as d:
            base=Path(d);repo=base/'repo';shutil.copytree(ROOT,repo,ignore=shutil.ignore_patterns('.git','__pycache__','.runtime','gunlukler','modeller'))
            modeldir=repo/'modeller/model-arsivi/qwen-image-2.1'
            for name in ['diffusion_models/qwen_image_2.1-Q4_K.gguf','text_encoders/Qwen3VL-8B-Instruct-Q4_K_M.gguf','vae/qwen_image_2.1_vae_bf16.safetensors']:
                p=modeldir/name;p.parent.mkdir(parents=True,exist_ok=True);p.write_text('fixture')
            loras=modeldir/'loras';loras.mkdir()
            import struct
            for name,meta in [('flagged',{'tag':'nsfw'}),('clean',{'tag':'watercolor'})]:
                hdr=json.dumps({'__metadata__':meta}).encode();(loras/(name+'.safetensors')).write_bytes(struct.pack('<Q',len(hdr))+hdr)
            (loras/'broken.safetensors').write_bytes(b'bad')
            stub=repo/'motorlar/qwen-image-backend/build-metal/bin/sd-cli';stub.parent.mkdir(parents=True)
            stub.write_text('#!/bin/zsh\nwhile (( $# )); do\n if [[ "$1" == --output ]]; then print fixture > "$2"; fi\n shift\ndone\n');stub.chmod(0o755)
            binpath=base/'bin';binpath.mkdir()
            mocks={'stat':'print 5000000000','open':'exit 0','pgrep':'exit 1','lsof':'exit 1','ffmpeg':'print scaled > "${@[-1]}"'}
            for name,body in mocks.items():
                p=binpath/name;p.write_text('#!/bin/zsh\n'+body+'\n');p.chmod(0o755)
            env=os.environ.copy();env.pop('BOZKURT_ROOT',None);env.pop('PI_CODING_AGENT_DIR',None);env['BOZKURT_WORKSPACE']=str(base/'workspace');env['PATH']=str(binpath)+os.pathsep+env['PATH']
            # operation 1, square, draft, no style, prompt, seed, no LoRA, confirm
            p=subprocess.run(['zsh',str(repo/'baslaticiler/baslat-qwen-image.sh')],input='1\n1\n1\n0\nA red teapot\n42\n0\nE\n',text=True,capture_output=True,env=env,timeout=15)
            self.assertEqual(p.returncode,0,p.stdout+p.stderr)
            self.assertIn('clean.safetensors',p.stdout);self.assertNotIn('flagged.safetensors',p.stdout);self.assertNotIn('broken.safetensors',p.stdout)
            outputs=list((base/'workspace/Bozkurt-Gorseller').glob('qwen-image-*.png'));self.assertEqual(len(outputs),1);self.assertEqual(outputs[0].read_text(),'scaled\n')
