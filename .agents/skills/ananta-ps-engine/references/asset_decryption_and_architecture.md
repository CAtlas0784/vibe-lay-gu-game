# NetEase Ananta Asset Decryption, UXRPC Protocol & Codebase Architecture Reference

เอกสารอ้างอิงเชิงลึกทางสถาปัตยกรรมที่ได้จากการ Reverse Engineering ซอร์สโค้ด Decompiled (`Assembly-CSharp`, `L50Game.dll`, `Auto.Client.dll`), ถอดรหัสโครงสร้าง VFS/DecryptionVault, และโปรโตคอล UXRPC ของเกม Project Mugen / Ananta CBT 4229938

---

## 1. การเข้ารหัส Asset และโครงสร้าง L50 VFS (`DecryptionVault`)

NetEase L50 Engine ใช้ระบบจัดเก็บ Asset แบบ Virtual File System (VFS) ผ่านคอนเทนเนอร์ไฟล์ `.vfc` และไฟล์ดัชนีสารบัญ `ipa_header.ehd`:

### คีย์และอัลกอริทึม (Keys & Magics)
- **V8 Index XOR Key (16 Bytes)**:
  `CF DD A2 4D 1E 83 96 4C 63 98 BB 3B 25 B6 3D C1`
  - ทำการ XOR เฉพาะช่วงไบต์ 8–23 ของแต่ละเรคอร์ด (40 ไบต์) เพื่อถอดรหัส `int64 offset`, `int32 size`, `uint32 flags`
  - เรคอร์ดที่ถูกต้องตรวจสอบโดยไบต์ที่ `record + 8 + 4` จะตรงกับ `V8Key[12..16]`
- **Media Payloads (MP4 / Cutscene Videos)**:
  - เข้ารหัสด้วย Single-Byte XOR ค่า `0x76` ทั้งไฟล์
  - เมื่อถอดรหัส (XOR 0x76) จะพบ 4 ไบต์แรกสะกดว่า `ftyp` (มาตรฐานไฟล์ MP4)
- **Pse Texture Container (`.pse`)**:
  - เมจิกเฮดเดอร์: `50 73 65 00 00 00` (`Pse\0\0`)
  - โครงสร้างเพย์โหลด: บล็อกสตรีม **Raw LZ4 Blocks** ที่แต่ละบล็อกขยายออกมาได้สูงสุด **128 KiB (`0x20000`)**
  - **กฎสำคัญ**: แต่ละก้อน 128 KiB เป็นอิสระจากกัน (Independent Chunks) ห้ามใช้ Back-reference ข้าม Chunk เด็ดขาด
- **Network Heartbeat Key (ChaCha20)**:
  `58 2D 21 AF 6C C4 CC A0 8E EC 0D 9D 58 CD A1 E8 66 E8 37 1D 1E 61 23 9B 8D 60 B7 B2 44 FC`
  - Counter = 1, Nonce = 0 ใช้สำหรับ Online Heartbeat / SignedKeys

---

## 2. โครงสร้าง UXRPC Serialization & Services

โปรโตคอลการสื่อสารของ Ananta ไม่ใช่ Protobuf Wire Format แต่เป็น **Ordered Binary Serialization** ผ่าน `UXBinaryWriter` และ `UXBinaryReader` โดยแยกออกเป็น 25 เซอร์วิสหลัก:

### บริการและรหัสเซอร์วิสสำคัญ (Service IDs)
| Service ID | ชื่อเซอร์วิส C# | หน้าที่ / ขอบเขต | จำนวนเมธอด |
| :---: | :--- | :--- | :---: |
| **34** | `UX.Game.IClientToLogin` | ขอตรวจสอบเวอร์ชัน, ล็อกอิน, ตรวจสอบบัญชี | 15 |
| **35** | `UX.Game.ILoginToClient` | ตอบกลับคอนฟิก, ดีบั๊ก, สวิตช์เกม | 3 |
| **52** | `UX.Game.IClientToGate` | เชื่อมต่อ Gate, ส่งข้อมูลเครื่อง, ตรวจเวลา | 5 |
| **53** | `UX.Game.IGateToClient` | ซิงค์เวลาเซิร์ฟเวอร์, สถานะเซิร์ฟเวอร์ | 4 |
| **63** | `UX.Game.IClientToGame` | คำสั่งเกมเพลย์หลัก, กระเป๋า, ยานพาหนะ | 890 |
| **64** | `UX.Game.IGameToClient` | ซิงค์ข้อมูลผู้เล่น, เงิน, เควสต์, สถานะโลก | 170 |
| **65** | `UX.Game.IClientToGameGM` | **คำสั่ง GM ฝั่ง Game Player** (เงิน, ของ, สกิล, วาร์ป) | 524 |
| **67** | `UX.Game.IClientToGameScene` | ควบคุมฉาก, วาร์ป, หลบหลีก, ขับขี่ | 585 |
| **68** | `UX.Game.IGameSceneToClient` | **AOI, เสกเอนทิตี, มอนสเตอร์, ยานพาหนะ, สภาพอากาศ** | 640 |
| **69** | `UX.Game.IClientToGameSceneGM` | **คำสั่ง GM ฝั่ง Scene** (เสกมอน, รถ, จัดการฉาก) | 321 |

---

## 3. สถาปัตยกรรมเสก Monster & NPC (`RaidBattleUnitAgent`)

ไคลเอนต์สร้างเอนทิตีผ่านแพ็กเกจ `SyncRaidBattleUnitAgent` (Method ID: `68402349`) โดยรับอ็อบเจกต์ `RaidBattleUnitAgent`:
- สืบทอดจาก `RaidBattleUnitBase`:
  - `Id` (ulong): Unique Entity Instance ID
  - `TemplateId` (uint): รหัสโมเดล/สเปคตัวละคร (ตรงกับ `AgentConfig.json`)
  - `Position` (UXVector3): พิกัดในฉาก
  - `FacingDirection` (float): มุมหันหน้า
  - `OwnerId` (ulong), `ManagedPid` (ulong)
  - `MoveId` (byte), `NavTags` (uint), `GroundData` (MoveActionGroundData)
- ฟิลด์เพิ่มเติมเฉพาะของ `RaidBattleUnitAgent`:
  - `SkillId` (int), `HSummonIndex` (int), `SpoonAgentId` (int)
  - `SuitId` (uint): ชุดที่สวมใส่ (0 หรือ ID ชุด)
  - `FashionIdList` (List<uint>): เครื่องประดับ/สกิน
  - `ParentId` (ulong), `VehicleId` (ulong), `SourceWeaponId` (ulong)
  - `IsBorn` (bool), `BattleAiS` (bool): เปิดใช้งาน AI ต่อสู้
  - `WeaponId` (uint): อาวุธที่ถือ
  - `SpawnType` (AgentSpawnType): แหล่งกำเนิด
  - `AnimateCullingMode`: รูปแบบการตัดทอนแอนิเมชันตามระยะทาง
  - `AIAgentInfo`: การผูกเข้ากับระบบ Link AI ของตัวเกม

---

## 4. กลไกปลดหมอกแผนที่ถาวร (Map Fog Removal System)

ใน `MapFogDataMgr` และ `MapFogData`:
1. ไคลเอนต์ตรวจสอบหมอกผ่านคลาส `SceneFogMap`:
   - `public bool All;`: หากแฟล็กนี้เป็น `true` เมธอด `SyncAllSceneFogData` หรือ `SyncUnlockScene` จะเซ็ต `unlockedAll = true` บน `MapFogData` ทำให้หมอกทั้งแผนที่หายไปทั้งหมด
2. ช่องทางส่งข้อมูล:
   - **Login Handoff**: ผ่าน `PlayerClientInfo.InfoAchievement.SceneFogMaps` โดยตั้งค่าแต่ละ Scene (1, 1001, 10001) ให้มี `SceneFogMap { All = true }` และปลดล็อก POI ด้วย `SceneFogMapPoiIds`
   - **Dynamic Packet**: ผ่าน `SyncSceneFogMapAllUnlock` (Method ID: `64915741`) โดยระบุ `SceneId` (1, 1001, 10001) และ `Unlocked = true`

---

## 5. กลไกเงินและไอเทมในกระเป๋า (Currency & Inventory System)

ใน `PlayerClientInfo.InfoItem`:
- `Money` (double): เงินหน่วยมาตรฐาน (Credits / Cash)
- `Gold` (double): ทองพรีเมียมสำหรับหมุนตู้กาชา
- `BindingGold` (double): ทองฟรีในเกม
- `FreeGold` (double): ทองกิจกรรม
เมื่อส่งค่าเริ่มต้น เช่น `999,999,999` ผ่าน `RuntimePayloadFactory.MinimalPlayerInfo4229938()` ระบบร้านค้า กาชา และเมนูอัปเกรดทั้งหมดจะมองเห็นยอดเงินมหาศาลพร้อมใช้งานทันที
