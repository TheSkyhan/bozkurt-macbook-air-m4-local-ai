# Bozkurt — Local AI for MacBook Air M4 with 16GB RAM

[Türkçe](README.tr.md) · [Home](README.md) · [Installation](docs/INSTALL.en.md)

Bozkurt is a terminal-based local AI workspace for people who want to run AI on a MacBook Air M4 with 16GB unified memory. It combines Bonsai, Qwen and optional Lucifer text profiles, Qwen Image generation, research and document tools in one menu. Inference runs on your Mac; no paid cloud LLM key is required.

This is not a separate foundation model. Bozkurt integrates third-party models and inference engines with Pi and local tools. Download model weights separately and install only the modes you need. The menu and default assistant instructions are primarily Turkish; you can request English responses.

## Usage

After installation, run `./baslaticiler/bozkurt` from the repository root. Press Enter for mode 1.

| Menu | Model / function | Available capabilities |
|---|---|---|
| 1 — Bozkurt Asistan | Bonsai 2 27B | Chat, read-only file inspection, web, weather, arithmetic, PDF/documents |
| 2 — Lucifer Gizli Sohbet | OrcaRouter Qwen-derived 27B IQ2_M | Arithmetic and local documents; web tools are not loaded |
| 3 — Genel Yardımcı | Local Qwen 9B Q8 profile | Fast chat, read-only file tools, web/weather, arithmetic and documents |
| 4 — Kodlama Ajanı | Bonsai 2 27B | File editing, terminal commands, research and basic macOS application tools |
| 5 — Qwen Image | Qwen Image 2.1 Q4_K | Image generation, editing and color effects |

The “Gizli” label means a restricted tool profile, not incognito storage. Sessions are saved locally in `.runtime/pi/`. Modes 1 and 3 cannot edit code; choose mode 4 for development. Their document tools can still create document outputs.

Example requests:

- “Inspect this project folder and explain your findings.”
- “There are 18 pencils in each of 7 boxes; I gave away 23. How many remain?”
- “What is tomorrow's weather in Ankara?”
- “Read the source pages and write a referenced report on this topic.”
- In coding mode: “Fix this project's bug, run the relevant test and report the result.”
- In image mode: “A red ceramic teapot on a wooden table, soft window light.”

## Workspace and commands

The default workspace is `~/Bozkurt-Workspace`; images go into its `Bozkurt-Gorseller` subfolder. Select another project with:

```bash
BOZKURT_WORKSPACE="$HOME/Projects/example" ./baslaticiler/bozkurt
```

`/beceriler`, `/araclar`, `/eklentiler`, `/modeller` and `/komutlar` list skills, tools, extensions and models. `/otonomi`, where loaded, shows the 80-call per-request counter. `/resume` opens previous sessions. Esc interrupts generation. A text server may remain running after you exit:

```bash
./baslaticiler/durum-kontrol.sh
./baslaticiler/durdur-ajan.sh
./baslaticiler/sistem-testi.sh
./yonet-beceriler.sh
```

## MacBook Air M4 / 16GB memory approach

Run one model at a time. The Bonsai profile uses a 24K context and q8_0 KV cache; Qwen uses 16K; the Lucifer server uses 8K. Image outputs are resized from smaller generation canvases. Large contexts, a second model, many browser tabs and Q8 image weights increase memory pressure. Long runs on a fanless M4 Air can vary in speed. See [settings](docs/SETTINGS.en.md).

## Network and privacy

The text API binds to `127.0.0.1:8080`. Web searches send queries, page reads send URLs, and weather requests send the selected city/coordinates to external services. Weather does not automatically discover your location. Remote PDF images can use the internet. The coding agent has your account's file/terminal permissions and is not an OS sandbox.

Personal data, history, private task files, model weights, private facial descriptions and adult image presets are excluded. For general-purpose LoRA customization, see the [image guide](docs/IMAGE.en.md).
