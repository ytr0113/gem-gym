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

    <div class="bg-white shadow overflow-hidden rounded-xl">
      <ul role="list" class="divide-y divide-gray-100">
        <li v-for="workout in workouts" :key="workout.id">
          <div class="block hover:bg-gray-50 transition-colors">
            <div class="px-4 py-5 sm:px-6">
              <div class="flex items-start justify-between">
                <NuxtLink :to="`/workouts/${workout.id}`" class="flex-grow group">
                  <div class="flex flex-col">
                    <span class="text-xs font-bold text-gray-400 uppercase tracking-widest mb-1">{{ formatDate(workout.date, true) }}</span>
                    <p class="text-lg font-black text-gray-900 group-hover:text-indigo-600 transition-colors">
                      {{ formatDate(workout.date) }} 
                    </p>
                  </div>
                  <div class="mt-2 text-sm text-gray-500 line-clamp-1 italic">
                    {{ workout.note || "メモなし" }}
                  </div>
                </NuxtLink>
                <div class="ml-4 flex-shrink-0">
                  <button
                    @click.prevent="deleteWorkout(workout.id)"
                    class="p-2 text-gray-300 hover:text-red-500 transition-colors"
                  >
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                    </svg>
                  </button>
                </div>
              </div>
            </div>
          </div>
        </li>
        <li
          v-if="!loading && workouts.length === 0"
          class="px-4 py-8 sm:px-6 text-center"
        >
          <div class="flex flex-col items-center">
            <svg xmlns="http://www.w3.org/2000/svg" class="h-12 w-12 text-gray-200 mb-3" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253" />
            </svg>
            <p class="text-gray-400 font-bold">履歴がまだありません</p>
          </div>
        </li>
        <li v-if="loading" class="px-4 py-12 text-center">
          <div class="inline-block animate-spin rounded-full h-8 w-8 border-4 border-indigo-500 border-t-transparent"></div>
          <p class="mt-2 text-xs font-bold text-indigo-400">履歴を読み込み中...</p>
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
const loading = ref(true);

const { getTodayJST } = useDate();

const fetchWorkouts = async () => {
  const { data: { session } } = await client.auth.getSession();
  const currentUserId = session?.user?.id || user.value?.id;

  if (!currentUserId || currentUserId === "undefined") {
    console.log("[History] Waiting for valid user ID...");
    return;
  }

  loading.value = true;
  try {
    const { data, error } = await client
      .from("workouts")
      .select("*")
      .eq("user_id", currentUserId)
      .order("date", { ascending: false });

    if (error) {
      console.error("Error fetching workouts:", error);
    } else {
      workouts.value = data || [];
    }
  } finally {
    loading.value = false;
  }
};

const createWorkout = async () => {
  const {
    data: { user: currentUser },
    error: authError,
  } = await client.auth.getUser();

  if (authError || !currentUser?.id || currentUser.id === "undefined") {
    alert("ログインセッションが無効です。");
    return;
  }

  const today = getTodayJST();

  // Check existing
  const { data: existing } = await client
    .from("workouts")
    .select("id")
    .eq("user_id", currentUser.id)
    .eq("date", today)
    .single();

  if (existing) {
    if (confirm("本日のトレーニングは既に作成されています。開きますか？")) {
      navigateTo(`/workouts/${(existing as any).id}`);
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
    navigateTo(`/workouts/${(data as any).id}`);
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

const formatDate = (dateString: string, brief = false) => {
  const date = new Date(dateString);
  if (brief) {
    return date.toLocaleDateString("ja-JP", {
      year: "numeric",
      month: "2-digit",
      day: "2-digit",
    });
  }
  return date.toLocaleDateString("ja-JP", {
    month: "long",
    day: "numeric",
    weekday: "short",
  });
};

watch(() => user.value?.id, (newId) => {
  if (newId && newId !== 'undefined') {
    fetchWorkouts();
  }
}, { immediate: true });

// Auth状態の変化も監視
client.auth.onAuthStateChange((event, session) => {
  if (session?.user?.id) {
    fetchWorkouts();
  }
});

onMounted(() => {
  fetchWorkouts();
});
</script>
