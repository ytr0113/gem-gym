<template>
  <div class="space-y-6">
    <div class="flex justify-between items-center">
      <h2 class="text-2xl font-bold leading-7 text-gray-900 sm:truncate">
        トレーニング履歴
      </h2>
      <button
        @click="createWorkout"
        class="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
      >
        新規トレーニング開始
      </button>
    </div>

    <div class="bg-white shadow overflow-hidden sm:rounded-md">
      <ul role="list" class="divide-y divide-gray-200">
        <li v-for="workout in workouts" :key="workout.id">
          <div class="block hover:bg-gray-50">
            <div class="px-4 py-4 sm:px-6">
              <div class="flex items-center justify-between">
                <NuxtLink :to="`/workouts/${workout.id}`" class="flex-grow">
                  <p class="text-sm font-medium text-indigo-600 truncate">
                    {{ formatDate(workout.date) }} のトレーニング
                  </p>
                </NuxtLink>
                <div class="ml-2 flex-shrink-0 flex items-center">
                  <button
                    @click.prevent="deleteWorkout(workout.id)"
                    class="text-red-500 hover:text-red-700 text-sm border px-2 py-1 rounded"
                  >
                    削除
                  </button>
                </div>
              </div>
              <div class="mt-2 sm:flex sm:justify-between">
                <div class="sm:flex">
                  <p class="flex items-center text-sm text-gray-500">
                    {{ workout.note || "メモなし" }}
                  </p>
                </div>
              </div>
            </div>
          </div>
        </li>
        <li
          v-if="workouts.length === 0"
          class="px-4 py-4 sm:px-6 text-center text-gray-500"
        >
          履歴がまだありません。
        </li>
      </ul>
    </div>
  </div>
</template>

<script setup lang="ts">
import type { Database } from "~/types/database";

const client = useSupabaseClient<Database>();
const user = useSupabaseUser();
const workouts = ref<Database["public"]["Tables"]["workouts"]["Row"][]>([]);

const fetchWorkouts = async () => {
  if (!user.value) return;
  const { data, error } = await client
    .from("workouts")
    .select("*")
    .order("date", { ascending: false });

  if (error) {
    console.error("Error fetching workouts:", error);
  } else {
    workouts.value = data || [];
  }
};

const createWorkout = async () => {
  const {
    data: { user: currentUser },
    error: authError,
  } = await client.auth.getUser();

  if (authError || !currentUser) {
    alert("ログインセッションが無効です。");
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
    if (confirm("本日のトレーニングは既に作成されています。開きますか？")) {
      navigateTo(`/workouts/${existing.id}`);
    }
    return;
  }

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

const deleteWorkout = async (id: string) => {
  if (!confirm("本当に削除しますか？")) return;

  const { error } = await client.from("workouts").delete().eq("id", id);
  if (error) {
    alert("削除エラー: " + error.message);
  } else {
    fetchWorkouts(); // refresh
  }
};

const formatDate = (dateString: string) => {
  return new Date(dateString).toLocaleDateString("ja-JP", {
    year: "numeric",
    month: "long",
    day: "numeric",
    weekday: "short",
  });
};

onMounted(() => {
  fetchWorkouts();
});
</script>
