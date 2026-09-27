import { existsSync, readFileSync, readdirSync } from "node:fs";
import { join } from "node:path";
import type { ExtensionAPI, ExtensionCommandContext } from "@earendil-works/pi-coding-agent";

const ROOT = process.env.BOZKURT_ROOT!;

// Araç ve eklentiler için kısa, kullanıcı dostu açıklamalar (dosya ad → açıklama).
const ARAclar: Record<string, string> = {
  "web_oku.py": "web_oku — gerçek kaynak sayfasını okur",
  "hesapla.py": "hesapla — doğrulanmış aritmetik",
  "sistem_dogrula.py": "kurulum sağlık testleri",
  "google_arama.py": "web_arama — DuckDuckGo/Bing ile güncel web araması",
  "hava_durumu.py": "hava_durumu — belirtilen şehirden bugün/yarın/hafta hava",
  "pdf_uret.py": "pdf_uret — Markdown/HTML → A4 dergi düzeni PDF (sayfa numaralı)",
  "belge_yaz.py": "belge_yaz — uzun metni bölüm bölüm .md dosyasına biriktirir",
  "wp_render.py": "WeasyPrint render yardımcı (pdf_uret içi)",
  "son_durum_raporu.py": "canlı kurulum doğrulamasını JSON raporlar",
};
const EKL: Record<string, string> = {
  "gptoss-arastirma.ts": "web_arama · hava_durumu · pdf_uret · belge_yaz araçları (modül başına allowlist)",
  "otonom-calisma.ts": "İstek bazlı araç sayacı ve hata tekrar koruması",
  "bozkurt-oturum-arayuz.ts": "Sohbet oturumu arayüzü (başlık/durum)",
  "bozkurt-yerel.ts": "Yerel uygulama listesi, pencere başlıkları ve uygulama açma",
  "bozkurt-gezgin.ts": "Bu eklenti — /beceriler /araclar /eklentiler /modeller /komutlar",
};

function frontmatter(yol: string): { name: string; desc: string } {
  try {
    const s = readFileSync(yol, "utf8");
    const m = s.match(/^---\n([\s\S]*?)\n---/);
    let name = "", desc = "";
    if (m) {
      const nm = m[1].match(/^name:\s*(.+)$/m);
      const dm = m[1].match(/^description:\s*"?([\s\S]*?)"?\s*$/m);
      name = nm ? nm[1].trim() : "";
      desc = dm ? dm[1].replace(/\s+/g, " ").trim() : "";
    }
    return { name: name || "—", desc: desc.slice(0, 160) };
  } catch { return { name: "—", desc: "" }; }
}

// Her liste kalıcı + kaydırılabilir bir panelde gösterilsin (notify geçici toast yerine).
// Bir öğe seçilince, o öğenin NE İŞE YARADIĞINI ve nası kullanıldığını açıkça göster — sessiz aksiyon yok.
async function goster(ctx: ExtensionCommandContext, baslik: string, satirlar: string[], aciklama?: (secilen: string) => string) {
  if (satirlar.length === 0) { ctx.ui.notify(baslik + " — kayıtlı öğe yok", "info"); return; }
  const secilen = await ctx.ui.select(baslik + "  (" + satirlar.length + ")  ·  detay için seç, kapatmak için Esc", satirlar);
  if (secilen && aciklama) ctx.ui.notify(aciklama(secilen), "info");
}

// Seçilen beceri/araç için "bu ne yapar" metni üret.
function beceriAciklama(secilen: string): string {
  const ad = secilen.split(" — ")[0].trim();
  const d = join(ROOT, "beceriler", ad, "SKILL.md");
  let govde = "";
  try { govde = readFileSync(d, "utf8").replace(/^---[\s\S]*?---/, "").trim().slice(0, 400); } catch {}
  return `🧩 "${ad}" becerisi:\n${govde || secilen}\n\nNOT: Bu bir görüntüleyici — beceri kendiliğinden ÇALIŞMAZ. İlgili görevi yazınca model otomatik kullanır; elle yüklemek istersen /skill:${ad} yaz.`;
}

function becerilerSatirlar(): string[] {
  const d = join(ROOT, "beceriler");
  if (!existsSync(d)) return [];
  return readdirSync(d, { withFileTypes: true })
    .filter((e) => e.isDirectory() && existsSync(join(d, e.name, "SKILL.md")))
    .map((e) => { const f = frontmatter(join(d, e.name, "SKILL.md")); return `${f.name} — ${f.desc}`; })
    .sort();
}
function araclarSatirlar(): string[] {
  const d = join(ROOT, "araclar");
  if (!existsSync(d)) return [];
  return readdirSync(d).filter((f) => f.endsWith(".py"))
    .map((f) => `${f.replace(".py", "")} — ${ARAclar[f] || "yerel araç"}`).sort();
}
function eklentilerSatirlar(): string[] {
  const d = join(ROOT, "eklentiler");
  if (!existsSync(d)) return [];
  return readdirSync(d).filter((f) => f.endsWith(".ts"))
    .map((f) => `${f} — ${EKL[f] || "eklenti"}`).sort();
}
function modellerSatirlar(): string[] {
  try {
    const p = join(process.env.PI_CODING_AGENT_DIR || join(ROOT, ".runtime", "pi"), "models.json");
    const d = JSON.parse(readFileSync(p, "utf8"));
    const out: string[] = [];
    for (const [ad, obj] of Object.entries<any>(d.providers || {}))
      for (const m of obj.models || []) out.push(`${ad}/${m.id} — ${m.name || ""} · ctx ${m.contextWindow}`);
    return out.sort();
  } catch { return []; }
}

export default function (pi: ExtensionAPI) {
  const komut = (ad: string, aciklama: string, satirlar: () => string[], baslik: string, detay?: (s: string) => string) =>
    pi.registerCommand(ad, {
      description: aciklama,
      handler: async (_args: string, ctx: ExtensionCommandContext) => { await goster(ctx, baslik, satirlar(), detay); },
    });

  komut("beceriler", "Becerileri (skills) listele", becerilerSatirlar, "🧩 Beceriler · görevle ilgili olunca otomatik yüklenir, bağlam şişirmez", beceriAciklama);
  komut("araclar", "Araçları (tools) listele", araclarSatirlar, "🔧 Araçlar");
  komut("eklentiler", "Eklentileri (extensions) listele", eklentilerSatirlar, "🔌 Eklentiler");
  komut("modeller", "Yapılandırılmış modelleri listele", modellerSatirlar, "🧠 Modeller");

  pi.registerCommand("komutlar", {
    description: "Bozkurt sistem haritası (beceri + araç + eklenti + model)",
    handler: async (_args: string, ctx: ExtensionCommandContext) => {
      const grup = (baslik: string, satirlar: string[]) => [`── ${baslik} (${satirlar.length}) ──`, ...satirlar.map((s) => "  " + s)];
      const hepsi = [
        ...grup("🧩 Beceriler", becerilerSatirlar()), "",
        ...grup("🔧 Araçlar", araclarSatirlar()), "",
        ...grup("🔌 Eklentiler", eklentilerSatirlar()), "",
        ...grup("🧠 Modeller", modellerSatirlar()),
      ];
      await goster(ctx, "🗺️ Bozkurt Sistem Haritası", hepsi);
    },
  });
}
