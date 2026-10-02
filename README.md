# Trade

ไฟล์สำหรับติดตั้งบอท TradeFull (XM MT5) แบบง่าย

**วิธีใช้บน Windows / VPS:** เปิด PowerShell แล้ววางคำสั่งนี้ (MT5 ต้องติดตั้งและล็อกอินไว้แล้ว)

```powershell
irm https://raw.githubusercontent.com/mewmew752/Trade/ccr-9e2c76a8-vu39m1/setup.ps1 | iex
```

สคริปต์จะดาวน์โหลด `TradeFull_Scalper.ex5` ไปไว้ในโฟลเดอร์ `MQL5\Experts` ของ MT5,
เปิด Algo Trading และเปิดกราฟ `GOLD#` M15 พร้อมวางบอทให้

ถ้าทองในบัญชีชื่ออื่น (เช่น `GOLD`) ให้รันแบบนี้แทน:

```powershell
$env:TRADEFULL_SYMBOL='GOLD'; irm https://raw.githubusercontent.com/mewmew752/Trade/ccr-9e2c76a8-vu39m1/setup.ps1 | iex
```

## แจ้งเตือนเข้า Telegram (ไม่บังคับ)

1. ใน Telegram คุยกับ **@BotFather** → พิมพ์ `/newbot` → ตั้งชื่อ → จะได้ **token** (หน้าตาแบบ `123456789:ABC...`)
2. ใน PowerShell บน VPS รัน (เปลี่ยน `TOKEN` เป็น token ของคุณ):

```powershell
$env:TRADEFULL_TG_TOKEN='TOKEN'; irm https://raw.githubusercontent.com/mewmew752/Trade/ccr-9e2c76a8-vu39m1/setup.ps1 | iex
```

3. ใน MT5: **Tools → Options → Expert Advisors** → ติ๊ก *Allow WebRequest for listed URL* → เพิ่ม `https://api.telegram.org` → OK
4. ส่งข้อความ `/start` หาบอทของคุณใน Telegram — บอทจะจำแชทนี้แล้วเริ่มส่งข้อความ

token เก็บไว้ในเครื่อง VPS เท่านั้น (`%APPDATA%\TradeFull`) ห้ามส่ง token ให้ใคร
