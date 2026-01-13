-- Enable RLS for workout related tables
ALTER TABLE public.workouts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.workout_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sets ENABLE ROW LEVEL SECURITY;

-- Policies for workouts
DROP POLICY IF EXISTS "Users can manage their own workouts" ON public.workouts;
CREATE POLICY "Users can manage their own workouts" ON public.workouts
    FOR ALL USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Policies for workout_items
-- Use EXISTS to check the user_id of the parent workout
DROP POLICY IF EXISTS "Users can manage their own workout items" ON public.workout_items;
CREATE POLICY "Users can manage their own workout items" ON public.workout_items
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.workouts
            WHERE workouts.id = workout_items.workout_id
            AND workouts.user_id = auth.uid()
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.workouts
            WHERE workouts.id = workout_items.workout_id
            AND workouts.user_id = auth.uid()
        )
    );

-- Policies for sets
-- Use EXISTS to check the user_id of the grandparent workout
DROP POLICY IF EXISTS "Users can manage their own sets" ON public.sets;
CREATE POLICY "Users can manage their own sets" ON public.sets
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.workout_items
            JOIN public.workouts ON workouts.id = workout_items.workout_id
            WHERE workout_items.id = sets.workout_item_id
            AND workouts.user_id = auth.uid()
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.workout_items
            JOIN public.workouts ON workouts.id = workout_items.workout_id
            WHERE workout_items.id = sets.workout_item_id
            AND workouts.user_id = auth.uid()
        )
    );
