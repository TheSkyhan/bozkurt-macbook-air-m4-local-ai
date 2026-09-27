# Bozkurt contributor instructions

- Keep user data, models, generated files, secrets, logs and histories out of Git.
- Run `python3 tests/check_distribution.py` and `python3 -m unittest discover -s tests` before publishing.
- Keep Turkish and English documentation aligned with actual launchers.
- Keep inference on loopback; do not silently change model quantization or Bonsai inference settings.
- Preserve user changes. Never copy a live runtime directory into the repository.
- Qwen Image ships general-purpose generation, editing and color effects only. Do not add private identity descriptions or adult presets.
