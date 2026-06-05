# FoodIQ v2.2.0 — Release Notes

## 📥 Downloads (APK + Source on one page)
**https://gofile.io/d/WZpIwY**
- `FoodIQ-v2.2.0.apk` — install directly on your Android phone
- `FoodIQ-v2.2.0-source.zip` — full source code

> GoFile links are temporary. The APK is also always available from
> **GitHub → Actions → latest "Build APK" run → Artifacts → FoodIQ-v2.2.0**.

---

## ✅ What's new in this release

This release adds the **Wellness Pack** (aligned to the Wellness Hackathon 2026
focus areas — *Personal Wellness & Lifestyle Intelligence* and *Mental Wellness
& Stress Management*) and makes the AI Nutritionist goal drive **everything**.

### 1. Goal now drives everything ("make everything based on that goal")
When you **Accept** the AI Nutritionist's daily calorie goal (or set it
manually), FoodIQ now also computes and applies your daily **macro targets**:
- **Protein / Carbs / Fat / Fiber** grams are derived from the calorie goal.
- The split is **condition-aware** — e.g. **diabetes** → lower-carb / higher
  protein, **heart/cholesterol** → lower fat, **kidney** → moderate protein.
- The **dashboard macros** now show **progress bars vs these targets**
  (e.g. "42 / 120 g") instead of just raw numbers.
- Water goal is applied too, and targets auto-recompute if you change your
  calorie goal in Settings.

### 2. New Wellness hub 🧘 (Mental Wellness)
A new **Wellness** screen (Profile → *Wellness*, plus a card on the Dashboard):
- **Daily check-in** for **mood, stress, and energy** (tap-to-pick emoji scales)
  with an optional note.
- **Daily Wellness Score** (0–100) that blends **nutrition adherence +
  hydration + mental wellbeing** into one easy number, with a status label
  (Thriving / Doing well / Needs care / Let's improve).
- **Personalized wellness tips** (e.g. 4-7-8 breathing when stress is high,
  hydration nudges, sleep reminders).
- A **7-day mood trend** strip.
- The dashboard card shows a ✓ once you've checked in today.

---

## 🔒 Everything else kept intact
Auth & sign-up→login→home, AI food scanner with portions, AI Assistant
(Gemini + Amharic + voice), multi-key Gemini load balancer, BMI calculator,
AI Nutritionist, weekly/monthly water stats, corrected Amharic food database,
dark mode, and the funny BMI/AI-aware meal reminders all remain as-is.

---

## 📲 Install steps
1. Open **https://gofile.io/d/WZpIwY** on your phone → download `FoodIQ-v2.2.0.apk`.
2. Open it and tap **Install** (allow "Install unknown apps" if prompted).
3. Set goals in **Profile → AI Nutritionist** (Accept the plan), then open
   **Profile → Wellness** for your daily check-in.
4. Installing over an older version updates in place — your account & data stay safe.

> Disclaimer: FoodIQ provides general wellness & nutrition guidance and is not a
> substitute for professional medical advice.
