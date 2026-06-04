# FoodIQ v2.0.0 — Release Notes

## 📥 Downloads (APK + Source on one page)
**https://gofile.io/d/H6PfeR**
- `FoodIQ-v2.0.0.apk` — install directly on your Android phone
- `FoodIQ-v2.0.0-source.zip` — full source code

> GoFile links are temporary. The APK is also always available from
> **GitHub → Actions → latest "Build APK" run → Artifacts → FoodIQ-v2.0.0**.

---

## ✅ What's new / fixed in this release

### 1. Groq fully removed → BMI now uses its own Gemini key
- All Groq code/keys were removed. The **BMI meal suggestions** now run on
  **Gemini** using the **dedicated BMI key** you provided (kept separate from the
  assistant/scanner key), with a model fallback chain on quota errors.

### 2. Chat field wraps to new lines
- The AI Assistant input now grows vertically (up to 5 lines) and wraps text to
  a **new line** when it reaches the edge, instead of scrolling sideways.

### 3. Better Amharic voice transcription
- Voice input now matches Amharic recognizers regardless of locale format
  (`am`, `am_ET`, `am-ET`) and uses longer listen windows + a pause threshold so
  a **full Amharic sentence** is captured (not just the first word).
- Tapping **stop** now sends whatever was captured (some Amharic engines don't
  emit a "final" result).
- If the phone has **no Amharic voice pack**, you now get a clear message telling
  you how to install it (Settings → System → Languages → Voice input → Amharic),
  while English voice still works and you can always type in Amharic.

### 4. Portion size in camera/gallery scans 🍽️
- After the AI recognizes a meal, you now pick a **portion size**
  (Small / Medium / Large / X-Large). Calories, protein, carbs and fat
  **recalculate live** and the chosen-portion grams + kcal are what gets logged.
- The vision prompt was upgraded to estimate the **real portion in grams** from
  the photo and return calories/macros for that exact serving (not per-100g),
  for more accurate logging.

### 5. Food database — corrected Amharic names + more foods
- Fixed many incorrect Amharic names, e.g.:
  - Quanta: ቋንቋ ("language") → **ቋንጣ**
  - Gomen: ጎሜን → **ጎመን**; Tikil Gomen → **ጥቅል ጎመን**
  - Ater Kik: አጠር → **አተር ክክ**
  - Beyaynetu spelling: በየይነቱ → **በያይነቱ** (fasting/meat/ful variants)
  - Kinche: ቂንጬ → **ቅንጬ**; Kita with honey: ከማር → **በማር**
  - Fasting Combo: የጾም ድንበር ("border") → **የጾም ምግብ**
- Added **38 new foods** with correct Amharic names — Ethiopian (Asa Wot/Tibs,
  Bozena & Tegabino Shiro, Azifa, Buticha, Shekla & Zilzil Tibs, Dulet, Kategna,
  Ergo, Ayib, Gomen be Ayib, and more) and common foods (Spaghetti/ስፓጌቲ,
  Macaroni/መካሮኒ, boiled potato/egg, salads, honey/ማር, dates/ተምር, etc.).

---

## 🔒 Everything else kept intact
Auth + sign-up→login→home flow, dashboard, calorie ring, macros, AI assistant
(Gemini + Amharic), weekly/monthly water stats, dark mode, BMI calculator, and
the funny BMI/AI-aware meal reminders all remain as-is.

---

## 📲 Install steps
1. Open **https://gofile.io/d/H6PfeR** on your phone → download `FoodIQ-v2.0.0.apk`.
2. Open it and tap **Install** (allow "Install unknown apps" if prompted).
3. Grant **Microphone** permission for voice; for Amharic voice, install the
   Amharic language pack as above.
4. Installing over an older version updates in place — your account & data stay safe.
