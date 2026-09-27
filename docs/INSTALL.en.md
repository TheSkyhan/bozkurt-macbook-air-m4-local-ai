# MacBook Air M4 16GB — Installation

[Introduction](../README.en.md) · [Türkçe](INSTALL.tr.md)

This distribution targets macOS Apple Silicon and zsh. Windows/Linux and Intel Macs are unvalidated. Install Homebrew and Xcode Command Line Tools (`xcode-select --install`). Downloads require internet access and sufficient disk space; even the Bonsai-only path downloads several GB. You do not need every optional model.

## 1. Install tools

```bash
brew install node python llama.cpp ffmpeg cmake pango cairo libffi
npm install -g @earendil-works/pi-coding-agent@0.87.1
git clone https://github.com/TheSkyhan/bozkurt-macbook-air-m4-local-ai.git
cd bozkurt-macbook-air-m4-local-ai
./kurulum.sh
```

Homebrew/npm download packages from the internet. The setup script keeps the existing `~/.pi/agent` profile separate and creates model/settings files under `.runtime/pi`. Running it again preserves existing configuration.

## 2. Start with Bonsai

The pinned revision below matches the reference setup. Review the model license and upstream installer before running it.

```bash
git clone https://github.com/PrismML-Eng/Bonsai-demo.git motorlar/Bonsai-demo
git -C motorlar/Bonsai-demo checkout 17b143e889a45c090816b520e79a50c996164e1f
(cd motorlar/Bonsai-demo && BONSAI_OPENWEBUI=0 BONSAI_CODE_INTERPRETER=0 ./setup.sh)
./baslaticiler/bozkurt
```

Choose **1** for chat/research or **4** for coding. Bonsai needs its compatible llama.cpp engine; do not point the Homebrew engine at Bonsai weights. Install other models using the [model guide](MODELS.md).

## 3. PDF support

```bash
python3 -m venv .venv-pdf
.venv-pdf/bin/python -m pip install -r requirements-pdf.txt
```

WeasyPrint is preferred. The tool may fall back to installed Chrome/Chromium/Edge or the system PDF converter; layouts can differ.

## 4. Optional short command

From the repository root, define an alias for this terminal. For persistence, add the resulting alias to your own `~/.zshrc`.

```zsh
alias bozkurt="${(q)PWD}/baslaticiler/bozkurt"
```

## 5. Verify

`python3 tests/check_distribution.py` validates the source package. `python3 -m unittest discover -s tests` runs regression tests without downloading models. `./baslaticiler/sistem-testi.sh` checks a full local installation and may report optional engines you did not install. Health URL: `http://127.0.0.1:8080/health`; API root: `http://127.0.0.1:8080/v1`.

Back up local settings before updating. Existing `.runtime/pi` settings are not automatically replaced by new examples. Removing the repository does not remove outputs in the separate `~/Bozkurt-Workspace` folder.
