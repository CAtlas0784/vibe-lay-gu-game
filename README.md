# Ananta (Project Mugen) CBT 4229938 Private Server & Proxy Engine

> ฐานโค้ดนี้ได้รับการพัฒนาต่อยอด (Forked) มาจากผลงานของ **[Horoyoi-san (ngp/Ananta-DEV5)](https://github.com/horoyoi-san/ngp/tree/Ananta-DEV5)**

เซิร์ฟเวอร์ส่วนตัว (Private Server) และระบบ HTTPS/SNI Proxy สำหรับเกม **Ananta (Project Mugen / 代号：无限大)** ไคลเอนต์เวอร์ชัน **CBT 4229938** ที่พัฒนาด้วยสถาปัตยกรรม C# .NET 8 (UX-RPC Binary Protocol) ร่วมกับ Node.js Proxy เพื่อจำลองการเชื่อมต่อและเล่นเกมในโหมด Sandbox / Free-Roam ได้อย่างสมบูรณ์

---

## 📋 สรุปสถานะฟีเจอร์ของระบบ (Feature Status Matrix)

ตารางแสดงรายละเอียดฟีเจอร์ทั้งหมด แบ่งตามสถานะการทำงานจริง:

| ฟีเจอร์ / ระบบ | สถานะ | รายละเอียดการทำงาน |
| :--- | :---: | :--- |
| **Combat & Skill System (ระบบต่อสู้และสกิล)** | 🟢 ใช้งานได้สมบูรณ์ | ผสานระบบต่อสู้บริสุทธิ์ของ DRMK ยกเลิกคูลดาวน์เทียมออก โจมตีคอมโบต่อเนื่อง Basic/Heavy Attack และสกิลได้อย่างลื่นไหล ไม่ขัดจังหวะตัวเอง พร้อมคืนทรัพยากรเมื่อจบคอมโบ |
| **Authentication & MPay Bypass** | 🟢 ใช้งานได้สมบูรณ์ | บายพาสล็อกอินผ่าน MPay JavaScript Bridge ใน `NtUniSdkBase.dll` อัตโนมัติ ไม่ต้องกรอกรหัสผ่าน |
| **HTTPS Gateway & Multi-Domain Proxy** | 🟢 ใช้งานได้สมบูรณ์ | จำลอง SSL SNI บนพอร์ต 443/80 หลอกระบบอัปเดต และบีบ Contract MD5 7-column ไม่ให้ขึ้นปิดปรับปรุง |
| **World Entry (V7 4-Step Handoff)** | 🟢 ใช้งานได้สมบูรณ์ | ส่งลำดับ `SyncLogicAgentEnter` -> `SyncManagedLogicAgent` -> `SyncRaidBattleUnitSpirit` -> `SyncPlayerCurrentSpirit` -> `SyncSceneLoadCompleted` เข้าสู่เมืองได้ 100% |
| **Character Switching (สลับตัวละครคลีนแบบ DRMK)** | 🟢 ใช้งานได้สมบูรณ์ | สลับตัวละครได้ในฉากเดียวกัน ส่ง SyncLogicAgentLeave นำตัวเก่าออกจากโลกอย่างสะอาด ไม่ทิ้งร่างค้าง ไม่ล็อกการควบคุม และไม่มีปุ่ม F ลอยบนหัวตัวเรา |
| **Vehicle Boarding (ขึ้นรถด้วยปุ่ม F)** | 🟡 กำลังทดสอบ | เดินไปใกล้รถแล้วกด F เพื่อขึ้นขับได้ทันทีผ่านระบบ Story Boarding และ Vehicle Drive State โดยตรง (กำลังทดสอบในเกม) |
| **Weather & Atmosphere Control (ระบบสภาพอากาศ)** | 🟢 ใช้งานได้สมบูรณ์ | ปรับสภาพอากาศได้ 7 รูปแบบ (Sunny, Cloudy, Rain, Storm, Fog, Overcast, Night) พร้อมปรับ Transition เวลาผ่าน Web Debug Panel |
| **Map Fog Removal & Precise Teleport (ลบหมอก & วาร์ป)** | 🟢 ใช้งานได้สมบูรณ์ | ปลดล็อกหมอกแมพถาวร (`SceneFogMaps` แฟล็ก `All = true` ใน `PlayerClientInfoAchievement` + ยิง `SyncSceneFogMapAllUnlock` ทั่วทุก Scene 1, 1001, 10001) และวาร์ป 2 คลิกไม่ตกแมพ |
| **Selfie Mode Camera (โหมดเซลฟี่)** | 🟡 กำลังทดสอบ | แก้หน้าต่าง Adjustment โหลดข้อมูลท่าทางและการแสดงออกครบถ้วน ปรับ FOV มุมกล้องกว้างขึ้น (แก้ความรู้สึกลำบากเหมือนคนแขนสั้น) และออกจากโหมดแล้วท่าทางไม่ค้าง (กำลังทดสอบในเกม) |
| **Outfit Toggle (ปุ่มลัดถอดชุดเหลือร่างต้น)** | 🟣 เอ๋อ / มีข้อจำกัด | สลับถอดเสื้อผ้าได้ผ่าน Web Debug Panel แต่ปุ่มลัด F8 ยังใช้งานไม่ได้ และบางครั้งโมเดลชุดไม่ยอมหายไปสมบูรณ์ |
| **Housing System (ระบบบ้านและอพาร์ตเมนต์)** | 🟡 กำลังทดสอบ | ปลดล็อกและเปิดสิทธิ์การเป็นเจ้าของบ้าน/อพาร์ตเมนต์ทั้งหมด (`11200000`, `1001..1005`) สามารถเข้าดูและซื้อได้ (กำลังทดสอบในเกม) |
| **Retail Game Switches & Unlimited Currency** | 🟢 ใช้งานได้สมบูรณ์ | กำหนดเงินและทองเริ่มต้นเต็มพิกัด 999,999,999 (`Money`, `Gold`, `BindingGold`, `FreeGold`) ใน `PlayerClientInfoItem` พร้อมปลดล็อกระบบร้านค้าและกาชาอย่างสมบูรณ์ |
| **NPC & Monster Spawner (เสก NPC / มอนสเตอร์ / สัตว์)** | 🟢 ใช้งานได้สมบูรณ์ | รวมระบบมอนสเตอร์เข้ากับ Agent รวมศูนย์ผ่าน AgentConfig มีตารางค้นหาแยก 5 หมวดหมู่ (มอนสเตอร์/บอส, ชาวเมือง, ตำรวจ/ยาม, สัตว์, พันธมิตร) พร้อมปุ่ม [➕ Add] เสกเข้าฉากได้สมบูรณ์ |
| **Traversal & Parkour (สลิง/เกี่ยวต่อสู้/ปีนป่าย)** | 🟢 ใช้งานได้สมบูรณ์ | ปลดล็อกบัฟเคลื่อนไหวใยแมงมุม (FeiSuo / Grapple Hook / Wall Rush / Dive Damage) ให้กับทุกตัวละคร รองรับการใช้สลิงเกี่ยวต่อสู้โดยไม่หลุดจากการเชื่อมต่อ |
| **Anti-Cheat Suppression** | 🟢 ใช้งานได้สมบูรณ์ | ดักปิด `DavinciReport`, `DavinciMgr.CheckTimeScale` (แก้บัค Connection Lost เวลาสลิงเกี่ยวหรือเกิด Slow Motion) และดูดซับ `GmDaVinciCode` ฝั่งเซิร์ฟเวอร์ |
| **Camera & Cinemachine Handling** | 🟢 ใช้งานได้สมบูรณ์ | จัดการทรานซิชันมุมกล้อง Cinemachine ระหว่างการเคลื่อนไหว สลับตัวละคร และโหมดอิสระ ปิดการ Force Debug Photo ที่เคยกวนระบบกล้องเกมหลัก |
| **RAM Warmup OOM Prevention** | 🟢 ใช้งานได้สมบูรณ์ | ปิดการสั่งคอมไพล์ 11,384 PSO Shaders รวดเดียว ลดเวลาโหลดจาก 40 วิเหลือ 0.01 วิ และไม่กินแรม 16-19GB จนเกมแครช |
| **Web Debug Panel (`:5809/debug`)** | 🟢 ใช้งานได้สมบูรณ์ | แดชบอร์ดเว็บสำหรับวาร์ปตามพิกัด (Teleport), ปรับเวลาและสภาพอากาศ, เสกเอนทิตี/มอนเตอร์, ถอดชุด, และสั่งงานระบบต่างๆ |
| **Safe Fastpatch Loader** | 🟢 ใช้งานได้สมบูรณ์ | ตัวสร้าง `fastpatch_4229938.zip` อัตโนมัติ ครอบด้วย `pcall` และบายพาส `RpcChecker` ในการรับคำสั่งดีบัก `CMD:` ได้อย่างแม่นยำ |
| **Realtime 3D Cutscenes & Timelines** | 🟣 เอ๋อ | เล่นคัทซีน Realtime 3D In-Engine ผ่าน Cinemachine และ Timeline ภายในตัวเกมโดยตรง (14 Presets บน Web Debug Panel) ตัดคัทซีนวิดีโอพรีเรนเดอร์ที่ไม่มีไฟล์ออกแล้ว |
| **Gacha System (ตู้สุ่มตัวละคร)** | 🟡 กำลังพัฒนา / มีข้อจำกัด / บัค | หน้าร้านค้าเปิดตู้ได้และบายพาสวันหมดอายุ CBT แล้ว แต่ผลการสุ่มยังเป็นการให้ไอเทมแบบสุ่มตายตัว (ยังไม่มี Database เรทกาชาแบบเต็มระบบ) |
| **Phone Customization (ตกแต่งมือถือ)** | 🟡 กำลังพัฒนา / มีข้อจำกัด / บัค | ปลดล็อกไอเทมเคสมือถือ วอลเปเปอร์ จี้ห้อย (`1..200`) ในหน่วยความจำ แต่ยังไม่บันทึกความเปลี่ยนแปลงข้าม Session แบบถาวร |
| **Monster Combat AI & Aggro** | 🔴 ยังทำไม่ได้ / วางแผนไว้ | มอนเตอร์ที่เสกออกมาจะยืนนิ่งหรือเคลื่อนที่พื้นฐาน ยังไม่มี Behavior Tree เชิงรุกเข้าโจมตีผู้เล่น (ต้องรอเขียน Combat AI Loop ฝั่งเซิร์ฟเวอร์) |
| **Multiplayer Co-op (เล่นด้วยกันหลายคน)** | 🔴 ยังทำไม่ได้ / วางแผนไว้ | ปัจจุบันเซิร์ฟเวอร์รองรับการเข้าเล่นแบบคนเดียว (Local Single-Player Sandbox) ระบบ Broadcast ผู้เล่นอื่นในฉากเดียวกันอยู่ใน Roadmap |
| **Main Story Quest Engine** | 🔴 ยังทำไม่ได้ / วางแผนไว้ | เควสต์เนื้อเรื่องหลักยังไม่เปิดใช้งาน เนื่องจากต้องใช้ State Machine และ Triggers ที่ผูกกับ Script เควสต์ขนาดใหญ่ |
| **In-game Shop Real Money** | 🔴 ไม่ทำ (ปิดถาวร) | ระบบเติมเงินจริงถูกปิดไว้ถาวรเพื่อความปลอดภัย ปลดล็อกของทั้งหมดให้ฟรีผ่าน Sandbox แทน |
| **City Traffic & Crowd Simulation** | 🔴 อยู่ในแผนพัฒนา | การจำลองฝูงชนและรถยนต์สัญจรแบบหนาแน่นทั้งเมืองปิดไว้ชั่วคราว เพื่อประหยัด CPU และ Memory |

---

## 🛠️ ความต้องการของระบบ (Prerequisites)

1. **Windows 10 / 11 (64-bit)**
2. **.NET 8.0 SDK**: [ดาวน์โหลดที่นี่](https://dotnet.microsoft.com/download/dotnet/8.0)
3. **Node.js (LTS v18 หรือ v20 ขึ้นไป)**: [ดาวน์โหลดที่นี่](https://nodejs.org/)
4. **Git & Git LFS**: [ดาวน์โหลดที่นี่](https://git-lfs.com/)
5. ตัวเกม **Ananta / Project Mugen (CBT Client build 4229938)**

---

## 🚀 วิธีติดตั้งและเปิดใช้งานเซิร์ฟเวอร์

### 1. Clone Repository (จำเป็นต้องใช้ Git LFS)
```bash
git clone https://github.com/CAtlas0784/vibe-lay-gu-game.git
cd vibe-lay-gu-game
git lfs pull
```

### 2. ติดตั้ง Certificate & Hosts
รันคำสั่งด้วย PowerShell (Administrator) เพื่อชี้โดเมน NetEase เข้าหาเซิร์ฟเวอร์เครื่องคุณ (`127.0.0.1`):
```powershell
powershell -ExecutionPolicy Bypass -File .\Ananta.Proxy\SETUP_PROXY_AS_ADMIN.ps1
```
*(หากต้องการยกเลิกการตั้งค่า Hosts ในภายหลัง สามารถรัน `REMOVE_PROXY_HOSTS_AS_ADMIN.ps1`)*

### 3. เปิดเซิร์ฟเวอร์
ดับเบิลคลิกเปิดใช้งานผ่านไฟล์:
```cmd
START.cmd
```
หรือรันผ่าน PowerShell:
```powershell
powershell -ExecutionPolicy Bypass -File .\Run-All.ps1
```
เมื่อขึ้นข้อความ `[READY]` แสดงว่าทั้ง **Node.js Proxy** (พอร์ต 443/80) และ **C# Game Server** (พอร์ต 5200-5202) พร้อมทำงานเรียบร้อยแล้ว

### 4. เข้าเล่นเกม
- เปิดไฟล์ `Ananta.exe`
- ตัวเกมจะผ่านหน้า Splash และหน้า `Initializing game` เข้าสู่หน้าจอหลัก
- กดเริ่มเกม ตัวเกมจะทำการบายพาสล็อกอินและนำตัวละครเข้าสู่โลก Sandbox ทันที!

### 5. หน้าต่าง Debug Panel
ระหว่างที่เปิดเซิร์ฟเวอร์ สามารถเปิด Browser ไปที่:
```text
http://localhost:5809/debug
```
เพื่อใช้วาร์ปไปยังจุดต่าง ๆ ในเมือง, ปรับเวลา, เปลี่ยนสภาพอากาศ, หรือเสกเอนทิตี

---

## 📁 โครงสร้างโปรเจกต์ (Project Structure)

```text
vibe-lay-gu-game/
├── Ananta.Proxy/             # Node.js HTTPS Multi-Domain Proxy & Fastpatch Generator
│   ├── proxy/
│   │   ├── certs/            # ใบรับรอง SSL สำหรับดักโดเมน NetEase
│   │   ├── public/           # Static config, version JSON, serverlist, fastpatch.zip
│   │   ├── tools/            # generate_client_config_patch.js (ตัวฉีด Lua Hooks)
│   │   └── server.js         # Proxy Server หลัก
├── Ananta.SDK/               # โค้ด Core Network Frame, Crypto (ChaCha8), และ UxRpc Message
├── Ananta.Server/            # C# .NET 8 UX-RPC Game Server
│   ├── Ananta.App/           # Console Entrypoint, Session Hub & Debug Web Panel
│   ├── Ananta.Core/          # Client Data Repositories, Wire Codecs & World State
│   ├── Ananta.Gameplay/      # ระบบ Traversal, Web Swing & Buff Handlers
│   ├── Ananta.Handlers/      # RPC Handlers (World, Switching, Gm, Vehicles, Fashion, Gacha)
│   ├── Ananta.Network/       # TCP Listener & Rpc Frame Dispatcher
│   └── ClientData/4229938/   # ไฟล์ Database Configs ของเกม (Json, LFS)
├── config/                   # private-server.json (ตั้งค่าพอร์ต, ไอดีตัวละคร, บัฟ)
├── Run-All.ps1               # สคริปต์อัตโนมัติ (Fastpatch -> Build -> Launch)
├── START.cmd                 # ตัวเปิดเซิร์ฟเวอร์แบบ All-in-One คลิกเดียวจบ
└── .gitattributes            # กำหนด Git LFS สำหรับ SceneitemConfig.json (135 MB)
```

---

## ⚠️ ข้อควรระวังและการแก้ปัญหา (Troubleshooting)

- **เกมค้างหน้า "Initializing Game" หรือ "Initialize Client"**: ตรวจสอบให้แน่ใจว่าได้ใช้ `fastpatch_4229938.zip` ที่สร้างจาก `generate_client_config_patch.js` เวอร์ชันล่าสุด ซึ่งครอบ `pcall` และไม่มีคำสั่งเรียก property ของ C# โดยตรง
- **พอร์ตชน (Ports already in use)**: หากมี Process เก่าค้างอยู่ สามารถปิด Node.js หรือ dotnet ที่ค้างผ่าน Task Manager หรือรัน `Stop-Process -Name node, Ananta.App -Force`
- **ดาวน์โหลดไม่ผ่าน / ติด LFS Bandwidth**: ตรวจสอบว่า `git lfs pull` ดึงไฟล์ `SceneitemConfig.json` ขนาด 135 MB มาครบถ้วน (ไฟล์ต้องไม่ใช่ Pointer text ขนาด 130 bytes)

---

## ⚖️ ข้อกำหนดและเงื่อนไข (Disclaimer)
โปรเจกต์นี้จัดทำขึ้นเพื่อการศึกษาด้าน Reverse Engineering, Network Protocol Emulation และการอนุรักษ์ซอฟต์แวร์ (Software Preservation) เท่านั้น ไม่มีส่วนเกี่ยวข้องกับ NetEase Games หรือ Naked Rain แต่อย่างใด ห้ามนำไปใช้ในเชิงพาณิชย์
