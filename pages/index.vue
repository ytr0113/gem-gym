<template>
  <div class="space-y-4 sm:space-y-6">
    <div class="bg-white shadow px-4 py-5 sm:rounded-lg sm:p-6">
      <div class="lg:grid lg:grid-cols-3 lg:gap-6">
        <div class="lg:col-span-1">
          <h3 class="text-xl sm:text-lg font-bold sm:font-medium leading-6 text-gray-900">
            ようこそ！
          </h3>
          <p class="mt-1 text-sm text-gray-500">
            毎日のトレーニングを記録して、理想の体を作りましょう。
          </p>
          <div class="mt-4 sm:mt-6">
            <div class="bg-indigo-50 overflow-hidden rounded-xl border border-indigo-100/50">
              <div class="px-4 py-5 sm:p-6">
                <dt class="text-xs sm:text-sm font-medium text-indigo-600 sm:text-gray-500 uppercase tracking-wider">
                  今週のワークアウト
                </dt>
                <dd class="mt-1 text-4xl sm:text-3xl font-black text-indigo-900">
                  {{ weeklyCount }} <span class="text-sm font-normal">回</span>
                </dd>
              </div>
            </div>
          </div>
        </div>
        <div class="mt-8 lg:mt-0 lg:col-span-2">
          <h4 class="text-xs font-bold text-gray-400 uppercase tracking-widest mb-4">
            ボリューム推移 (kg)
          </h4>
          <ClientOnly>
            <VolumeChart :labels="volumeLabels" :data="volumeData" />
            <template #fallback>
              <div
                class="h-64 bg-gray-50 rounded-lg flex items-center justify-center text-gray-400 text-sm italic"
              >
                グラフを読み込み中...
              </div>
            </template>
          </ClientOnly>
        </div>
      </div>
    </div>

    <!-- Quick Actions -->
    <div class="bg-white shadow rounded-lg sm:rounded-lg">
      <div class="px-4 py-5 sm:p-6">
        <h3 class="text-lg leading-6 font-bold text-gray-900 mb-4 sm:mb-0">
          クイックアクション
        </h3>
        <div class="mt-2 sm:mt-5 flex flex-col sm:flex-row gap-3 sm:space-x-4">
          <button
            type="button"
            @click="createWorkout"
            class="flex-1 inline-flex items-center justify-center px-4 py-3 sm:py-2 border border-transparent shadow-sm text-sm font-bold sm:font-medium rounded-xl sm:rounded-md text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-4 focus:ring-indigo-500/50 transition-all active:scale-95"
          >
            <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
            </svg>
            トレーニングを開始
          </button>
          <NuxtLink
            to="/workouts"
            class="flex-1 inline-flex items-center justify-center px-4 py-3 sm:py-2 border border-gray-200 shadow-sm text-sm font-bold sm:font-medium rounded-xl sm:rounded-md text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-4 focus:ring-gray-100 transition-all active:scale-95 text-center"
          >
            <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 mr-2 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
            履歴を見る
          </NuxtLink>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import type { Database } from "~/types/database";
import VolumeChart from "~/components/charts/VolumeChart.vue";

const client = useSupabaseClient<Database>();
const user = useSupabaseUser();

const weeklyCount = ref(0);
const volumeLabels = ref<string[]>([]);
const volumeData = ref<number[]>([]);

const fetchStats = async () => {
  if (!user.value) return;

  // Get date 7 days ago
  const today = new Date();
  const sevenDaysAgo = new Date(today);
  sevenDaysAgo.setDate(today.getDate() - 6);
  const dateStr = sevenDaysAgo.toISOString().split("T")[0];

  try {
    const { data: workouts, error } = await client
      .from("workouts")
      .select(
        `
                date,
                workout_items (
                    sets (
                        weight,
                        reps
                    )
                )
            `
      )
      .gte("date", dateStr)
      .order("date", { ascending: true });

    if (error) throw error;

    // Process data
    weeklyCount.value = workouts?.length || 0;

    // Group volume by date
    const volMap: Record<string, number> = {};
    // Initialize last 7 days with 0
    for (let i = 0; i < 7; i++) {
      const d = new Date(sevenDaysAgo);
      d.setDate(d.getDate() + i);
      const key = d.toLocaleDateString("ja-JP", {
        month: "2-digit",
        day: "2-digit",
      });
      volMap[key] = 0;
      volumeLabels.value[i] = key; // ordered labels
    }

    workouts?.forEach((w) => {
      const dKey = new Date(w.date).toLocaleDateString("ja-JP", {
        month: "2-digit",
        day: "2-digit",
      });
      let dailyVol = 0;
      // @ts-ignore: nested types can be tricky
      w.workout_items?.forEach((item: any) => {
        item.sets?.forEach((s: any) => {
          if (s.weight && s.reps) {
            dailyVol += s.weight * s.reps;
          }
        });
      });
      // Accumulate if multiple workouts per day
      if (volMap[dKey] !== undefined) {
        volMap[dKey] += dailyVol;
      } else {
        // In case logic mismatches timezone slightly
        volMap[dKey] = dailyVol;
      }
    });

    volumeData.value = volumeLabels.value.map((l) => volMap[l] || 0);
  } catch (e) {
    console.error("Stats error:", e);
  }
};

onMounted(() => {
  fetchStats();
});

const createWorkout = async () => {
  const {
    data: { user: currentUser },
    error: authError,
  } = await client.auth.getUser();

  if (authError || !currentUser) {
    alert("ログインセッションが無効です。再ログインしてください。");
    return;
  }

  const today = new Date().toISOString().split("T")[0];

  // Check existing
  const { data: existing } = await client
    .from("workouts")
    .select("id")
    .eq("user_id", currentUser.id)
    .eq("date", today)
    .single();

  if (existing) {
    if (confirm("本日のトレーニングは既に作成されています。再開しますか？")) {
      navigateTo(`/workouts/${existing.id}`);
    }
    return;
  }

  console.log("User ID:", currentUser.id);

  const { data, error } = await client
    .from("workouts")
    .insert({
      user_id: currentUser.id,
      date: today,
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
