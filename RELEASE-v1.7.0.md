# FoodIQ v1.7.0 — Release Notes

## 📥 Downloads (APK + Source on one page)
**https://gofile.io/d/1Pe17t**
- `FoodIQ-v1.7.0.apk` — install directly on your Android phone
- `FoodIQ-v1.7.0-source.zip` — full source code

> GoFile links are temporary. The APK is also always available from
> **GitHub → Actions → latest "Build APK" run → Artifacts → FoodIQ-v1.7.0**.

---

## ✅ What was fixed in this release

### 1. The build itself now works (the real "miracle" fix)
The previous v1.6.0 builds were **failing on GitHub Actions**, so no installable
APK was ever produced. Two root causes were fixed:
- **JetifyTransform / out-of-memory failure** — `gradle.properties` had been cut
  down to `-Xmx1024m` and `compileSdk 34`. Restored the proven config
  (`-Xmx2G`, `compileSdk`/`targetSdk 35`, caching on).
- **`CardThemeData` API error** — v1.6.0 used `CardThemeData`, which only exists
  in Flutter 3.27+. Reverted to `CardTheme` so the project compiles on the
  pinned, stable **Flutter 3.24.0** toolchain used by CI.
- Both CI workflows now pin **Flutter 3.24.0** and emit a clean
  `FoodIQ-v1.7.0.apk` artifact.

### 2. Camera / Gallery — you can now SEE what the AI recognized
After the AI analyzes a photo, the meal-type sheet now shows a prominent
**"AI recognized this as → <Food Name>"** banner with the confidence %, calories,
and an Ethiopian tag — so you can confirm it got the meal right *before* logging.
- Each Breakfast / Lunch / Dinner / Snack button also names the detected food.
- A hint tells you to tap **"Skip logging"** and retake the photo if it's wrong.

### 3. Notifications — flexible, funny, appetite-driving & BMI/AI-aware
- Reminder text now **changes over time** (fresh, randomized copy each schedule)
  while keeping the breakfast / lunch / dinner context.
- Every reminder is written to be **funny and to build appetite**.
- Messages include an **AI/BMI-based meal suggestion**: foods are picked to match
  your BMI category (underweight → calorie-dense, overweight/obese → light &
  high-fiber, etc.), so reminders nudge you toward the right meal.
- The reminder text refreshes automatically whenever you recalculate your BMI.

### 4. Everything else kept intact
All existing functionality is preserved — auth, dashboard, analytics, water
tracker, AI assistant, food database, manual logging, dark mode, BMI calculator,
and the notification scheduling/repair tools.

---

## 📲 Install steps
1. Open **https://gofile.io/d/1Pe17t** on your phone → download `FoodIQ-v1.7.0.apk`.
2. Open it from your notifications and tap **Install**
   (allow "Install unknown apps" for your browser if prompted).
3. On first launch, grant **Notifications** permission.
4. On Android 12+, if reminders don't fire, also allow
   **Settings → Apps → FoodIQ → Alarms & reminders**.
5. Set your weight/height in the **BMI** screen so reminders can personalize
   their meal suggestions.

Installing over an older version updates in place — your account & data stay safe.
