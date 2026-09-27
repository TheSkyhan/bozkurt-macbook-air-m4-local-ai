# Model files / Model dosyaları

**TR:** Ağırlıklar ve üçüncü taraf motorlar bu depoya yüklenmez. Aşağıdaki adlar mevcut profillerin beklediği dosya adlarıdır; tümü resmî Qwen sürümü anlamına gelmez. Qwen metin ve Lucifer profilleri üçüncü taraf türev model adlarını kullanır. Model kartını, lisansı ve kaynağını indirmeden önce inceleyin. Kaynağı doğrulanmayan alternatif türevler için otomatik indirme komutu eklenmemiştir.

**EN:** Weights and third-party engines are not uploaded. Names below are filenames expected by the bundled profiles, not a claim that every derivative is an official Qwen release. The Qwen text and Lucifer profiles name third-party derivatives. Check provenance, model cards and licenses before downloading. Unverified derivative sources intentionally have no automatic download command.

## Bonsai (recommended first setup / ilk kurulum)

Follow [installation TR](INSTALL.tr.md) / [installation EN](INSTALL.en.md).

- Expected file: `motorlar/Bonsai-demo/models/bonsai2-gguf/27B/Ternary-Bonsai-2-27B-PQ2_0.gguf`.
- [Bonsai upstream](https://github.com/PrismML-Eng/Bonsai-demo), [model card](https://huggingface.co/prism-ml/Ternary-Bonsai-2-27B-gguf).
- Engine checkout: `17b143e889a45c090816b520e79a50c996164e1f`.
- Use the matching PrismML engine, not stock llama.cpp for this packing.

## Optional text profiles / İsteğe bağlı metin profilleri

| Menu | Expected path relative to repository root |
|---|---|
| Qwen (3) | `modeller/GGUF/Q8/Qwen3.8-9B-Distill-Heretic-GGUF/Qwen3.8-9B-Distill-Heretic-Uncensored-Q8_0.gguf` |
| Lucifer (2) | `modeller/model-arsivi/lucifer-orcarouter-27b/orcarouter_Qwen3.8-27B-Uncensored-IQ2_M.gguf` |

TR: Bu dosyalara sahip değilseniz mod 1/4 ile başlayın. Başka uyumlu GGUF kullanacaksanız ilgili başlatıcıdaki `MODEL`, menüdeki sağlayıcı/model seçimi ve `.runtime/pi/models.json` kimliğini birlikte güncelleyin. Bağlamı modelinizin gerçek kapasitesine göre ayarlayın; dosyayı yalnız eski isimle yeniden adlandırmak uyumluluk sağlamaz.

EN: If you do not have these files, start with modes 1/4. To use another compatible GGUF, update the launcher's `MODEL`, the menu provider/model selection and `.runtime/pi/models.json` together. Match context limits to the actual model; renaming another model to an old filename does not establish compatibility.

Reference Homebrew llama.cpp: `0.5.0`, build `11146`, commit `7fe450e19`. Newer builds can change CLI flags. Set `BOZKURT_LLAMA_BIN` to a compatible executable if needed. [llama.cpp upstream](https://github.com/ggml-org/llama.cpp).

## Qwen Image 2.1

Build the pinned image engine / Sabit görsel motorunu derleyin:

```bash
git clone --recursive https://github.com/leejet/stable-diffusion.cpp.git motorlar/qwen-image-backend
git -C motorlar/qwen-image-backend checkout 6dcb5bbd4278aa8f6d851f7515e87555f8e757b7
git -C motorlar/qwen-image-backend submodule update --init --recursive
cmake -S motorlar/qwen-image-backend -B motorlar/qwen-image-backend/build-metal -DSD_METAL=ON
cmake --build motorlar/qwen-image-backend/build-metal --config Release -j 4
```

Store the following under `modeller/model-arsivi/qwen-image-2.1/`:

| Subdirectory / Alt klasör | Filename / Dosya | Source / Kaynak |
|---|---|---|
| `diffusion_models/` | `qwen_image_2.1-Q4_K.gguf` | [leejet](https://huggingface.co/leejet/Qwen-Image-2.1-GGUF/tree/main) |
| `text_encoders/` | `Qwen3VL-8B-Instruct-Q4_K_M.gguf` | [Qwen GGUF](https://huggingface.co/Qwen/Qwen3-VL-8B-Instruct-GGUF/tree/main) |
| `text_encoders/` | compatible vision projector | [Qwen GGUF](https://huggingface.co/Qwen/Qwen3-VL-8B-Instruct-GGUF/tree/main) |
| `vae/` | `qwen_image_2.1_vae_bf16.safetensors` | [Comfy-Org](https://huggingface.co/Comfy-Org/Qwen-Image-2.1/tree/main/vae) |

TR: Düzenlemede görsel projektörü gerekir. Başlatıcı referans kurulumun Q8_0 projektör adını bekler (`mmproj-Qwen3VL-8B-Instruct-Q8_0.gguf`). Kaynakta F16/BF16 sürümü varsa `VISION_PROJECTOR` yolunu gerçek dosyaya uyarlayın; kuantizasyonu sadece dosya adını değiştirerek dönüştürmeyin. F16 daha fazla bellek kullanabilir ve 16 GB düzenleme profiliyle ayrıca denenmelidir. Önce metinden görsel veya yalnız efekt moduyla başlayabilirsiniz. VAE, Qwen Image 2.1'e ait olmalıdır.

EN: Editing requires a matching vision projector. The launcher expects the reference installation's Q8_0 filename (`mmproj-Qwen3VL-8B-Instruct-Q8_0.gguf`). If your source provides F16/BF16, set `VISION_PROJECTOR` to the real file; renaming does not quantize it. F16 may require more memory and needs separate validation for 16GB editing. Start with text-to-image or effects-only if needed. Use the Qwen Image 2.1 VAE.

[Upstream Qwen Image 2.1 instructions](https://github.com/leejet/stable-diffusion.cpp/blob/master/docs/qwen_image_2.1.md) · [Build instructions](https://github.com/leejet/stable-diffusion.cpp/blob/master/docs/build.md).

TR: Model kartı ve indirme sayfasındaki dosya adları değişebilir; kurulu motorun sürümüyle uyumu kontrol edin. EN: Filenames and availability can change; verify compatibility with your engine revision. Model downloads and licenses are independent of this source package.
