<template>
  <div class="space-y-4">
    <!-- Header with Quick Action -->
    <div class="flex items-center justify-between px-1 mb-2">
      <div>
        <h2 class="text-2xl font-black text-indigo-900 tracking-tight">ダッシュボード</h2>
        <p class="text-[10px] font-black text-gray-400 uppercase tracking-widest leading-none mt-1">目指せパーフェクトボディ！</p>
      </div>
      <button
        type="button"
        @click="createWorkout()"
        class="inline-flex items-center px-4 py-2.5 bg-indigo-600 text-white rounded-xl font-bold text-sm shadow-lg shadow-indigo-200 active:scale-95 transition-all hover:bg-indigo-700"
      >
        <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 mr-1.5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M12 4v16m8-8H4" />
        </svg>
        開始
      </button>
    </div>

    <!-- Stats & Calendar Grid -->
    <div class="grid grid-cols-1 sm:grid-cols-2 gap-4 items-stretch">
      <!-- Calendar Area -->
      <div class="flex flex-col h-full space-y-2">
        <h3 class="text-xs font-black text-gray-400 uppercase tracking-[0.2em] px-1">
          トレーニング記録
        </h3>
        <WorkoutCalendar :workouts-by-date="workoutsByDate" @select-day="handleDateSelect" class="flex-grow" />
      </div>

      <!-- Weekly Stats Area -->
      <div class="flex flex-col h-full space-y-2">
        <h3 class="text-xs font-black text-gray-400 uppercase tracking-[0.2em] px-1">
          週間のパフォーマンス
        </h3>
        <div class="bg-white p-5 rounded-2xl shadow-sm border border-gray-100 flex-grow flex flex-col">
          <div class="flex items-end justify-between mb-2">
            <div>
              <p class="text-[10px] font-black text-gray-400 uppercase tracking-widest leading-none mb-1">週間のトレーニング数</p>
              <p class="text-4xl font-black text-indigo-900 leading-none">{{ weeklyCount }}<span class="text-sm font-normal ml-1">回</span></p>
            </div>
            <div 
              class="px-3 py-1 rounded-full text-[10px] font-black uppercase transition-colors duration-500"
              :class="weeklyMessage.color"
            >
              {{ weeklyMessage.text }}
            </div>
          </div>
          
          <div class="mt-4 flex-grow flex flex-col">
            <h4 class="text-[10px] font-black text-gray-400 uppercase tracking-widest mb-4">
              ボリュームの推移
            </h4>
            <div class="flex-grow min-h-[160px]">
              <ClientOnly>
                <VolumeChart :labels="volumeLabels" :datasets="volumeDatasets" />
                <template #fallback>
                  <div class="h-full bg-gray-50 rounded-xl flex items-center justify-center text-gray-300 text-xs italic">
                    読み込み中...
                  </div>
                </template>
              </ClientOnly>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import type { Database } from "~/types/database";
import VolumeChart from "~/components/charts/VolumeChart.vue";
import WorkoutCalendar from "~/components/WorkoutCalendar.vue";

const client = useSupabaseClient<Database>();
const user = useSupabaseUser();

const weeklyCount = ref(0);
const volumeLabels = ref<string[]>([]);
const volumeDatasets = ref<{ label: string; data: number[]; backgroundColor: string }[]>([]);
const workoutsByDate = ref<Record<string, string>>({});
const weeklyMessage = computed(() => {
  if (weeklyCount.value === 0) return { text: '今週も頑張ろう！', color: 'bg-gray-50 text-gray-400' };
  if (weeklyCount.value === 1) return { text: 'ナイス！いい感じ！', color: 'bg-indigo-50 text-indigo-600' };
  if (weeklyCount.value <= 3) return { text: '仕上がってるよ！！', color: 'bg-green-50 text-green-600' };
  return { text: 'パーフェクト！', color: 'bg-yellow-50 text-yellow-600' };
});

const { getTodayJST } = useDate();

const fetchStats = async () => {
  if (!user.value) return;

  // Get date 7 days ago for chart
  const today = new Date();
  const sevenDaysAgo = new Date(today);
  sevenDaysAgo.setDate(today.getDate() - 6);
  const chartDateStr = sevenDaysAgo.toISOString().split("T")[0]; // Chart range might still use UTC-ish but let's be careful. Actually for consistency let's just fix the "today" trigger.

  // Get date 60 days ago for calendar (buffer for month switching)
  const sixtyDaysAgo = new Date(today);
  sixtyDaysAgo.setDate(today.getDate() - 60);
  const calendarDateStr = sixtyDaysAgo.toISOString().split("T")[0];

  try {
    const { data: workouts, error } = await client
      .from("workouts")
      .select(
        `
        id,
        date,
        workout_items (
          exercise:exercises (
            target_muscle
          ),
          sets (
            weight,
            reps
          )
        )
      `
      )
      .gte("date", calendarDateStr)
      .order("date", { ascending: true })
      .eq("user_id", user.value.id);

    if (error) throw error;

    // 1. Populate calendar map
    const map: Record<string, string> = {};
    (workouts as any[])?.forEach(w => {
      map[w.date] = w.id;
    });
    workoutsByDate.value = map;

    // 2. Filter for weekly count and chart
    const recentWorkouts = (workouts as any[])?.filter(w => w.date >= chartDateStr) || [];
    weeklyCount.value = recentWorkouts.length;

    // 3. Aggregate volume by date AND muscle group
    const MUSCLE_COLORS: Record<string, string> = {
      '胸': '#ef4444',
      '背中': '#3b82f6',
      '肩': '#f59e0b',
      '腕': '#8b5cf6',
      '脚': '#10b981',
      'その他': '#94a3b8'
    };

    // Initialize labels for the last 7 days
    volumeLabels.value = [];
    for (let i = 0; i < 7; i++) {
      const d = new Date(sevenDaysAgo);
      d.setDate(d.getDate() + i);
      volumeLabels.value.push(d.toLocaleDateString("ja-JP", {
        month: "2-digit",
        day: "2-digit",
      }));
    }

    const muscleDataMap: Record<string, Record<string, number>> = {};
    const muscles = new Set<string>();

    recentWorkouts.forEach((w) => {
      const dKey = new Date(w.date).toLocaleDateString("ja-JP", {
        month: "2-digit",
        day: "2-digit",
      });

      w.workout_items?.forEach((item: any) => {
        const muscle = item.exercise?.target_muscle || 'その他';
        muscles.add(muscle);

        if (!muscleDataMap[muscle]) {
          muscleDataMap[muscle] = {};
        }
        if (!muscleDataMap[muscle][dKey]) {
          muscleDataMap[muscle][dKey] = 0;
        }

        item.sets?.forEach((s: any) => {
          if (s.weight && s.reps) {
            muscleDataMap[muscle][dKey] += s.weight * s.reps;
          }
        });
      });
    });

    // Prepare datasets for chart
    volumeDatasets.value = Array.from(muscles).map(muscle => ({
      label: muscle,
      backgroundColor: MUSCLE_COLORS[muscle] || MUSCLE_COLORS['その他'],
      data: volumeLabels.value.map(label => muscleDataMap[muscle]?.[label] || 0)
    }));
  } catch (e) {
    console.error("Stats error:", e);
  }
};

onMounted(() => {
  fetchStats();
});

const handleDateSelect = async (dateStr: string) => {
  const existingId = workoutsByDate.value[dateStr];
  if (existingId) {
    navigateTo(`/workouts/${existingId}`);
  } else {
    if (confirm(`${dateStr} のトレーニングを作成しますか？`)) {
      await createWorkout(dateStr);
    }
  }
};

const createWorkout = async (targetDate?: string) => {
  const {
    data: { user: currentUser },
    error: authError,
  } = await client.auth.getUser();

  if (authError || !currentUser) {
    alert("ログインセッションが無効です。再ログインしてください。");
    return;
  }

  const date = targetDate || getTodayJST();

  // Check existing (extra safety)
  const { data: existing } = await client
    .from("workouts")
    .select("id")
    .eq("user_id", currentUser.id)
    .eq("date", date)
    .single();

  if (existing) {
    if (confirm(`${date} のトレーニングは既に作成されています。再開しますか？`)) {
      navigateTo(`/workouts/${existing.id}`);
    }
    return;
  }

  const { data, error } = await client
    .from("workouts")
    .insert({
      user_id: currentUser.id,
      date: date,
    })
    .select()
    .single();

  if (error) {
    alert("作成に失敗しました: " + error.message);
  } else if (data) {
    navigateTo(`/workouts/${data.id}`);
  }
};
</script>
