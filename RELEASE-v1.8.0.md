# FoodIQ v1.8.0 — Release Notes

## 📥 Downloads (APK + Source on one page)
**https://gofile.io/d/Cguqa2**
- `FoodIQ-v1.8.0.apk` — install directly on your Android phone
- `FoodIQ-v1.8.0-source.zip` — full source code

> GoFile links are temporary. The APK is also always available from
> **GitHub → Actions → latest "Build APK" run → Artifacts → FoodIQ-v1.8.0**.

---

## ✅ What's new in this release

### Water log now appears in Weekly & Monthly stats
Previously the **Analytics** screen only showed water on the *Daily* tab.
The **Weekly** and **Monthly** tabs now include a full **Water intake** section:

- **Daily avg** glasses, **Total** litres, and **On track** days (days that hit
  your water goal) — shown as mini-stat cards.
- A **water bar chart** (glasses per day) with a dashed **goal line**, matching
  the calorie chart style. Tap any bar to see that day's glasses + ml.
- Works for both **Last 7 Days** and **Last 30 Days**.
- An empty-state message shows when no water was logged in the period.

### Live updates
- Logging or removing a glass on the dashboard now refreshes the weekly/monthly
  water charts immediately (in addition to the daily card).
- The Analytics refresh button / pull-to-refresh also reloads water ranges.

### Performance
- The weekly/monthly water data is fetched in a **single query per range** and
  bucketed by day, so the charts load fast.

---

## 🔒 Everything else kept intact
All existing functionality is preserved — auth, dashboard, calorie ring,
macros, AI food scanner (with the meal-name banner), AI assistant, food
database, manual logging, dark mode, BMI calculator, and the funny BMI/AI-aware
meal reminders.

---

## 📲 Install steps
1. Open **https://gofile.io/d/Cguqa2** on your phone → download `FoodIQ-v1.8.0.apk`.
2. Open it from your notifications and tap **Install**
   (allow "Install unknown apps" for your browser if prompted).
3. Installing over an older version updates in place — your account & data stay safe.
