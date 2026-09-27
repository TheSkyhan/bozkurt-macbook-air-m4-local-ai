# Dependencies and attribution / Bağımlılıklar ve atıf

Bozkurt provides integration code and configuration around independent upstream projects. Their source trees, binaries and model weights are not redistributed here.

| Component | Reference | Role |
|---|---|---|
| Pi coding agent | npm `@earendil-works/pi-coding-agent` 0.87.1 | Agent CLI, tools, sessions, themes |
| Bonsai demo | [PrismML-Eng/Bonsai-demo](https://github.com/PrismML-Eng/Bonsai-demo), revision `17b143e889a45c090816b520e79a50c996164e1f` | Bonsai-compatible model runtime |
| llama.cpp | [ggml-org/llama.cpp](https://github.com/ggml-org/llama.cpp), reference build 11146 | Qwen/Lucifer inference |
| stable-diffusion.cpp | [leejet/stable-diffusion.cpp](https://github.com/leejet/stable-diffusion.cpp), revision `6dcb5bbd4278aa8f6d851f7515e87555f8e757b7` | Qwen Image Metal backend |
| FFmpeg | [ffmpeg.org](https://ffmpeg.org/) | Color effects and resizing |
| WeasyPrint | [weasyprint.org](https://weasyprint.org/), reference 70.0 | PDF rendering |
| Open-Meteo | [open-meteo.com](https://open-meteo.com/) | Optional geocoding and weather |
| DuckDuckGo / Bing | Search services | Optional web search |
| Wikimedia Commons | [commons.wikimedia.org](https://commons.wikimedia.org/) | Optional document image discovery |

TR: Her bağımlılık ve model kendi lisansına tabidir. Model kartlarını inceleyin. Commons görsellerinin atıf/lisans gereklerini ayrıca kontrol edin; araç otomatik lisans uygunluğu garantisi vermez. Marka isimleri uyumluluk ve stil açıklaması içindir; resmî ortaklık iddiası yoktur. Bu ilk yayın için Bozkurt koduna ayrı bir açık kaynak lisansı seçilmemiştir; üçüncü taraf lisansları Bozkurt'a otomatik uygulanmaz.

EN: Each dependency and model retains its own license. Review model cards and Commons image attribution requirements; the tool does not guarantee license compliance for retrieved images. Brand names describe compatibility or style, not endorsement. No separate open-source license has been selected for Bozkurt's own code in this initial publication; upstream licenses do not automatically cover it.
