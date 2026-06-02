-- ================================================
-- FoodIQ - Complete Supabase Database Schema
-- PASTE THIS ENTIRE SCRIPT INTO SUPABASE SQL EDITOR
-- ================================================

-- STEP 1: Drop existing tables and recreate (safe to re-run)
DROP TABLE IF EXISTS public.user_settings CASCADE;
DROP TABLE IF EXISTS public.custom_foods CASCADE;
DROP TABLE IF EXISTS public.water_logs CASCADE;
DROP TABLE IF EXISTS public.calorie_logs CASCADE;
DROP TABLE IF EXISTS public.profiles CASCADE;

-- STEP 2: Create profiles table
CREATE TABLE public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL DEFAULT '',
  email TEXT NOT NULL DEFAULT '',
  calorie_goal INTEGER NOT NULL DEFAULT 2000,
  water_goal INTEGER NOT NULL DEFAULT 2000,
  is_premium BOOLEAN NOT NULL DEFAULT false,
  premium_expiry TIMESTAMPTZ,
  age INTEGER NOT NULL DEFAULT 25,
  weight DOUBLE PRECISION NOT NULL DEFAULT 70.0,
  height DOUBLE PRECISION NOT NULL DEFAULT 170.0,
  gender TEXT NOT NULL DEFAULT 'Not specified',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- STEP 3: Create calorie_logs table
CREATE TABLE public.calorie_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  food_id TEXT NOT NULL DEFAULT '',
  food_name TEXT NOT NULL DEFAULT '',
  meal_type TEXT NOT NULL DEFAULT 'snack',
  portion DOUBLE PRECISION NOT NULL DEFAULT 1.0,
  calories DOUBLE PRECISION NOT NULL DEFAULT 0,
  protein DOUBLE PRECISION NOT NULL DEFAULT 0,
  carbs DOUBLE PRECISION NOT NULL DEFAULT 0,
  fat DOUBLE PRECISION NOT NULL DEFAULT 0,
  fiber DOUBLE PRECISION NOT NULL DEFAULT 0,
  serving_size DOUBLE PRECISION NOT NULL DEFAULT 100,
  notes TEXT,
  logged_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- STEP 4: Create water_logs table
CREATE TABLE public.water_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  amount_ml DOUBLE PRECISION NOT NULL DEFAULT 0,
  logged_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- STEP 5: Create custom_foods table
CREATE TABLE public.custom_foods (
  id TEXT PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  name TEXT NOT NULL DEFAULT '',
  calories DOUBLE PRECISION NOT NULL DEFAULT 0,
  protein DOUBLE PRECISION NOT NULL DEFAULT 0,
  carbs DOUBLE PRECISION NOT NULL DEFAULT 0,
  fat DOUBLE PRECISION NOT NULL DEFAULT 0,
  fiber DOUBLE PRECISION NOT NULL DEFAULT 0,
  serving_size DOUBLE PRECISION NOT NULL DEFAULT 100,
  serving_unit TEXT NOT NULL DEFAULT 'g',
  description TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- STEP 6: Create user_settings table
CREATE TABLE public.user_settings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL UNIQUE REFERENCES public.profiles(id) ON DELETE CASCADE,
  dark_mode BOOLEAN NOT NULL DEFAULT false,
  meal_reminders_enabled BOOLEAN NOT NULL DEFAULT false,
  breakfast_time TEXT NOT NULL DEFAULT '08:00',
  lunch_time TEXT NOT NULL DEFAULT '12:30',
  dinner_time TEXT NOT NULL DEFAULT '19:00',
  onboarding_complete BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- STEP 7: Create indexes for performance
CREATE INDEX idx_calorie_logs_user_id ON public.calorie_logs(user_id);
CREATE INDEX idx_calorie_logs_logged_at ON public.calorie_logs(logged_at);
CREATE INDEX idx_water_logs_user_id ON public.water_logs(user_id);
CREATE INDEX idx_water_logs_logged_at ON public.water_logs(logged_at);
CREATE INDEX idx_custom_foods_user_id ON public.custom_foods(user_id);
CREATE INDEX idx_user_settings_user_id ON public.user_settings(user_id);

-- STEP 8: Enable Row Level Security on all tables
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.calorie_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.water_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.custom_foods ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_settings ENABLE ROW LEVEL SECURITY;

-- STEP 9: Create RLS policies for profiles
CREATE POLICY "Users can view own profile" ON public.profiles
  FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can insert own profile" ON public.profiles
  FOR INSERT WITH CHECK (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON public.profiles
  FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Users can delete own profile" ON public.profiles
  FOR DELETE USING (auth.uid() = id);

-- STEP 10: Create RLS policies for calorie_logs
CREATE POLICY "Users can view own calorie logs" ON public.calorie_logs
  FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own calorie logs" ON public.calorie_logs
  FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own calorie logs" ON public.calorie_logs
  FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own calorie logs" ON public.calorie_logs
  FOR DELETE USING (auth.uid() = user_id);

-- STEP 11: Create RLS policies for water_logs
CREATE POLICY "Users can view own water logs" ON public.water_logs
  FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own water logs" ON public.water_logs
  FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own water logs" ON public.water_logs
  FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own water logs" ON public.water_logs
  FOR DELETE USING (auth.uid() = user_id);

-- STEP 12: Create RLS policies for custom_foods
CREATE POLICY "Users can view own custom foods" ON public.custom_foods
  FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own custom foods" ON public.custom_foods
  FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own custom foods" ON public.custom_foods
  FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own custom foods" ON public.custom_foods
  FOR DELETE USING (auth.uid() = user_id);

-- STEP 13: Create RLS policies for user_settings
CREATE POLICY "Users can view own settings" ON public.user_settings
  FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own settings" ON public.user_settings
  FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own settings" ON public.user_settings
  FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own settings" ON public.user_settings
  FOR DELETE USING (auth.uid() = user_id);

-- STEP 14: CRITICAL - Create trigger function to auto-create profile on signup
-- This runs with elevated privileges (SECURITY DEFINER) and bypasses RLS
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = public
AS $$
BEGIN
  -- Auto-confirm the user's email
  UPDATE auth.users
  SET email_confirmed_at = now()
  WHERE id = NEW.id AND email_confirmed_at IS NULL;

  -- Insert profile
  INSERT INTO public.profiles (id, name, email, calorie_goal, water_goal)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'name', split_part(NEW.email, '@', 1)),
    NEW.email,
    COALESCE((NEW.raw_user_meta_data->>'calorie_goal')::INTEGER, 2000),
    2000
  )
  ON CONFLICT (id) DO NOTHING;

  -- Insert default user settings
  INSERT INTO public.user_settings (user_id, dark_mode, meal_reminders_enabled, breakfast_time, lunch_time, dinner_time, onboarding_complete)
  VALUES (NEW.id, false, false, '08:00', '12:30', '19:00', false)
  ON CONFLICT (user_id) DO NOTHING;

  RETURN NEW;
END;
$$;

-- STEP 15: Create the trigger on auth.users
-- Drop existing trigger first (safe to re-run)
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- STEP 16: Disable email confirmation for new signups
-- This allows immediate login after registration
UPDATE auth.users SET email_confirmed_at = now() WHERE email_confirmed_at IS NULL;

-- ================================================
-- DONE! Your FoodIQ database is ready.
-- 
-- What this setup does:
-- 1. Creates all required tables with proper relationships
-- 2. Enables Row Level Security (RLS) on all tables
-- 3. Creates policies so users can only access their own data
-- 4. Auto-creates a profile and settings when a new user signs up (via trigger)
-- 5. Auto-confirms new user emails so they can log in immediately
-- ================================================
