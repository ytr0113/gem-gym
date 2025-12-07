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
          <NuxtLink
            :to="`/workouts/${workout.id}`"
            class="block hover:bg-gray-50"
          >
            <div class="px-4 py-4 sm:px-6">
              <div class="flex items-center justify-between">
                <p class="text-sm font-medium text-indigo-600 truncate">
                  {{ formatDate(workout.date) }} のトレーニング
                </p>
                <div class="ml-2 flex-shrink-0 flex">
                  <!-- Status labels could go here -->
                </div>
              </div>
              <div class="mt-2 sm:flex sm:justify-between">
                <div class="sm:flex">
                  <p class="flex items-center text-sm text-gray-500">
                    <!-- Icon or summary info -->
                    {{ workout.note || "メモなし" }}
                  </p>
                </div>
              </div>
            </div>
          </NuxtLink>
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
  if (!user.value) return;
  const { data, error } = await client
    .from("workouts")
    .insert({
      user_id: user.value.id,
      date: new Date().toISOString().split("T")[0], // today YYYY-MM-DD
    })
    .select()
    .single();

  if (error) {
    alert("作成に失敗しました: " + error.message);
  } else if (data) {
    navigateTo(`/workouts/${data.id}`);
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
