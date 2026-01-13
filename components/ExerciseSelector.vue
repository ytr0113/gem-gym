<template>
  <div
    class="fixed z-10 inset-0 overflow-y-auto"
    aria-labelledby="modal-title"
    role="dialog"
    aria-modal="true"
  >
    <div
      class="flex items-center sm:items-end justify-center min-h-screen pt-4 px-4 pb-20 text-center sm:block sm:p-0"
    >
      <div
        class="fixed inset-0 bg-gray-600 bg-opacity-75 backdrop-blur-sm transition-opacity"
        aria-hidden="true"
        @click="$emit('close')"
      ></div>

      <span
        class="hidden sm:inline-block sm:align-middle sm:h-screen"
        aria-hidden="true"
        >&#8203;</span
      >

      <div
        class="inline-block align-middle bg-white rounded-2xl px-4 pt-5 pb-4 text-left overflow-hidden shadow-2xl transform transition-all sm:my-8 sm:align-middle sm:max-w-lg sm:w-full sm:p-6"
      >
        <div>
          <h3
            class="text-lg leading-6 font-medium text-gray-900"
            id="modal-title"
          >
            種目を選択
          </h3>
          <div class="mt-2">
            <input
              type="text"
              v-model="searchQuery"
              placeholder="種目名で検索..."
              class="shadow-sm focus:ring-indigo-500 focus:border-indigo-500 block w-full sm:text-sm border-gray-300 rounded-md p-2 border"
            />
          </div>

          <!-- Category Tags (Quick Scroll or Filter) -->
          <div v-if="!searchQuery" class="mt-3 flex flex-wrap gap-2">
            <button
              v-for="cat in categoryOrder"
              :key="cat"
              @click="toggleCategory(cat, true)"
              class="px-2 py-1 text-xs bg-gray-100 hover:bg-gray-200 rounded text-gray-600"
            >
              {{ cat }}
            </button>
          </div>

          <div class="mt-4 max-h-[60vh] sm:max-h-96 overflow-y-auto" ref="scrollContainer">
            <!-- Search Results -->
            <div v-if="searchQuery">
                <ul class="divide-y divide-gray-200">
                  <li
                    v-for="exercise in filteredExercises"
                    :key="exercise.id"
                    @click="selectExercise(exercise)"
                    class="py-2 px-2 hover:bg-gray-100 cursor-pointer flex justify-between"
                  >
                    <span>{{ exercise.name }}</span>
                    <span class="text-xs text-gray-500 self-center">{{
                      exercise.target_muscle || "その他"
                    }}</span>
                  </li>
                  <li
                    v-if="filteredExercises.length === 0"
                    class="py-4 text-center text-sm text-gray-500"
                  >
                    「{{ searchQuery }}」は見つかりません。
                    <div class="mt-2 flex flex-col space-y-2">
                        <p class="text-xs">新規作成する部位を選択して作成：</p>
                        <div class="flex flex-wrap justify-center gap-2">
                            <button
                                v-for="cat in categoryOrder"
                                :key="cat"
                                @click="createExercise(cat, searchQuery)"
                                class="px-3 py-1 bg-indigo-50 text-indigo-700 rounded-md text-xs hover:bg-indigo-100 border border-indigo-200"
                            >
                                {{ cat }}で作成
                            </button>
                        </div>
                    </div>
                  </li>
                </ul>
            </div>

            <!-- Categorized List (Accordion) -->
            <div v-else>
                <div v-for="cat in categoryOrder" :key="cat" :id="'cat-' + cat" class="mb-2">
                    <div 
                      class="flex items-center justify-between bg-gray-50 rounded-md px-3 py-2 cursor-pointer border border-gray-100 sticky top-0 z-10"
                      @click="toggleCategory(cat)"
                    >
                      <div class="flex items-center space-x-2">
                        <svg 
                          xmlns="http://www.w3.org/2000/svg" 
                          class="h-4 w-4 text-gray-400 transition-transform duration-200"
                          :class="{ 'rotate-90': openCategories.has(cat) }"
                          fill="none" viewBox="0 0 24 24" stroke="currentColor"
                        >
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
                        </svg>
                        <span class="text-sm font-bold text-gray-700 tracking-wider">
                          {{ cat }}
                        </span>
                        <span class="text-xs text-gray-400 font-normal">
                          ({{ exercisesByGroup[cat]?.length || 0 }})
                        </span>
                      </div>
                      <button 
                        @click.stop="startInlineCreate(cat)"
                        class="p-1 hover:bg-gray-200 rounded-full text-indigo-600 transition-colors"
                        title="種目を追加"
                      >
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
                        </svg>
                      </button>
                    </div>

                    <div v-show="openCategories.has(cat)" class="mt-1 transition-all">
                        <!-- Inline Creation Form -->
                        <div v-if="inlineCreateCategory === cat" class="p-2 bg-indigo-50 border-x border-b border-indigo-100 rounded-b-md mb-2">
                          <div class="flex space-x-2">
                            <input 
                              type="text" 
                              v-model="inlineCreateName"
                              placeholder="新しい種目名"
                              class="flex-1 text-sm border-indigo-200 rounded-md p-1.5 focus:ring-indigo-500 focus:border-indigo-500"
                              @keyup.enter="confirmInlineCreate"
                              ref="inlineInput"
                            />
                            <button 
                              @click="confirmInlineCreate"
                              class="px-3 py-1 bg-indigo-600 text-white text-xs rounded-md hover:bg-indigo-700"
                            >
                              追加
                            </button>
                            <button 
                              @click="cancelInlineCreate"
                              class="px-2 py-1 text-gray-500 hover:text-gray-700"
                            >
                              <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                              </svg>
                            </button>
                          </div>
                        </div>

                        <ul class="divide-y divide-gray-100 ml-2">
                            <li
                                v-for="exercise in exercisesByGroup[cat] || []"
                                :key="exercise.id"
                                @click="selectExercise(exercise)"
                                class="py-3 px-3 hover:bg-gray-50 cursor-pointer text-sm text-gray-700 flex justify-between rounded-md items-center"
                            >
                                <span>{{ exercise.name }}</span>
                                <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 text-gray-300" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
                                </svg>
                            </li>
                            <li v-if="!(exercisesByGroup[cat]?.length)" class="py-3 px-3 text-xs text-gray-400 italic">
                                登録されていません
                            </li>
                        </ul>
                    </div>
                </div>
            </div>
          </div>
        </div>
        <div class="mt-5 sm:mt-6">
          <button
            type="button"
            class="mt-3 w-full inline-flex justify-center rounded-md border border-gray-300 shadow-sm px-4 py-2 bg-white text-base font-medium text-gray-700 hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 sm:text-sm"
            @click="$emit('close')"
          >
            キャンセル
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import type { Database } from "~/types/database";

const props = defineProps<{
  // nothing needed yet
}>();

const emits = defineEmits(["close", "select"]);

const client = useSupabaseClient<Database>();
const user = useSupabaseUser();
const exercises = ref<Database["public"]["Tables"]["exercises"]["Row"][]>([]);
const searchQuery = ref("");
const scrollContainer = ref<HTMLElement | null>(null);
const openCategories = ref<Set<string>>(new Set());

// Inline creation state
const inlineCreateCategory = ref<string | null>(null);
const inlineCreateName = ref("");
const inlineInput = ref<HTMLInputElement[] | null>(null);

const categoryOrder = ["胸", "背中", "腹", "肩", "腕", "脚", "その他"];

const exercisesByGroup = computed(() => {
  const groups: Record<string, Database["public"]["Tables"]["exercises"]["Row"][]> = {};
  exercises.value.forEach(e => {
    const cat = e.target_muscle || "その他";
    if (!groups[cat]) groups[cat] = [];
    groups[cat].push(e);
  });
  return groups;
});

const filteredExercises = computed(() => {
  if (!searchQuery.value) return exercises.value;
  return exercises.value.filter((e) =>
    e.name.toLowerCase().includes(searchQuery.value.toLowerCase())
  );
});

const toggleCategory = (cat: string, forceOpen = false) => {
  if (forceOpen) {
    openCategories.value.add(cat);
    // Smooth scroll after a tick
    nextTick(() => {
      const el = document.getElementById('cat-' + cat);
      if (el) el.scrollIntoView({ behavior: 'smooth', block: 'start' });
    });
    return;
  }

  if (openCategories.value.has(cat)) {
    openCategories.value.delete(cat);
  } else {
    openCategories.value.add(cat);
  }
};

const fetchExercises = async () => {
  try {
    const {
      data: { user: currentUser },
    } = await client.auth.getUser();

    let query = client.from("exercises").select("*");

    if (!currentUser || !currentUser.id || currentUser.id === "undefined") {
      console.log("[ExerciseSelector] No valid user, fetch system exercises only");
      query = query.eq("user_id", "00000000-0000-0000-0000-000000000000");
    } else {
      console.log("[ExerciseSelector] Fetching for UserID:", currentUser.id);
      query = query.or(
        `user_id.eq.${currentUser.id},user_id.eq.00000000-0000-0000-0000-000000000000`
      );
    }

    const { data, error } = await query.order("name");

    if (error) {
        console.error("[ExerciseSelector] Fetch error:", error);
    } else {
        exercises.value = data || [];
    }
  } catch (e) {
    console.error("[ExerciseSelector] Error in fetchExercises:", e);
  }
};

const selectExercise = (
  exercise: Database["public"]["Tables"]["exercises"]["Row"]
) => {
  emits("select", exercise);
};

const startInlineCreate = (category: string) => {
  openCategories.value.add(category);
  inlineCreateCategory.value = category;
  inlineCreateName.value = "";
  // Focus input on next tick
  nextTick(() => {
    if (inlineInput.value && inlineInput.value.length > 0) {
      inlineInput.value[0].focus();
    }
  });
};

const cancelInlineCreate = () => {
  inlineCreateCategory.value = null;
  inlineCreateName.value = "";
};

const confirmInlineCreate = async () => {
  if (!inlineCreateName.value || !inlineCreateCategory.value) return;
  await createExercise(inlineCreateCategory.value, inlineCreateName.value);
  cancelInlineCreate();
};

const createExercise = async (category: string, name: string) => {
  if (!name) return;

  const {
    data: { user: currentUser },
    error: authError,
  } = await client.auth.getUser();

  if (authError || !currentUser) {
    alert("ログインセッションが無効です。もう一度ログインし直してください。");
    return;
  }

  const { data, error } = await client
    .from("exercises")
    .insert({
      user_id: currentUser.id,
      name: name,
      target_muscle: category,
    })
    .select()
    .single();

  if (error) {
    alert("作成エラー: " + error.message);
  } else if (data) {
    console.log("[ExerciseSelector] Created new exercise:", data);
    exercises.value.push(data);
    selectExercise(data);
  }
};

onMounted(() => {
  fetchExercises();
});

// Watch for auth changes to refetch
watch(user, (newUser) => {
  fetchExercises();
});
</script>

