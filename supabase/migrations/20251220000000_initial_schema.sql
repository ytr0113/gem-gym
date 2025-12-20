-- Create Workouts Table
CREATE TABLE IF NOT EXISTS public.workouts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    date DATE NOT NULL DEFAULT CURRENT_DATE,
    note TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Create Exercises Table
CREATE TABLE IF NOT EXISTS public.exercises (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    name TEXT NOT NULL,
    target_muscle TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Create Workout Items Table
CREATE TABLE IF NOT EXISTS public.workout_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workout_id UUID NOT NULL REFERENCES public.workouts(id) ON DELETE CASCADE,
    exercise_id UUID NOT NULL REFERENCES public.exercises(id) ON DELETE CASCADE,
    note TEXT,
    order_index INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Create Sets Table
CREATE TABLE IF NOT EXISTS public.sets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workout_item_id UUID NOT NULL REFERENCES public.workout_items(id) ON DELETE CASCADE,
    weight NUMERIC,
    reps INT,
    rpe NUMERIC,
    order_index INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Enable RLS (Disable initially requested by user's preference in past logs, but let's keep it as is)
-- ALTER TABLE public.workouts ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE public.exercises ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE public.workout_items ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE public.sets ENABLE ROW LEVEL SECURITY;
