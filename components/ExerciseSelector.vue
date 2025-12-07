<template>
  <div
    class="fixed z-10 inset-0 overflow-y-auto"
    aria-labelledby="modal-title"
    role="dialog"
    aria-modal="true"
  >
    <div
      class="flex items-end justify-center min-h-screen pt-4 px-4 pb-20 text-center sm:block sm:p-0"
    >
      <div
        class="fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity"
        aria-hidden="true"
        @click="$emit('close')"
      ></div>

      <span
        class="hidden sm:inline-block sm:align-middle sm:h-screen"
        aria-hidden="true"
        >&#8203;</span
      >

      <div
        class="inline-block align-bottom bg-white rounded-lg px-4 pt-5 pb-4 text-left overflow-hidden shadow-xl transform transition-all sm:my-8 sm:align-middle sm:max-w-lg sm:w-full sm:p-6"
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
          <div class="mt-4 max-h-60 overflow-y-auto">
            <ul class="divide-y divide-gray-200">
              <li
                v-for="exercise in filteredExercises"
                :key="exercise.id"
                @click="selectExercise(exercise)"
                class="py-2 px-2 hover:bg-gray-100 cursor-pointer flex justify-between"
              >
                <span>{{ exercise.name }}</span>
                <span class="text-xs text-gray-500 self-center">{{
                  exercise.target_muscle || "-"
                }}</span>
              </li>
              <li
                v-if="filteredExercises.length === 0 && searchQuery"
                class="py-2 text-center text-sm text-gray-500"
              >
                見つかりません。「{{ searchQuery }}」を新規作成しますか？
                <button
                  @click="createExercise"
                  class="ml-2 text-indigo-600 hover:text-indigo-900 font-medium"
                >
                  作成
                </button>
              </li>
            </ul>
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

const filteredExercises = computed(() => {
  if (!searchQuery.value) return exercises.value;
  return exercises.value.filter((e) =>
    e.name.toLowerCase().includes(searchQuery.value.toLowerCase())
  );
});

const fetchExercises = async () => {
  if (!user.value) return;
  const { data, error } = await client
    .from("exercises")
    .select("*")
    .order("name");

  if (error) {
    console.error(error);
  } else {
    exercises.value = data || [];
  }
};

const selectExercise = (
  exercise: Database["public"]["Tables"]["exercises"]["Row"]
) => {
  emits("select", exercise);
};

const createExercise = async () => {
  if (!searchQuery.value) return;

  // Explicitly fetch user
  const {
    data: { user: currentUser },
    error: authError,
  } = await client.auth.getUser();

  console.log("createExercise - Auth User:", currentUser);
  console.log("createExercise - Auth Error:", authError);

  if (authError || !currentUser) {
    alert("ログインセッションが無効です。");
    return;
  }

  console.log("createExercise - ID to insert:", currentUser.id);

  const { data, error } = await client
    .from("exercises")
    .insert({
      user_id: currentUser.id,
      name: searchQuery.value,
      target_muscle: null,
    })
    .select()
    .single();

  if (error) {
    alert("作成エラー: " + error.message);
  } else if (data) {
    selectExercise(data);
  }
};

onMounted(() => {
  fetchExercises();
});
</script>
