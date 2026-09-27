# Qwen Image — generation, editing and LoRA

[Türkçe](IMAGE.tr.md) · [Models](MODELS.md)

Choose menu 5 or run `./baslaticiler/baslat-qwen-image.sh`. Three operations are available:

1. Generate a new image from a text description.
2. Edit a source image with an optional mask and an edit description. Requires a matching vision projector. Exact identity/composition preservation is not guaranteed.
3. Apply fourteen FFmpeg color effects without an AI model. The source remains unchanged; this path only requires ffmpeg.

## Workflow and quality

Operation → source if needed → canvas → quality → style → prompt → editing effect → seed → optional LoRA → summary/confirmation.

| Canvas | Actual generation | Final resize |
|---|---|---|
| Square | 512×512 | 1080×1080 |
| Feed 4:5 | 512×640 | 1080×1350 |
| Story 9:16 | 432×768 | 1080×1920 |
| Source ratio, editing | Long side 640, short side multiple of 32 | Long side 1440 |

Resizing does not generate new model detail. Draft/balanced/detailed means 16/24/32 steps. The launcher uses CFG 6.0, Euler and 64×64 VAE tiles. Editing moves VAE decoding to CPU and can be slower. Q4_K is the default for 16GB. Do not run another local model during generation.

Eight styles: portrait, product, food, landscape, architecture, fully clothed fashion, cinematic and minimal logo look. Style 0 leaves out the style preset. Logos remain raster images, not vector files.

Fourteen effects: Clarendon, Valencia, Gingham, Juno, Lark, cinematic, film/Portra, monochrome, VSCO A6/C1/M5, Kodak Ektar, golden hour and noir. These are FFmpeg approximations, not the brands' proprietary LUT packages.

An empty seed uses random (`-1`). Matching seeds/models/settings help comparisons; bit-identical output across engine/hardware versions is not promised. Output: `$BOZKURT_WORKSPACE/Bozkurt-Gorseller`; technical logs: `gunlukler/`.

## Add a general-purpose LoRA

1. Select a style/product/illustration adapter compatible with **Qwen Image 2.1**, with appropriate usage rights. Read its model card.
2. Place its `.safetensors` file locally in `modeller/model-arsivi/qwen-image-2.1/loras/`. Prefer simple filenames; do not commit the file.
3. Select it in the image menu. LoRA defaults to off; strength defaults to 0.8, allowed range 0.1–1.5.
4. Test with 16 steps and a small canvas. If it fails, disable the adapter and retry the same request.

Adapters with unreadable header metadata or NSFW/NCII markers are excluded. Metadata inspection is not an image-content classifier and cannot guarantee every output. This distribution contains no adult presets, private facial descriptions or instructions to restore them. This extension guide covers general-purpose adapters.
