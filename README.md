# Trade

ไฟล์สำหรับติดตั้งบอท **XauRsiTrend** (XM MT5, ทองคำ, กราฟ M5) แบบง่าย — แทนบอท AI ตัวเก่า (TradeFull_Scalper) ซึ่งเลิกใช้แล้ว

**วิธีใช้บน Windows / VPS:** เปิด PowerShell แล้ววางคำสั่งนี้ (MT5 ต้องติดตั้งและล็อกอินไว้แล้ว)

```powershell
irm https://raw.githubusercontent.com/mewmew752/Trade/ccr-9e2c76a8-vu39m1/setup.ps1 | iex
```

สคริปต์จะดาวน์โหลด `XauRsiTrend.ex5` ไปไว้ในโฟลเดอร์ `MQL5\Experts` ของ MT5, ลบบอทตัวเก่าออก,
เปิด Algo Trading และเปิดกราฟ `GOLD#` M5 พร้อมวางบอทให้ (กราฟ M1 เก่าปิดทิ้งได้)

ค่าที่ตั้งให้: ความเสี่ยง 0.5% ของ Equity ต่อไม้, เปิดได้หลายไม้พร้อมกันไม่จำกัด (สูงสุด 1 ไม้ต่อแท่ง M5), SL 2×ATR, TP 2.5 เท่าของ SL, หยุดเปิดไม้ใหม่ทั้งวันเมื่อขาดทุนถึง 3% ของยอดต้นวัน, ไม่เข้าเมื่อสเปรด > 50 จุด, ไม่เปิดไม้ใหม่วันศุกร์หลัง 20:00 (เวลาเซิร์ฟเวอร์), เปิดได้ทั้ง BUY และ SELL ตามเทรนด์ H1 (ปิด SELL ได้ด้วย `InpAllowShort=false`)

**บัญชีจริง:** บอทจะไม่ยอมทำงานบนบัญชีจริง เพราะผลทดสอบย้อนหลังยังไม่ผ่านเกณฑ์ (ดูรายงานใน repo TradeFull)
ใช้บน Demo ก่อน

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

บอทจะใช้แชทเดิมที่บอทตัวเก่าเคยเจอให้อัตโนมัติ ถ้าไม่มีข้อความเข้า ให้ส่ง `/start` หาบอทอีกครั้ง

token เก็บไว้ในเครื่อง VPS เท่านั้น (`%APPDATA%\TradeFull`) ห้ามส่ง token ให้ใคร
