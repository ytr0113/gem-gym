<template>
  <div class="space-y-6">
    <div class="bg-white shadow px-4 py-5 sm:rounded-lg sm:p-6">
      <div class="md:grid md:grid-cols-3 md:gap-6">
        <div class="md:col-span-1">
          <h3 class="text-lg font-medium leading-6 text-gray-900">
            ようこそ！
          </h3>
          <p class="mt-1 text-sm text-gray-500">
            毎日のトレーニングを記録して、理想の体を作りましょう。
          </p>
          <div class="mt-6">
            <div class="bg-indigo-50 overflow-hidden rounded-lg">
              <div class="px-4 py-5 sm:p-6">
                <dt class="text-sm font-medium text-gray-500 truncate">
                  今週のワークアウト
                </dt>
                <dd class="mt-1 text-3xl font-semibold text-indigo-900">
                  {{ weeklyCount }} 回
                </dd>
              </div>
            </div>
          </div>
        </div>
        <div class="mt-5 md:mt-0 md:col-span-2">
          <h4 class="text-sm font-medium text-gray-500 mb-2">
            直近のボリューム推移 (kg)
          </h4>
          <ClientOnly>
            <VolumeChart :labels="volumeLabels" :data="volumeData" />
            <template #fallback>
              <div
                class="h-64 bg-gray-100 flex items-center justify-center text-gray-400"
              >
                Loading Chart...
              </div>
            </template>
          </ClientOnly>
        </div>
      </div>
    </div>

    <!-- Quick Actions -->
    <div class="bg-white shadow sm:rounded-lg">
      <div class="px-4 py-5 sm:p-6">
        <h3 class="text-lg leading-6 font-medium text-gray-900">
          クイックアクション
        </h3>
        <div class="mt-5 flex space-x-4">
          <button
            type="button"
            @click="createWorkout"
            class="inline-flex items-center px-4 py-2 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
          >
            トレーニングを開始する
          </button>
          <NuxtLink
            to="/workouts"
            class="inline-flex items-center px-4 py-2 border border-gray-300 shadow-sm text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
          >
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

  console.log("User ID:", currentUser.id);

  const { data, error } = await client
    .from("workouts")
    .insert({
      user_id: currentUser.id,
      date: new Date().toISOString().split("T")[0],
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
