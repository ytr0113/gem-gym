-- Add abdominal exercises to default exercises
INSERT INTO public.exercises (user_id, name, target_muscle)
SELECT '00000000-0000-0000-0000-000000000000', name, target_muscle
FROM (VALUES 
    ('アブドミナルクランチ', '腹'),
    ('腹筋ローラー', '腹'),
    ('プランク', '腹'),
    ('レッグレイズ', '腹'),
    ('サイドプランク', '腹'),
    ('クランチ', '腹'),
    ('ツイストクランチ', '腹')
) AS t(name, target_muscle)
WHERE NOT EXISTS (
    SELECT 1 FROM public.exercises e 
    WHERE e.name = t.name AND e.user_id = '00000000-0000-0000-0000-000000000000'
);
