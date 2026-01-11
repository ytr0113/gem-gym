-- Enable RLS
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.body_metrics ENABLE ROW LEVEL SECURITY;

-- Policies for user_profiles
DROP POLICY IF EXISTS "Users can view their own profile" ON public.user_profiles;
CREATE POLICY "Users can view their own profile" ON public.user_profiles
    FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update their own profile" ON public.user_profiles;
CREATE POLICY "Users can update their own profile" ON public.user_profiles
    FOR ALL USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Policies for body_metrics
DROP POLICY IF EXISTS "Users can view their own metrics" ON public.body_metrics;
CREATE POLICY "Users can view their own metrics" ON public.body_metrics
    FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can manage their own metrics" ON public.body_metrics;
CREATE POLICY "Users can manage their own metrics" ON public.body_metrics
    FOR ALL USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);
