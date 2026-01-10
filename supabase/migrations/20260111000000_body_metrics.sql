-- Create Body Metrics Table
CREATE TABLE IF NOT EXISTS public.body_metrics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    date DATE NOT NULL DEFAULT CURRENT_DATE,
    weight NUMERIC,
    body_fat NUMERIC,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(user_id, date)
);

-- Create User Settings Table (for goals)
CREATE TABLE IF NOT EXISTS public.user_profiles (
    user_id UUID PRIMARY KEY,
    target_weight NUMERIC,
    target_body_fat NUMERIC,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
