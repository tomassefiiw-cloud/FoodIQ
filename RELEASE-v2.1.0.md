# FoodIQ v2.1.0 — Release Notes

## 📥 Downloads (APK + Source on one page)
**https://gofile.io/d/8xGZvk**
- `FoodIQ-v2.1.0.apk` — install directly on your Android phone
- `FoodIQ-v2.1.0-source.zip` — full source code

> GoFile links are temporary. The APK is also always available from
> **GitHub → Actions → latest "Build APK" run → Artifacts → FoodIQ-v2.1.0**.

---

## ✅ What's new in this release

### 1. AI Nutritionist — personalized daily calorie & water goals 🩺
A new **AI Nutritionist** screen (Profile → *AI Nutritionist*, and a quick card on
the Dashboard) acts like a real dietitian for the user:

- It **asks for the information a nutritionist needs**:
  - Body details (weight, height, age, gender)
  - **Activity level** (Sedentary → Very Active)
  - **Goal** (Lose / Maintain / Gain)
  - **Health conditions** — Diabetes, Hypertension, Heart Disease, High
    Cholesterol, Kidney Disease, Gastritis/Ulcer, Pregnancy
  - **Financial status** (Low / Medium / High) — so suggestions stay affordable
  - Optional free-text notes (vegetarian, lactose intolerant, fasting, etc.)
- It then **prepares a personalized recommendation**: a daily **calorie goal**
  and **water intake**, with a professional rationale and condition- & budget-
  aware tips (e.g. low-glycemic foods for diabetes, low-salt for hypertension,
  budget staples like shiro/misir/gomen for a low budget).
- **The user decides:** tap **Accept & Apply** to use the suggested goals, or
  **Set Manually** to enter their own — exactly as requested.
- Health answers are saved so the form is pre-filled next time.

### 2. Accurate & safe numbers
- AI runs on Gemini, but every result is **sanity-checked & safety-clamped**
  (never below 1200 kcal for women / 1500 for men; water 1.5–4 L).
- If the AI is unavailable/over quota, a **medically-grounded offline
  calculation** kicks in automatically (Mifflin–St Jeor BMR × activity factor,
  adjusted for goal & conditions) so the user **always** gets an accurate target.

### 3. Multi-key Gemini "load balancer" ⚖️
- A new balancer spreads every AI request across **all available Gemini keys**
  and a chain of **light, high-quota models**, always preferring the
  **least-loaded key/model** and resting any key that hits its quota (429).
- The **AI Assistant** and **BMI suggestions** now also go through this balancer,
  so the whole app is far more resilient to rate limits.

---

## 🔒 Everything else kept intact
Auth & sign-up→login→home flow, dashboard, calorie ring, macros, AI food scanner
with portion sizes, AI assistant (Gemini + Amharic + voice), weekly/monthly water
stats, dark mode, BMI calculator, corrected Amharic food database, and the funny
BMI/AI-aware meal reminders all remain as-is.

---

## 📲 Install steps
1. Open **https://gofile.io/d/8xGZvk** on your phone → download `FoodIQ-v2.1.0.apk`.
2. Open it and tap **Install** (allow "Install unknown apps" if prompted).
3. Go to **Profile → AI Nutritionist** (or the green card on the Dashboard),
   fill in your info, and tap **Get My Plan** → **Accept & Apply**.
4. Installing over an older version updates in place — your account & data stay safe.

> Disclaimer: FoodIQ's nutritionist gives general guidance and is not a
> substitute for professional medical advice — especially for medical conditions.
