# Bozkurt — Local AI on MacBook Air M4 16GB | Localhost LLM & Qwen Image

**MacBook Air M4 16GB için yerel yapay zekâ: localhost sohbet, kodlama ajanı, araştırma, PDF ve görsel üretimi.**

**Run local AI on a MacBook Air M4 with 16GB unified memory: localhost chat, a coding agent, research, PDF tools and Qwen Image.**

[Türkçe tanıtım ve kullanım](README.tr.md) · [English introduction and usage](README.en.md)

Bozkurt brings local model launchers, a Pi terminal assistant, practical tools and task skills into one macOS workflow. It uses Apple Silicon Metal acceleration and a loopback API at `http://127.0.0.1:8080/v1`. It is an integration and configuration project, not a newly trained foundation model.

Bozkurt, Apple Silicon üzerinde yerel model başlatıcılarını, Pi terminal asistanını, araçları ve görev becerilerini birleştirir. Model ağırlıkları, konuşma geçmişleri, kişisel veriler ve Qwen Image yetişkin içerik ön ayarları bu depoda bulunmaz.

## Start here / Buradan başlayın

| Türkçe | English |
|---|---|
| [Kurulum](docs/INSTALL.tr.md) | [Installation](docs/INSTALL.en.md) |
| [Kullanım ve modlar](README.tr.md#kullanım) | [Usage and modes](README.en.md#usage) |
| [Ayarlar ve bellek](docs/SETTINGS.tr.md) | [Settings and memory](docs/SETTINGS.en.md) |
| [Model dosyaları ve kaynakları](docs/MODELS.md) | [Model files and sources](docs/MODELS.md) |
| [Qwen Image ve LoRA](docs/IMAGE.tr.md) | [Qwen Image and LoRA](docs/IMAGE.en.md) |
| [Sorun giderme](docs/TROUBLESHOOTING.tr.md) | [Troubleshooting](docs/TROUBLESHOOTING.en.md) |
| [Gizlilik ve paylaşım kapsamı](docs/PRIVACY.md) | [Privacy and distribution scope](docs/PRIVACY.md) |

## What is included?

- Five menu entries: Bonsai assistant, offline-tool Lucifer chat, Qwen helper, Bonsai coding agent and Qwen Image.
- Local arithmetic, document assembly, PDF output, optional web search, weather and source-page reading.
- Fourteen task skills, session UI, model/tool discovery and repeated-tool-call protection.
- Qwen Image generation/editing, eight style presets and fourteen FFmpeg color effects.
- Portable paths and isolated Pi configuration; model weights and downloaded inference engines remain local.

## Quick orientation

```bash
git clone https://github.com/TheSkyhan/bozkurt-macbook-air-m4-local-ai.git
cd bozkurt-macbook-air-m4-local-ai
# Install prerequisites and model files using the guide first.
./kurulum.sh
./baslaticiler/bozkurt
```

**This is a source distribution, not a one-click model bundle.** Follow the installation guide before launching a model. The reference hardware is MacBook Air M4, 16GB; a fresh end-to-end installation and full inference matrix have not been validated on every macOS release. The terminal menu and built-in prompts are primarily Turkish; the English guide explains the same workflow.

Local inference needs no cloud LLM key. Web/weather tools and optional remote document images use the internet. “Offline chat” does not mean invisible history: Pi stores sessions locally. The coding agent runs commands with your account's permissions.

## Project structure

```text
baslaticiler/       Model launchers and terminal menu
araclar/           Python web, weather, math and document tools
eklentiler/        Pi TypeScript extensions
beceriler/         Task instructions (skills)
temalar/           Light and dark terminal themes
yapilandirma/     Public configuration examples
motorlar/lib/      Environment and server-management helpers
docs/              Turkish and English guides
tests/             Distribution checks and regression tests
```

## Project status and scope

The public package is derived from an M4/16GB local setup. Its validation scope is recorded in [VALIDATION.md](docs/VALIDATION.md). No performance ranking or cloud-model equivalence is claimed. The 1080px image outputs are resized from smaller generation canvases; they are not native 1080px generations.

For people searching for **MacBook Air M4 local AI**, **16GB Apple Silicon local LLM**, **localhost AI assistant on Mac**, **MacBook M4 yerel yapay zekâ kurulumu** or **Qwen Image on Mac**, the guides explain the actual commands, memory tradeoffs and limitations.

[Dependencies and attribution](THIRD_PARTY.md) · [Contributing](CONTRIBUTING.md)
