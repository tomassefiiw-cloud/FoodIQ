# 🎉 FoodIQ v1.1.0 — Bug fixes & new features

**Build date:** 2026-06-02
**Build platform:** Flutter 3.24.5 / Dart 3.5.4 / Android SDK 35 / JDK 17

---

## 📥 Direct Downloads

### 📱 APK (Android, install directly on your phone)
👉 **https://gofile.io/d/obf1nl**

- **File:** `FoodIQ-v1.1.0.apk`
- **Size:** 25.6 MB
- **MD5:** `fafbe898c8507da1470720b91042c7d4`
- **Package:** `com.foodiq.foodiq`
- **versionCode:** 3 — **versionName:** 1.1.0
- **Min Android:** 5.0 (API 21) — supports ~99% of Android devices
- **Target Android:** 14 (API 34)

### 📦 Source Code (ZIP)
👉 **https://gofile.io/d/druNUz**

- **File:** `FoodIQ-source-v1.1.0.zip`
- **Size:** 841 KB

### 🐙 GitHub Repository
👉 **https://github.com/tomassefiiw-cloud/FoodIQ**
Latest commit: `24a91db`

---

## 🐛 Fixed Bugs (from your reports)

### 1. **AI camera & gallery couldn't identify food** ✅
The previous version had broken key obfuscation that produced garbage API keys. Both Gemini (camera) and Groq (chat) were silently falling back to offline mode 100% of the time.
- Replaced the broken `_decode(r-1)` scheme with proper XOR+hex obfuscation.
- Verified both keys decode correctly at runtime.
- Updated the deprecated Gemini model from `gemini-1.5-flash` to `gemini-2.0-flash`.
- Camera screen now shows the *real* error message instead of a generic "could not identify". You'll see things like "No internet", "Server returned 429", or the exact Gemini error.

### 2. **AI Assistant doesn't respond** ✅
Same root cause — broken keys. Now Groq llama-3.3-70b actually receives the request and replies.
- AI Assistant is now a dedicated **bottom-nav tab** (was hidden in Profile menu).
- Online/Offline indicator now reflects the actual last reply status (no more always saying "Online").

### 3. **Dark mode not persistent** ✅
The `darkModeProvider` was a stateless `StateProvider<bool>` with no persistence.
- Converted to a `StateNotifierProvider<DarkModeNotifier, bool>` backed by `SharedPreferences`.
- Setting persists across app restarts and even reinstalls (until user clears data).

### 4. **No OS push notifications** ✅
The previous build didn't request Android 13+ `POST_NOTIFICATIONS` runtime permission, and the channel wasn't set to `Importance.max` — so even when scheduled, notifications never showed in the system tray.
- Added explicit `permission_handler` runtime request for `POST_NOTIFICATIONS` + `SCHEDULE_EXACT_ALARM`.
- Notification channel now uses `Importance.max` + `Priority.max` + `visibility: public` so they appear on the lock screen, status bar, and notification shade.
- Added `RECEIVE_BOOT_COMPLETED` permission and boot receiver in the manifest, so reminders survive phone reboots.
- App re-schedules reminders on startup if you had them enabled.

### 5. **No manual food entry** ✅
The "Custom" tab was literally a "Coming soon" placeholder.
- The Custom tab now lists your custom foods.
- "Add food" floating action button opens a beautiful bottom sheet to type in name, calories, macros, serving size.
- Optional toggle: "Also log this now" — saves the food to your library AND logs it as today's meal in one step.
- Manual foods can be deleted with confirmation dialog.

### 6. **Hard to find AI / manual entry from Home** ✅
- Replaced the `+` FAB on Home with a quick-action bottom sheet offering 4 choices:
  - 📷 **Scan with camera** (jumps to Camera tab)
  - 🍽️ **Browse food database** (opens FoodLogScreen)
  - ✏️ **Add manually** (opens FoodLogScreen on Custom tab)
  - 🤖 **Ask FoodIQ AI** (jumps to AI tab)

---

## ✨ Bottom navigation now has 5 tabs

| Tab | Icon | Purpose |
|-----|------|---------|
| Home | 🏠 | Dashboard with calories, water, today's meals |
| Stats | 📊 | Analytics charts |
| Scan | 📷 | AI camera food recognition |
| **AI** | 🤖 | **FoodIQ AI Assistant (new!)** |
| Profile | 👤 | Account, settings, premium |

---

## 📲 Install on your phone

1. **Download** the APK from https://gofile.io/d/obf1nl to your Android phone.
2. **Allow installation from unknown sources**:
   - **Settings → Apps → Special access → Install unknown apps**
   - Allow your browser (e.g. Chrome) to install apps.
3. **Open the downloaded APK** → Android will ask to confirm.
4. **Tap Install** → done!
5. **First launch**: grant Camera + Notifications permissions when asked.

If you previously installed v1.0.0, this will install over the top — your data stays. (You may have to manually re-toggle dark mode and meal reminders once.)

---

## 🗄️ Supabase setup (only needed once)

If you haven't already, open your Supabase project → **SQL Editor** → paste the contents of [`supabase_schema.sql`](https://github.com/tomassefiiw-cloud/FoodIQ/blob/main/supabase_schema.sql) → **Run**. This creates the tables, RLS policies, and the auth trigger.

---

## 🔑 What's where in the code

| Feature | File |
|---|---|
| API key obfuscation | `lib/core/constants/api_keys.dart` |
| Dark mode persistence | `lib/providers/auth_provider.dart` (DarkModeNotifier) |
| Notifications + channel + perms | `lib/services/notification_service.dart` |
| AI recognition error display | `lib/screens/camera/camera_screen.dart` |
| AI chat online indicator | `lib/screens/assistant/assistant_screen.dart` |
| Manual food entry sheet | `lib/screens/food_log/food_log_screen.dart` (`_ManualFoodSheet`) |
| Quick-action FAB sheet | `lib/screens/dashboard/dashboard_screen.dart` (`_showAddSheet`) |
| Bottom nav tabs | `lib/screens/dashboard/dashboard_screen.dart` |
| Startup re-schedule | `lib/main.dart` |
| Android manifest perms | `android/app/src/main/AndroidManifest.xml` |
