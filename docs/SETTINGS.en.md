# Settings — M4 / 16GB

[Türkçe](SETTINGS.tr.md) · [Home](../README.en.md)

## Configuration files

- `yapilandirma/models.example.json`: distributed provider examples; all use `127.0.0.1:8080/v1`. `yerel` is a local placeholder, not a credential.
- `.runtime/pi/models.json`: active providers, copied on first launch. `contextWindow` is the client context budget; `maxTokens` caps the response.
- `.runtime/pi/settings.json`: automatic compaction, theme, recent context and per-model token reserves.
- `yapilandirma/etkin-beceriler.conf`: `1` enables a skill, `0` disables it. `./yonet-beceriler.sh` edits this list. Add new skills as `beceriler/<name>/SKILL.md` and register them in the list.
- `yapilandirma/konum.conf`: optional personal location, ignored by Git. Naming a city in each request is sufficient.

## Environment variables

| Variable | Default / function |
|---|---|
| `BOZKURT_ROOT` | Automatically resolved repository root |
| `BOZKURT_WORKSPACE` | `~/Bozkurt-Workspace`; agent workspace and outputs |
| `PI_CODING_AGENT_DIR` | `$BOZKURT_ROOT/.runtime/pi`; configuration and sessions |
| `BOZKURT_LLAMA_BIN` | `llama-server` from PATH; Qwen/Lucifer engine |
| `BOZKURT_QWEN_TEMP` | `0.75`; higher values increase variation |
| `BONSAI_CTX` | `24576`; Bonsai server context |
| `BONSAI_REASONING_BUDGET` | `384`; `0` disables reasoning output |
| `BOZKURT_WEB_OKU_SINIR` | Web page character limit; extension default 14000, some menu profiles override it |
| `BOZKURT_WEB_DISABLED` | Set to `1` by menu 2; remote-resource checks in document tools |
| `BOZKURT_KONUM_LAT`, `BOZKURT_KONUM_LON`, `BOZKURT_KONUM_SEHIR` | Optional coordinates/city that you configure yourself |

## Inference profiles

| Profile | Server context | KV | Cache / checkpoints | Sampling |
|---|---:|---|---|---|
| Bonsai | 24576 | q8_0 K/V | 4096 MiB / 128, step 128 | upstream Bonsai 2 profile; reasoning budget 384 |
| Qwen | 16384 | engine default | 512 MiB / 16, step 256 | temperature .75, top-p .92, top-k 40 |
| Lucifer | 8192 | q8_0 K/V | 512 MiB / 16, step 256 | temperature .90, top-p .95, top-k 60 |

The inherited Lucifer client example advertises 16384 while its server uses 8192, an accommodation for Turkish token estimation in the reference setup. This is not real 16K server capacity. Long prompts can overflow; align the client to 8192 if needed and retain compaction reserves. If you reduce Bonsai context, align its client `contextWindow` too.

```bash
BONSAI_CTX=16384 ./baslaticiler/bozkurt
```

Bonsai inference settings were retained from the reference setup; speed is not guaranteed. The legacy `BOZKURT_EARLY_COMPACT_AT` variable appears in launchers but is not consumed by the current extension. Manage automatic compaction through Pi settings.

## Headless coding agent

Start `./baslaticiler/baslat-bonsai.sh` in a separate terminal first. Then:

```bash
BOZKURT_PROJE="$HOME/Projects/example" \
BOZKURT_GOREV="Run the tests and report the cause of the failure." \
./baslaticiler/baslat-headless-ajan.sh
```

`BOZKURT_GOREV_DOSYA` selects a task file, `BOZKURT_SID` a session, `BOZKURT_MODEL` a provider/model, `BOZKURT_MAX_TUR` defaults to 8, `BOZKURT_DUSUNME` defaults to off, and `BOZKURT_ARACLAR` controls tool arguments. `BOZKURT_EKLENTISIZ=1` removes the autonomy extension, including its repetition protection. Success requires exit code zero and an exact final line `GOREV_TAMAM`. Logs can contain private task contents; do not publish them.
