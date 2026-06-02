# 🎉 FoodIQ v1.2.0 — Bug fixes & live analytics

**Build date:** 2026-06-02
**Build platform:** Flutter 3.24.5 / Dart 3.5.4 / Android SDK 35 / JDK 17

---

## 📥 Direct Downloads

### 📱 APK
👉 **https://gofile.io/d/ZoJ28S**

- **File:** `FoodIQ-v1.2.0.apk`
- **Size:** 26 MB
- **MD5:** `b23968717e58f1fd94d76805ba2dbbda`
- **Package:** `com.foodiq.foodiq`
- **versionCode:** 4 — **versionName:** 1.2.0
- **Min Android:** 5.0 (API 21)
- **Target Android:** 14 (API 34)

### 📦 Source ZIP
👉 **https://gofile.io/d/8ZqQCk**

### 🐙 GitHub
👉 **https://github.com/tomassefiiw-cloud/FoodIQ**
Latest commit: `a71c4fc`

---

## 🐛 Bugs you reported — all fixed

### 1. **Gemini camera says "quota reached"** ✅
The free `gemini-2.0-flash` tier ran out (200 RPD daily limit). v1.2.0:
- **Downgraded primary model** to `gemini-2.5-flash-lite` — same accuracy, **much higher free quota** (30 RPM, 1,500 RPD).
- **Added automatic fallback chain** — if any model returns 429, the app silently tries the next one:
  `gemini-2.5-flash-lite` → `gemini-flash-lite-latest` → `gemini-2.0-flash-lite` → `gemini-2.0-flash` → `gemini-2.5-flash`
- If all 5 hit quota, the camera shows a clear "All AI vision models reached quota" message (not a generic error).

### 2. **Analytics not working properly / not updating** ✅
The previous analytics screen was **literally hardcoded** (showed "1,850 kcal/day" no matter what you logged). v1.2.0 has a complete rewrite:
- **Daily tab**: live macro pie chart (Protein / Carbs / Fat / Fiber), calorie + water progress cards, meal breakdown (breakfast / lunch / dinner / snack).
- **Weekly tab**: bar chart of last 7 days with goal line, average + total + days-on-track, average macros.
- **Monthly tab**: bar chart of last 30 days, same stats.
- **Real-time updates**: every log entry (camera, manual, browse) now invalidates `todayCalorieSummaryProvider`, `weeklyCalorieLogsProvider`, AND `monthlyCalorieLogsProvider` — so the analytics refresh **instantly**.
- Pull-to-refresh on every tab + dedicated refresh button in the app bar.

### 3. **AI chat helping questions invisible in dark mode** ✅
The quick-question chips used `AppColors.primaryBg` (a light cream) which blended into the dark background.
- Now uses orange tint (`primary.withOpacity(0.18)`) in dark mode + bold orange text + thicker orange border.
- Light mode unchanged.

### 4. **Notifications not appearing on status bar** ✅
The v1.1.0 notification channel was created with `Importance.high`, but Android **never lets you change a channel's importance after creation**. Even though v1.1 set Max in code, the actual channel on your device stayed at the old level.
- **Bumped channel ID to `foodiq_meal_reminder_v2`** — Android sees this as a new channel and creates it fresh with `Importance.max`.
- Old `_v1` channel is explicitly deleted on app start.
- Notification details now include: `priority: Priority.max`, `visibility: public`, `category: reminder`, `ticker`, and `BigTextStyleInformation` with the full body — so they pop as **heads-up notifications** + appear on the lock screen + show in the navigation/status bar.
- Exact alarms requested via both `permission_handler` AND the native plugin (covers OEM ROMs that ignore one or the other).
- If exact-alarm permission is blocked (Android 14+), the app **gracefully falls back to inexact alarms** instead of failing silently.

### 5. **Timezone must strictly follow OS** ✅
The notification service now uses a **3-strategy detection chain**:
1. `flutter_timezone` plugin reads the OS's IANA name directly (e.g. `Africa/Addis_Ababa`)
2. If that fails, match the device's current UTC offset to a known IANA zone in the database
3. If that fails, fall back to `Etc/GMT±N` (with **correctly inverted POSIX sign** — UTC+3 maps to `Etc/GMT-3` not `Etc/GMT+3`)
4. Last resort: `UTC`

The current detected timezone is shown in Settings → About for debugging.

---

## 📲 Install on your phone

1. **Open https://gofile.io/d/ZoJ28S on your phone** → tap Download.
2. **Open the downloaded `FoodIQ-v1.2.0.apk`** in your notifications.
3. If Android blocks it: Settings → Apps → Special access → Install unknown apps → allow your browser.
4. **Tap Install** → done.
5. **Important for notifications**: when first asked, grant "Notifications" permission. On Android 14+, if reminders don't fire reliably, also go to Settings → Apps → FoodIQ → Notifications → Reminders → allow "Alarms & reminders".

If you have v1.0.0 or v1.1.0 installed, this will update in place — your account & data stay safe.

---

## 🗄️ Don't forget your Supabase setup

If sign-up still doesn't work, paste [`supabase_schema.sql`](https://github.com/tomassefiiw-cloud/FoodIQ/blob/main/supabase_schema.sql) into your Supabase SQL Editor → Run.

---

## 🔬 Test these specifically

After installing v1.2.0:

1. **Camera AI** → take a photo of food. Even if Gemini is at quota, the app will try 4 more models automatically. Worst case you'll see a clear message.
2. **Analytics** → log a food, then open the Analytics tab. The pie chart and the daily total update immediately.
3. **Dark mode** → open AI chat. The quick-question chips should be clearly visible in orange.
4. **Notifications** → Settings → toggle Meal Reminders ON. You should immediately get a test notification on your status bar. Then check Settings → Apps → FoodIQ → Notifications and confirm the "Meal Reminders" channel exists with importance "Urgent".
5. **Timezone** → Settings → About should show your real timezone (e.g. `Africa/Addis_Ababa`).
