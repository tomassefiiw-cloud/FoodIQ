# FoodIQ v1.9.0 — Release Notes

## 📥 Downloads (APK + Source on one page)
**https://gofile.io/d/BJ8QQN**
- `FoodIQ-v1.9.0.apk` — install directly on your Android phone
- `FoodIQ-v1.9.0-source.zip` — full source code

> GoFile links are temporary. The APK is also always available from
> **GitHub → Actions → latest "Build APK" run → Artifacts → FoodIQ-v1.9.0**.

---

## ✅ What's new / fixed in this release

### 1. AI Assistant now runs on Gemini + speaks Amharic 🇪🇹
- The text assistant was switched from Groq to **Gemini** using your new API key.
- I tested every model the key can access and chose **`gemini-2.5-flash-lite`** —
  it has the **highest free-tier quota** and answers fluently in Amharic.
- A model **fallback chain** auto-retries on quota (429) errors:
  `gemini-2.5-flash-lite → gemini-flash-lite-latest → gemini-2.0-flash-lite →
  gemini-2.5-flash → gemini-2.0-flash`.
- **Amharic auto-detect:** if you type in Amharic, the assistant replies entirely
  in Amharic; otherwise it replies in English. Even the offline fallback now
  answers in Amharic when you ask in Amharic.

### 2. Voice assistant 🎤 (with Amharic support)
- Added a **mic button** in the AI Assistant input bar. Tap it to speak your
  question; it transcribes into the text box and auto-sends when you finish.
- Defaults to **Amharic (am-ET)** when your device has it, and you can switch the
  voice language anytime via the **🌐 language button** in the app bar.
- Uses the device's on-board speech recognizer (`speech_to_text`), with the
  `RECORD_AUDIO` permission requested on first use.

### 3. New sign-up flow → Login → Home
- After a new user fills in their sign-up details, they're now **redirected to the
  Login page** (with their email pre-filled) instead of jumping straight in.
- They sign in there and **land on the Home/dashboard immediately**.

---

## 🔒 Everything else kept intact
Auth, dashboard, calorie ring, macros, AI food scanner (meal-name banner),
food database, manual logging, dark mode, BMI calculator (still uses its own
Groq suggestion call), weekly/monthly water stats, and the funny BMI/AI-aware
meal reminders all remain as-is.

---

## 📲 Install steps
1. Open **https://gofile.io/d/BJ8QQN** on your phone → download `FoodIQ-v1.9.0.apk`.
2. Open it from notifications and tap **Install** (allow "Install unknown apps"
   for your browser if prompted).
3. On first use of the mic, grant **Microphone** permission.
4. For best Amharic voice results, make sure your phone's Google app / speech
   services have the **Amharic** language pack installed
   (Settings → System → Languages → add Amharic).
5. Installing over an older version updates in place — your account & data stay safe.
