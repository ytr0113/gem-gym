-- Enable RLS for exercises
ALTER TABLE public.exercises ENABLE ROW LEVEL SECURITY;

-- Handle foreign key constraint if it exists (it might be added by Supabase automatically)
DO $$ 
BEGIN 
    IF EXISTS (
        SELECT 1 
        FROM information_schema.table_constraints 
        WHERE constraint_name = 'exercises_user_id_fkey' 
        AND table_name = 'exercises'
    ) THEN
        ALTER TABLE public.exercises DROP CONSTRAINT exercises_user_id_fkey;
    END IF;
END $$;

-- Policy: Allow everyone to read system exercises (user_id: 0000...)
DROP POLICY IF EXISTS "Anyone can view system exercises" ON public.exercises;
CREATE POLICY "Anyone can view system exercises" ON public.exercises
    FOR SELECT USING (user_id = '00000000-0000-0000-0000-000000000000');

-- Policy: Allow authenticated users to view their own exercises
DROP POLICY IF EXISTS "Users can view their own exercises" ON public.exercises;
CREATE POLICY "Users can view their own exercises" ON public.exercises
    FOR SELECT USING (auth.uid() = user_id);

-- Policy: Allow authenticated users to manage their own exercises
DROP POLICY IF EXISTS "Users can manage their own exercises" ON public.exercises;
CREATE POLICY "Users can manage their own exercises" ON public.exercises
    FOR ALL USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Re-insert default exercises (ensure they exist)
-- Use a subquery to avoid duplicates by name if id is different
INSERT INTO public.exercises (user_id, name, target_muscle)
SELECT '00000000-0000-0000-0000-000000000000', name, target_muscle
FROM (VALUES 
    ('ベンチプレス', '胸'),
    ('ダンベルフライ', '胸'),
    ('インクラインベンチプレス', '胸'),
    ('デッドリフト', '背中'),
    ('懸垂', '背中'),
    ('ラットプルダウン', '背中'),
    ('ベントオーバーロウ', '背中'),
    ('ショルダープレス', '肩'),
    ('サイドレイズ', '肩'),
    ('リアレイズ', '肩'),
    ('アームカール', '腕'),
    ('トライセプスエクステンション', '腕'),
    ('スクワット', '脚'),
    ('レッグプレス', '脚'),
    ('レッグエクステンション', '脚')
) AS t(name, target_muscle)
WHERE NOT EXISTS (
    SELECT 1 FROM public.exercises e 
    WHERE e.name = t.name AND e.user_id = '00000000-0000-0000-0000-000000000000'
);
-- Note: id is random_uuid, so conflict check by id is not enough for duplicate names. 
-- But for a migration, this is just to ensure they are present.
