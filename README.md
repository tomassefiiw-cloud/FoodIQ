# FoodIQ 🍽️

**Smart Ethiopian Calorie Tracking with AI**

## Features
- 🇪🇹 **103 Ethiopian Foods** - Complete database with Amharic names (አማርኛ)
- 🌍 **80 Common Foods** - International food database
- 🤖 **AI Nutrition Assistant** - Powered by Groq LLM
- 📸 **AI Food Recognition** - Powered by Gemini Vision
- 📊 **Smart Analytics** - Daily/Weekly/Monthly charts
- 💧 **Water Tracking** - Track daily water intake
- ⏰ **Meal Reminders** - Formal yet fun notifications
- 🌙 **Dark/Light Mode** - Adaptive theme
- 🔐 **Supabase Auth** - Secure authentication

## Setup

### 1. Clone the repo
```bash
git clone https://github.com/tomassefiiw-cloud/FoodIQ.git
cd FoodIQ
flutter pub get
```

### 2. Set up Supabase Tables
Run the following SQL in your Supabase SQL Editor:

```sql
-- Profiles table
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  email TEXT NOT NULL,
  calorie_goal INTEGER DEFAULT 2000,
  water_goal INTEGER DEFAULT 2000,
  is_premium BOOLEAN DEFAULT FALSE,
  premium_expiry TIMESTAMPTZ,
  age INTEGER DEFAULT 25,
  weight DOUBLE PRECISION DEFAULT 70.0,
  height DOUBLE PRECISION DEFAULT 170.0,
  gender TEXT DEFAULT 'Not specified',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Calorie logs table
CREATE TABLE calorie_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  food_id TEXT NOT NULL,
  food_name TEXT NOT NULL,
  meal_type TEXT DEFAULT 'snack',
  portion DOUBLE PRECISION DEFAULT 1.0,
  calories DOUBLE PRECISION NOT NULL,
  protein DOUBLE PRECISION DEFAULT 0,
  carbs DOUBLE PRECISION DEFAULT 0,
  fat DOUBLE PRECISION DEFAULT 0,
  fiber DOUBLE PRECISION DEFAULT 0,
  serving_size DOUBLE PRECISION DEFAULT 100,
  notes TEXT,
  logged_at TIMESTAMPTZ DEFAULT NOW()
);

-- Water logs table
CREATE TABLE water_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  amount_ml DOUBLE PRECISION NOT NULL,
  logged_at TIMESTAMPTZ DEFAULT NOW()
);

-- Custom foods table
CREATE TABLE custom_foods (
  id TEXT PRIMARY KEY,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  name TEXT NOT NULL,
  calories DOUBLE PRECISION NOT NULL,
  protein DOUBLE PRECISION DEFAULT 0,
  carbs DOUBLE PRECISION DEFAULT 0,
  fat DOUBLE PRECISION DEFAULT 0,
  fiber DOUBLE PRECISION DEFAULT 0,
  serving_size DOUBLE PRECISION DEFAULT 100,
  serving_unit TEXT DEFAULT 'g',
  description TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- User settings table
CREATE TABLE user_settings (
  user_id UUID PRIMARY KEY REFERENCES profiles(id) ON DELETE CASCADE,
  dark_mode BOOLEAN DEFAULT FALSE,
  meal_reminders_enabled BOOLEAN DEFAULT FALSE,
  breakfast_time TEXT DEFAULT '08:00',
  lunch_time TEXT DEFAULT '12:30',
  dinner_time TEXT DEFAULT '19:00',
  timezone TEXT DEFAULT 'UTC',
  onboarding_complete BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE calorie_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE water_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE custom_foods ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_settings ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Users can read own profile" ON profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON profiles FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Users can insert own profile" ON profiles FOR INSERT WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can manage own calorie logs" ON calorie_logs FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users can manage own water logs" ON water_logs FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users can manage own custom foods" ON custom_foods FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users can manage own settings" ON user_settings FOR ALL USING (auth.uid() = user_id);
```

### 3. Build the APK
```bash
flutter build apk --release \
  --dart-define=SUPABASE_URL=your_supabase_url \
  --dart-define=SUPABASE_ANON_KEY=your_anon_key \
  --dart-define=GEMINI_API_KEY=your_gemini_key \
  --dart-define=GROQ_API_KEY=your_groq_key
```

The APK will be at `build/app/outputs/flutter-apk/app-release.apk`

## Tech Stack
- **Flutter 3.44** + Dart 3.12
- **Supabase** (Auth + Database)
- **Gemini 1.5 Flash** (Food Vision AI)
- **Groq LLM** (Nutrition Assistant)
- **Riverpod** (State Management)
- **Google Fonts Poppins**

## App Screenshots
| Home | Food Database | AI Scanner | Analytics |
|------|---------------|------------|-----------|
| Dashboard with calorie ring & water tracker | 183+ Ethiopian & common foods | AI-powered food recognition | Daily/Weekly/Monthly charts |

## License
MIT
