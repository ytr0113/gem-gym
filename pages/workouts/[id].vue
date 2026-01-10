<template>
  <div>
    <div v-if="loading" class="text-center py-10">読み込み中...</div>
    <div v-else-if="!workout">ワークアウトが見つかりません。</div>
    <div v-else class="space-y-6 pb-24">
      <!-- Header -->
      <div class="bg-white px-4 py-5 shadow sm:rounded-lg sm:px-6">
        <div class="md:flex md:items-center md:justify-between">
          <div class="min-w-0 flex-1">
            <h2 class="text-2xl font-bold leading-7 text-gray-900 sm:truncate sm:text-3xl sm:tracking-tight">
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
      <div class="space-y-6" ref="itemsContainer">
        <div
          v-for="item in workoutItems"
          :key="item.id"
          class="bg-white shadow sm:rounded-lg overflow-hidden border border-gray-100"
        >
          <div class="px-4 py-3 sm:px-6 flex justify-between items-center bg-gray-50 border-b border-gray-200">
            <div class="flex items-center space-x-2">
              <h3 class="text-base font-bold text-gray-900">
                {{ getExerciseInfo(item.exercise_id).name }}
              </h3>
              <span class="inline-flex items-center rounded-full bg-indigo-50 px-2 py-0.5 text-xs font-medium text-indigo-700 ring-1 ring-inset ring-indigo-700/10">
                {{ getExerciseInfo(item.exercise_id).muscle || 'その他' }}
              </span>
            </div>
            <button
              @click="deleteItem(item.id)"
              class="p-1.5 text-gray-400 hover:text-red-500 transition-colors"
              title="種目を削除"
            >
              <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
              </svg>
            </button>
          </div>

          <div class="border-t border-gray-100">
            <div class="sm:divide-y sm:divide-gray-200">
              <!-- Sets Header -->
              <div class="grid grid-cols-12 gap-2 px-4 py-2 text-[10px] font-bold text-gray-400 uppercase tracking-widest text-center items-center">
                <div class="col-span-1">#</div>
                <div class="col-span-3">重量 <span class="hidden sm:inline">(kg)</span></div>
                <div class="col-span-3">レップ<span class="hidden sm:inline">数</span></div>
                <div class="col-span-3">RPE</div>
                <div class="col-span-2">操作</div>
              </div>

              <!-- Sets List -->
              <div
                v-for="(set, index) in getSets(item.id)"
                :key="set.id"
                class="grid grid-cols-12 gap-2 px-4 py-3 items-center text-center border-t border-gray-50"
              >
                <!-- Read Mode -->
                <template v-if="editingSetId !== set.id">
                  <div class="col-span-1 text-sm font-medium text-gray-500">{{ index + 1 }}</div>
                  <div class="col-span-3 text-sm text-gray-900 font-semibold whitespace-nowrap">
                    <template v-if="set.weight === 0">
                      <span class="text-indigo-600 font-bold">自重</span>
                    </template>
                    <template v-else>
                      {{ set.weight }}<span class="text-[10px] ml-0.5 font-normal text-gray-400">kg</span>
                    </template>
                  </div>
                  <div class="col-span-3 text-sm text-gray-900 font-semibold whitespace-nowrap">{{ set.reps }}<span class="text-[10px] ml-0.5 font-normal text-gray-400">回</span></div>
                  <div class="col-span-3">
                    <span v-if="set.rpe" class="inline-flex items-center rounded-md bg-yellow-50 px-2 py-1 text-xs font-medium text-yellow-800 ring-1 ring-inset ring-yellow-600/20">
                      {{ set.rpe }}
                    </span>
                    <span v-else class="text-gray-300">-</span>
                  </div>
                  <div class="col-span-2 flex justify-center space-x-2">
                    <button @click="startEditSet(set)" class="p-1 text-gray-400 hover:text-indigo-600 transition-colors">
                      <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
                      </svg>
                    </button>
                    <button @click="deleteSet(set.id)" class="p-1 text-gray-400 hover:text-red-500 transition-colors">
                      <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                      </svg>
                    </button>
                  </div>
                </template>

                <!-- Edit Mode -->
                <template v-else>
                  <div class="col-span-1 text-xs text-gray-500">{{ index + 1 }}</div>
                  <div class="col-span-3 flex items-center space-x-1">
                    <input v-model.number="editingSetData.weight" type="number" step="0.5" class="w-16 text-center text-sm border-gray-300 rounded-md p-1 shadow-sm focus:ring-indigo-500 focus:border-indigo-500" />
                    <button @click="editingSetData.weight = 0" type="button" class="flex-shrink-0 p-1 bg-gray-100 hover:bg-gray-200 rounded text-[10px] text-gray-600 transition-colors whitespace-nowrap">自重</button>
                  </div>
                  <div class="col-span-3">
                    <input v-model.number="editingSetData.reps" type="number" class="w-full text-center text-sm border-gray-300 rounded-md p-1 shadow-sm focus:ring-indigo-500 focus:border-indigo-500" />
                  </div>
                  <div class="col-span-3">
                    <select v-model.number="editingSetData.rpe" class="w-full text-center text-sm border-gray-300 rounded-md p-1 shadow-sm focus:ring-indigo-500 focus:border-indigo-500">
                      <option :value="null">-</option>
                      <option :value="10">10</option>
                      <option :value="9">9</option>
                      <option :value="7">7</option>
                      <option :value="5">5</option>
                    </select>
                  </div>
                  <div class="col-span-2 flex justify-center space-x-1">
                    <button @click="saveSet" class="text-indigo-600 hover:text-indigo-900">
                      <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
                      </svg>
                    </button>
                    <button @click="cancelEdit" class="text-gray-400 hover:text-gray-600">
                      <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                      </svg>
                    </button>
                  </div>
                </template>
              </div>

              <!-- Add Set Form (Quick Add) -->
              <div class="px-4 py-3 bg-gray-50/50">
                <form @submit.prevent="addSet(item.id)" class="grid grid-cols-12 gap-2 items-center">
                  <div class="col-span-1 text-center text-[10px] font-bold text-gray-400">ADD</div>
                  <div class="col-span-3 flex items-center space-x-1">
                    <input v-model.number="newSets[item.id].weight" type="number" step="0.5" placeholder="kg" class="block w-full min-w-0 rounded-md border-0 py-1.5 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 placeholder:text-gray-300 focus:ring-2 focus:ring-inset focus:ring-indigo-600 sm:text-sm text-center" required />
                    <button type="button" @click="newSets[item.id].weight = 0" class="flex-shrink-0 px-1.5 py-1.5 bg-white border border-gray-300 shadow-sm hover:bg-gray-50 rounded text-[10px] font-bold text-gray-600 transition-colors whitespace-nowrap">自重</button>
                  </div>
                  <div class="col-span-3 relative">
                    <input v-model.number="newSets[item.id].reps" type="number" placeholder="回" class="block w-full rounded-md border-0 py-1.5 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 placeholder:text-gray-300 focus:ring-2 focus:ring-inset focus:ring-indigo-600 sm:text-sm text-center" required />
                  </div>
                  <select v-model.number="newSets[item.id].rpe" class="col-span-3 block w-full rounded-md border-0 py-1.5 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 focus:ring-2 focus:ring-inset focus:ring-indigo-600 sm:text-sm text-center">
                    <option :value="null">RPEなし</option>
                    <option :value="10">10: 限界</option>
                    <option :value="9">9: 1回可能</option>
                    <option :value="7">7: 2-3回可能</option>
                    <option :value="5">5: 余裕</option>
                  </select>
                  <div class="col-span-2 text-center">
                    <button type="submit" class="inline-flex justify-center rounded-md bg-indigo-600 p-2 text-sm font-semibold text-white shadow-sm hover:bg-indigo-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600 w-full transition-all">
                      <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
                      </svg>
                    </button>
                  </div>
                </form>
              </div>

              <!-- Note Field (Moved to Bottom) -->
              <div class="px-4 py-3 bg-white border-t border-gray-100">
                <div class="flex items-start space-x-2">
                  <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 text-gray-400 mt-1" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
                  </svg>
                  <textarea
                    v-model="item.note"
                    @blur="updateItemNote(item)"
                    placeholder="この種目のメモを追加..."
                    rows="1"
                    class="block w-full border-0 p-0 text-sm text-gray-600 placeholder:text-gray-400 focus:ring-0 resize-none bg-transparent"
                  ></textarea>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div v-if="workoutItems.length === 0" class="text-center py-20 bg-white shadow sm:rounded-lg border-2 border-dashed border-gray-200">
          <svg xmlns="http://www.w3.org/2000/svg" class="mx-auto h-12 w-12 text-gray-300" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10" />
          </svg>
          <p class="mt-2 text-sm font-medium text-gray-500">種目がまだありません。</p>
          <div class="mt-6">
            <button @click="showExerciseSelector = true" type="button" class="inline-flex items-center px-4 py-2 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-700">
              最初の種目を追加
            </button>
          </div>
        </div>
      </div>

      <!-- Sticky Add Exercise Button (Smaller) -->
      <div class="fixed bottom-6 right-6 z-40">
        <button
          @click="showExerciseSelector = true"
          type="button"
          class="flex items-center justify-center space-x-2 px-4 py-2.5 border border-transparent shadow-lg text-sm font-bold rounded-full text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-4 focus:ring-indigo-500/50 transition-all active:scale-95"
        >
          <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
          </svg>
          <span>種目を追加</span>
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
const workout = ref<Database["public"]["Tables"]["workouts"]["Row"] | null>(null);
const workoutItems = ref<Database["public"]["Tables"]["workout_items"]["Row"][]>([]);
const exercisesCache = ref<Record<string, {name: string, muscle: string | null}>>({});
const sets = ref<Database["public"]["Tables"]["sets"]["Row"][]>([]);

const showExerciseSelector = ref(false);
const itemsContainer = ref<HTMLElement | null>(null);

// Local state for new sets: itemId -> { weight, reps, rpe }
const newSets = ref<Record<string, { weight: number | null; reps: number | null; rpe: number | null }>>({});

// Editing state
const editingSetId = ref<string | null>(null);
const editingSetData = ref<{ weight: number; reps: number; rpe: number | null; }>({ weight: 0, reps: 0, rpe: null });

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

    // Fetch Sets
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

    // Fetch Exercise Info
    const exerciseIds = [...new Set(workoutItems.value.map((i) => i.exercise_id))];
    if (exerciseIds.length > 0) {
      const { data: eData, error: eError } = await client
        .from("exercises")
        .select("id, name, target_muscle")
        .in("id", exerciseIds);
      if (eError) throw eError;
      (eData as any[])?.forEach((e) => {
        exercisesCache.value[e.id] = { name: e.name, muscle: e.target_muscle };
      });
    }
  } catch (e: any) {
    console.error(e);
    alert("データ取得エラー: " + e.message);
  } finally {
    loading.value = false;
  }
};

const getExerciseInfo = (id: string) =>
  exercisesCache.value[id] || { name: "読み込み中...", muscle: null };

const getSets = (itemId: string) =>
  sets.value.filter((s) => s.workout_item_id === itemId);

const addExercise = async (exercise: Database["public"]["Tables"]["exercises"]["Row"]) => {
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
    const newItem = data as Database["public"]["Tables"]["workout_items"]["Row"];
    workoutItems.value.push(newItem);
    exercisesCache.value[exercise.id] = { name: exercise.name, muscle: exercise.target_muscle };
    newSets.value[newItem.id] = { weight: null, reps: null, rpe: null };
    
    // Auto scroll to bottom
    nextTick(() => {
        window.scrollTo({ top: document.body.scrollHeight, behavior: 'smooth' });
    });
  }
};

const updateItemNote = async (item: Database["public"]["Tables"]["workout_items"]["Row"]) => {
  const { error } = await client
    .from("workout_items")
    .update({ note: item.note })
    .eq("id", item.id);
  if (error) {
    console.error("Note update error:", error);
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
    // Keep values for NEXT set auto-fill
    newSets.value[itemId] = { weight: input.weight, reps: input.reps, rpe: input.rpe };
  }
};

const startEditSet = (set: Database["public"]["Tables"]["sets"]["Row"]) => {
  editingSetId.value = set.id;
  editingSetData.value = {
    weight: set.weight || 0,
    reps: set.reps || 0,
    rpe: set.rpe,
  };
};

const cancelEdit = () => {
  editingSetId.value = null;
};

const saveSet = async () => {
  if (!editingSetId.value) return;

  const { data, error } = await client
    .from("sets")
    .update({
      weight: editingSetData.value.weight,
      reps: editingSetData.value.reps,
      rpe: editingSetData.value.rpe,
    })
    .eq("id", editingSetId.value)
    .select()
    .single();

  if (error) {
    alert("更新エラー: " + error.message);
  } else if (data) {
    const index = sets.value.findIndex((s) => s.id === editingSetId.value);
    if (index !== -1) {
      sets.value[index] = data;
    }
    editingSetId.value = null;
  }
};

const deleteSet = async (setId: string) => {
  if (!confirm("このセットを削除しますか？")) return;
  const { error } = await client.from("sets").delete().eq("id", setId);
  if (error) {
    alert("削除エラー: " + error.message);
  } else {
    sets.value = sets.value.filter((s) => s.id !== setId);
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
