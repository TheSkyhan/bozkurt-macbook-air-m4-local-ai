#!/usr/bin/env python3
"""Eski sabit başarı iddiaları yerine canlı kurulum sonucunu JSON olarak raporlar."""
import subprocess,sys
from pathlib import Path
if __name__ == '__main__':
    sys.exit(subprocess.call([sys.executable,str(Path(__file__).with_name('sistem_dogrula.py')),'--json']))
