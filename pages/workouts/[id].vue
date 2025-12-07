<template>
  <div>
    <div v-if="loading" class="text-center py-10">読み込み中...</div>
    <div v-else-if="!workout">ワークアウトが見つかりません。</div>
    <div v-else class="space-y-6">
      <!-- Header -->
      <div class="bg-white px-4 py-5 shadow sm:rounded-lg sm:px-6">
        <div class="md:flex md:items-center md:justify-between">
          <div class="min-w-0 flex-1">
            <h2
              class="text-2xl font-bold leading-7 text-gray-900 sm:truncate sm:text-3xl sm:tracking-tight"
            >
              {{ formatDate(workout.date) }}
            </h2>
          </div>
          <div class="mt-4 flex md:ml-4 md:mt-0">
            <button
              @click="router.push('/workouts')"
              type="button"
              class="inline-flex items-center rounded-md bg-white px-3 py-2 text-sm font-semibold text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-gray-50"
            >
              戻る
            </button>
          </div>
        </div>
      </div>

      <!-- Workout Items -->
      <div class="space-y-4">
        <div
          v-for="item in workoutItems"
          :key="item.id"
          class="bg-white shadow sm:rounded-lg overflow-hidden"
        >
          <div
            class="px-4 py-5 sm:px-6 flex justify-between items-center bg-gray-50"
          >
            <h3 class="text-lg leading-6 font-medium text-gray-900">
              {{ getExerciseName(item.exercise_id) }}
            </h3>
            <button
              @click="deleteItem(item.id)"
              class="text-red-500 text-sm hover:text-red-700"
            >
              削除
            </button>
          </div>
          <div class="border-t border-gray-200 px-4 py-5 sm:p-0">
            <div class="sm:divide-y sm:divide-gray-200">
              <!-- Sets Header -->
              <div
                class="grid grid-cols-4 gap-4 px-4 py-2 text-xs font-medium text-gray-500 uppercase tracking-wider text-center"
              >
                <div>Set</div>
                <div>kg</div>
                <div>Reps</div>
                <div>RPE</div>
              </div>

              <!-- Sets List -->
              <div
                v-for="(set, index) in getSets(item.id)"
                :key="set.id"
                class="grid grid-cols-4 gap-4 px-4 py-2 items-center text-center"
              >
                <div>{{ index + 1 }}</div>
                <div>{{ set.weight }}</div>
                <div>{{ set.reps }}</div>
                <div>{{ set.rpe || "-" }}</div>
              </div>

              <!-- Add Set Form -->
              <div class="px-4 py-3 bg-gray-50">
                <form
                  @submit.prevent="addSet(item.id)"
                  class="grid grid-cols-4 gap-4 items-center"
                >
                  <div class="text-center text-sm text-gray-500">New</div>
                  <input
                    v-model.number="newSets[item.id].weight"
                    type="number"
                    step="0.5"
                    placeholder="kg"
                    class="block w-full rounded-md border-0 py-1.5 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-indigo-600 sm:text-sm sm:leading-6 text-center"
                    required
                  />
                  <input
                    v-model.number="newSets[item.id].reps"
                    type="number"
                    placeholder="Reps"
                    class="block w-full rounded-md border-0 py-1.5 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-indigo-600 sm:text-sm sm:leading-6 text-center"
                    required
                  />
                  <button
                    type="submit"
                    class="inline-flex justify-center rounded-md bg-indigo-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-indigo-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600"
                  >
                    +
                  </button>
                </form>
              </div>
            </div>
          </div>
        </div>

        <div
          v-if="workoutItems.length === 0"
          class="text-center py-10 bg-white shadow sm:rounded-lg"
        >
          <p class="text-gray-500">種目がまだありません。</p>
        </div>
      </div>

      <!-- Add Exercise Button -->
      <div class="text-center">
        <button
          @click="showExerciseSelector = true"
          type="button"
          class="inline-flex items-center px-4 py-2 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
        >
          種目を追加
        </button>
      </div>

      <ExerciseSelector
        v-if="showExerciseSelector"
        @close="showExerciseSelector = false"
        @select="addExercise"
      />
    </div>
  </div>
</template>

<script setup lang="ts">
import type { Database } from "~/types/database";

const route = useRoute();
const router = useRouter();
const client = useSupabaseClient<Database>();
const user = useSupabaseUser();

const workoutId = route.params.id as string;
const loading = ref(true);
const workout = ref<Database["public"]["Tables"]["workouts"]["Row"] | null>(
  null
);
const workoutItems = ref<
  Database["public"]["Tables"]["workout_items"]["Row"][]
>([]);
const exercisesCache = ref<Record<string, string>>({}); // id -> name
const sets = ref<Database["public"]["Tables"]["sets"]["Row"][]>([]);

const showExerciseSelector = ref(false);

// Local state for new sets: itemId -> { weight, reps, rpe }
const newSets = ref<
  Record<
    string,
    { weight: number | null; reps: number | null; rpe: number | null }
  >
>({});

const fetchWorkoutData = async () => {
  loading.value = true;
  try {
    // Fetch Workout
    const { data: wData, error: wError } = await client
      .from("workouts")
      .select("*")
      .eq("id", workoutId)
      .single();
    if (wError) throw wError;
    workout.value = wData;

    // Fetch Items
    const { data: iData, error: iError } = await client
      .from("workout_items")
      .select("*")
      .eq("workout_id", workoutId)
      .order("created_at", { ascending: true });
    if (iError) throw iError;
    workoutItems.value = iData || [];

    // Initialize newSets state
    workoutItems.value.forEach((item) => {
      if (!(item.id in newSets.value)) {
        newSets.value[item.id] = { weight: null, reps: null, rpe: null };
      }
    });

    // Fetch Sets (all for this workout, technically could filter by item IDs but this is easier for now)
    // Optimization: In a real app we might want to be more specific, but for MVP fetching all sets for items belonging to this workout is okay-ish if we join.
    // Actually, let's just fetch all sets where workout_item_id matches
    if (workoutItems.value.length > 0) {
      const itemIds = workoutItems.value.map((i) => i.id);
      const { data: sData, error: sError } = await client
        .from("sets")
        .select("*")
        .in("workout_item_id", itemIds)
        .order("created_at", { ascending: true });
      if (sError) throw sError;
      sets.value = sData || [];
    } else {
      sets.value = [];
    }

    // Fetch Exercise Names needed
    const exerciseIds = [
      ...new Set(workoutItems.value.map((i) => i.exercise_id)),
    ];
    if (exerciseIds.length > 0) {
      const { data: eData, error: eError } = await client
        .from("exercises")
        .select("id, name")
        .in("id", exerciseIds);
      if (eError) throw eError;
      eData?.forEach((e) => {
        exercisesCache.value[e.id] = e.name;
      });
    }
  } catch (e: any) {
    console.error(e);
    alert("データ取得エラー: " + e.message);
  } finally {
    loading.value = false;
  }
};

const getExerciseName = (id: string) =>
  exercisesCache.value[id] || "Unknown Exercise";

const getSets = (itemId: string) =>
  sets.value.filter((s) => s.workout_item_id === itemId);

const addExercise = async (
  exercise: Database["public"]["Tables"]["exercises"]["Row"]
) => {
  showExerciseSelector.value = false;
  const { data, error } = await client
    .from("workout_items")
    .insert({
      workout_id: workoutId,
      exercise_id: exercise.id,
    })
    .select()
    .single();

  if (error) {
    alert("追加エラー: " + error.message);
  } else if (data) {
    // Update local state
    workoutItems.value.push(data);
    exercisesCache.value[exercise.id] = exercise.name;
    newSets.value[data.id] = { weight: null, reps: null, rpe: null };
  }
};

const deleteItem = async (itemId: string) => {
  if (!confirm("この種目を削除しますか？")) return;
  const { error } = await client
    .from("workout_items")
    .delete()
    .eq("id", itemId);
  if (error) {
    alert("削除エラー: " + error.message);
  } else {
    workoutItems.value = workoutItems.value.filter((i) => i.id !== itemId);
    sets.value = sets.value.filter((s) => s.workout_item_id !== itemId);
    delete newSets.value[itemId];
  }
};

const addSet = async (itemId: string) => {
  const input = newSets.value[itemId];
  if (input.weight === null || input.reps === null) return;

  const { data, error } = await client
    .from("sets")
    .insert({
      workout_item_id: itemId,
      weight: input.weight,
      reps: input.reps,
      rpe: input.rpe,
    })
    .select()
    .single();

  if (error) {
    alert("セット記録エラー: " + error.message);
  } else if (data) {
    sets.value.push(data);
    // Keep weight for convenience, clear reps? or keep both? keeping both is usually nice.
    // input.reps = null
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
  fetchWorkoutData();
});
</script>
