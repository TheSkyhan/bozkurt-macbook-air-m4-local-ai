import { Type } from "@earendil-works/pi-ai";
import { defineTool, type ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { execFile } from "node:child_process";
const text = (data: unknown) => ({content:[{type:"text" as const,text:JSON.stringify(data)}],details:{}});
function run(command:string,args:string[],signal?:AbortSignal):Promise<string>{
  return new Promise((resolve,reject)=>execFile(command,args,{signal,timeout:15000,maxBuffer:256000,encoding:"utf8"},(err,out)=>err?reject(err):resolve(out)));
}
export default function(pi:ExtensionAPI){
  pi.registerTool(defineTool({
    name:"uygulamalari_listele",label:"Yerel uygulamalar",
    description:"Çalışan macOS uygulamalarının adı, bundle kimliği ve PID bilgisini yerel olarak listeler. Ekran içeriği veya tarayıcı geçmişi okumaz.",
    parameters:Type.Object({}),
    async execute(_id:string,_p:any,signal:AbortSignal|undefined){
      const script='ObjC.import("AppKit"); JSON.stringify($.NSWorkspace.sharedWorkspace.runningApplications.js.filter(a => a.activationPolicy == 0).map(a => ({ad:ObjC.unwrap(a.localizedName),bundle:ObjC.unwrap(a.bundleIdentifier),pid:a.processIdentifier})))';
      return text(JSON.parse(await run('/usr/bin/osascript',['-l','JavaScript','-e',script],signal)));
    }
  }));
  pi.registerTool(defineTool({
    name:"uygulama_durumu",label:"Yerel pencere durumu",
    description:"uygulamalari_listele sonucundaki PID için pencere başlıklarını salt-okunur getirir. Tam sayfa metni veya tıklama aracı değildir. Erişilebilirlik izni yoksa bunu bildirir.",
    parameters:Type.Object({pid:Type.Integer({minimum:1})}),
    async execute(_id:string,p:any){
      const script = `tell application "System Events"
        set targetProcess to first application process whose unix id is ${p.pid}
        return get name of every window of targetProcess
      end tell`;
      return text({pid:p.pid, windows:await run('/usr/bin/osascript',['-e',script])});
    }
  }));
  pi.registerTool(defineTool({
    name:"uygulama_ac",label:"Uygulama aç",
    description:"Kullanıcının açılmasını istediği kurulu macOS uygulamasını adıyla açar. Örnek: Safari, TextEdit. Mesaj göndermez veya belgeyi değiştirmez.",
    parameters:Type.Object({ad:Type.String({minLength:1,maxLength:120})}),
    async execute(_id:string,p:any,signal:AbortSignal|undefined){
      if(p.ad.startsWith('-') || p.ad.includes('\n'))throw new Error('Geçersiz uygulama adı.');
      await run('/usr/bin/open',['-a',p.ad],signal);return text({durum:'açma isteği gönderildi',uygulama:p.ad});
    }
  }));
}
