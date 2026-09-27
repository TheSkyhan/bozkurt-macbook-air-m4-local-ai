import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";

function sol(text: string, width: number, theme: { fg: (t: string, v: string) => string }, sag?: string): string {
	const inner = Math.max(20, width - 2);
	let content = text;
	if (sag) {
		const bos = Math.max(1, inner - 2 - visibleWidth(text) - visibleWidth(sag));
		content = text + " ".repeat(bos) + sag;
	}
	const c = truncateToWidth(content, inner - 2, "…", true);
	return theme.fg("border", "│") + " " + c + " ".repeat(Math.max(0, inner - 2 - visibleWidth(c))) + " " + theme.fg("border", "│");
}

export default function bozkurtOturumArayuz(pi: ExtensionAPI) {
	const title = process.env.BOZKURT_OTURUM_BASLIK || "BOZKURT OTURUMU";
	const subtitle = process.env.BOZKURT_OTURUM_ALT || "Yerel yapay zekâ oturumu";

	function modelAdi(ctx: ExtensionContext): string {
		const m: any = ctx.model;
		return m ? (m.name || m.id || "?") : "?";
	}
	function ctxOzet(ctx: ExtensionContext): string {
		const u = ctx.getContextUsage?.();
		if (!u || u.tokens == null) return "";
		const yuzde = u.percent != null ? Math.round(u.percent) : Math.round((u.tokens / u.contextWindow) * 100);
		const k = (n: number) => (n >= 1000 ? (n / 1000).toFixed(1).replace(".0", "") + "k" : String(n));
		return `${yuzde}% (${k(u.tokens)}/${k(u.contextWindow)})`;
	}

	function baslik(ctx: ExtensionContext) {
		ctx.ui.setHeader((_tui, theme) => ({
			render(width: number): string[] {
				const m = modelAdi(ctx);
				const cx = ctxOzet(ctx);
				const info = `${theme.fg("muted", "model ")}${theme.fg("accent", m)}${cx ? theme.fg("muted", "  ·  ctx ") + theme.fg("success", cx) : ""}`;
				const yardim = theme.fg("dim", "ctrl+o yardım   •   / komutlar   •   esc durdur");
				if (width < 48) return [theme.bold(theme.fg("accent", `BOZKURT • ${title}`)), theme.fg("muted", subtitle), theme.fg("muted", m)];
				const inner = Math.max(20, width - 2);
				const border = theme.fg("borderAccent", "─".repeat(inner));
				const heading = `${theme.bold(theme.fg("accent", "BOZKURT"))}${theme.fg("border", "  ◆  ")}${theme.bold(theme.fg("text", title))}`;
				return [
					theme.fg("borderAccent", `╭${border}╮`),
					sol(heading, width, theme, theme.fg("muted", "bozkurt")),
					sol(theme.fg("muted", subtitle), width, theme),
					sol(info, width, theme),
					sol(yardim, width, theme),
					theme.fg("borderAccent", `╰${border}╯`),
				];
			},
			invalidate() {},
		}));
	}
	function durum(ctx: ExtensionContext, metin: string, renk = "accent") {
		ctx.ui.setStatus("bozkurt-oturum", `${theme_dot(ctx, renk)} ${ctx.ui.theme.fg("dim", metin)}`);
	}
	function theme_dot(ctx: ExtensionContext, renk: string) {
		return ctx.ui.theme.fg(renk, "●");
	}

	pi.on("session_start", (_e, ctx) => { if (ctx.mode !== "tui") return; baslik(ctx); durum(ctx, "Yerel oturum hazır"); });
	pi.on("model_select", (_e, ctx) => { if (ctx.mode === "tui") { baslik(ctx); } });
	pi.on("turn_start", (_e, ctx) => { if (ctx.mode === "tui") durum(ctx, "Yanıt üretiliyor…", "warning"); });
	pi.on("turn_end", (_e, ctx) => { if (ctx.mode === "tui") { durum(ctx, "Hazır", "success"); baslik(ctx); } });
}
