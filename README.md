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
