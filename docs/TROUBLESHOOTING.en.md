# Troubleshooting

| Symptom | Check / resolution |
|---|---|
| `pi` not found | Use the npm command in the installation guide; verify PATH with `command -v pi`. |
| Missing model file | Install the model for the selected mode; compare the launcher path against `docs/MODELS.md`. |
| Port 8080 busy | Run `lsof -nP -iTCP:8080 -sTCP:LISTEN`. The launcher refuses to stop unrelated applications; stop that application yourself. |
| Early server exit / three-minute timeout | Inspect the relevant local log under `gunlukler/` for missing weights, incompatible flags or memory errors. |
| Metal OOM / high swap | Close heavy applications, run one model, use Qwen Image Q4_K and a small canvas. Align client context if reducing Bonsai context. |
| `unknown argument` | Compare engine versions; newer Homebrew packages may not support the same flags. |
| Image editing fails | Check the Qwen 2.1 VAE, Qwen3-VL encoder and matching projector. Text-to-image does not require the projector. |
| LoRA absent from menu | Check the directory, extension, metadata and 2.1 compatibility. Flagged or unreadable metadata is rejected. |
| Weather location error | Supply a city explicitly; there is no automatic GPS/IP discovery. |
| PDF fails or looks wrong | Check `.venv-pdf`, WeasyPrint and Homebrew pango/cairo dependencies. Remote images need network access. |
| Window inspection fails | Check macOS Privacy & Security Automation/Accessibility permissions. Permissions are not bypassed. |
| Empty / excessively long answer | Check actual server context, client context, response reserve and reasoning budget; try a short new session. |

Full GUI clicking/browser automation is not included. `/resume` lists sessions in this installation's Pi directory. `sistem-testi.sh` checks a full installation; missing optional engines do not by themselves prevent Bonsai use.

When reporting a bug, include versions, mode, reproduction steps and a short sanitized error. Do not upload full logs or chat histories.
