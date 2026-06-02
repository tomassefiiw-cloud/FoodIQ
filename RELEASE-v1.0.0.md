# 🎉 FoodIQ v1.0.0 — Release Artifacts

**Build date:** 2026-06-02
**Build platform:** Flutter 3.24.5 / Dart 3.5.4 / Android SDK 35 / JDK 17

---

## 📥 Direct Downloads

### 📱 APK (Android, install directly on your phone)
👉 **[https://gofile.io/d/prRfPW](https://gofile.io/d/prRfPW)**

- **File:** `FoodIQ-v1.0.0.apk`
- **Size:** 25.5 MB
- **MD5:** `e8bfb1a532635a98d2023fa3a5f90337`
- **Package:** `com.foodiq.foodiq`
- **Min Android:** 5.0 (API 21) — supports ~99% of Android devices
- **Target Android:** 14 (API 34)

### 📦 Source Code (ZIP)
👉 **[https://gofile.io/d/VRlpZP](https://gofile.io/d/VRlpZP)**

- **File:** `FoodIQ-source-v1.0.0.zip`
- **Size:** 831 KB
- Clean source (no build artifacts, no dependencies)

---

## 🐙 GitHub Repository
👉 **https://github.com/tomassefiiw-cloud/FoodIQ**

Latest commit: `ad45bd7` — *Fix Flutter 3.24 compat: CardTheme, withOpacity, google_fonts 6.2.1*

---

## 📲 How to install the APK on your phone

1. **Download** the APK from the gofile link above to your Android phone.
2. **Enable installation from unknown sources:**
   - Open **Settings → Security** (or **Apps → Special access → Install unknown apps**)
   - Allow your browser (e.g. Chrome) to install apps
3. **Open the downloaded `FoodIQ-v1.0.0.apk`** — Android will ask for confirmation.
4. **Tap Install** — done! 🎉
5. **First launch** → you'll see the onboarding, then create an account.

---

## ✨ What's inside

- 🇪🇹 **Ethiopian + International food database** with calorie & macro tracking
- 📸 **AI camera food recognition** powered by Google Gemini Vision
- 💬 **AI nutrition assistant** powered by Groq llama-3.3-70b
- 📊 **Analytics dashboard** with fl_chart visualizations
- 💧 **Water tracker** with daily goal & glass count
- 🔔 **Smart meal reminders** — formal-yet-witty, appetite-building, timezone-adaptive
  - Configurable times for breakfast, lunch, dinner
  - Auto-adapts to your device's timezone
  - 24+ rotating witty reminder messages
- 🎨 **Elegant orange theme** with Poppins font, light & dark mode
- 🔐 **Secure Supabase auth** (email/password + JWT)
- 💎 **Premium subscription** (200 ETB/month — stub for payment integration)

---

## 🛠️ Tech Stack

| Layer        | Tech                                  |
|--------------|---------------------------------------|
| Mobile       | Flutter 3.24, Dart 3.5, Riverpod      |
| AI Chat      | Groq Cloud — `llama-3.3-70b-versatile`|
| AI Vision    | Google Gemini Vision (`gemini-1.5-flash`) |
| Auth + DB    | Supabase (PostgreSQL + Row Level Security) |
| Charts       | fl_chart                              |
| Notifications| flutter_local_notifications + timezone|

---

## 🗄️ Supabase database

Before users can sign up, you need to apply the schema. Open your Supabase project → **SQL Editor** → paste the contents of [`supabase_schema.sql`](https://github.com/tomassefiiw-cloud/FoodIQ/blob/main/supabase_schema.sql) → **Run**.

This creates:
- `profiles` table (extends `auth.users`)
- `foods` table with seed data (Ethiopian + international)
- `calorie_logs`, `water_logs`, `custom_foods` tables
- Row Level Security policies
- Auto-create profile trigger on signup

---

## 🔑 API keys (already embedded in APK)

The APK ships with your API keys embedded (base64-encoded in `lib/core/constants/api_keys.dart`):
- ✅ Supabase URL + anon key
- ✅ Gemini API key
- ✅ Groq API key

Users don't need to configure anything — just install and start tracking! 🚀
