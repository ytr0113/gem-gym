<template>
  <div v-if="user" class="space-y-6">
    <!-- ヘッダー -->
    <div class="flex items-center justify-between">
      <div>
        <h2 class="text-2xl font-black text-indigo-900 tracking-tight">身体データ記録</h2>
        <p class="text-[10px] font-black text-gray-400 uppercase tracking-widest leading-none mt-1">自分の進化を数値で追おう</p>
      </div>

      <button 
        @click="openModal"
        class="inline-flex items-center px-4 py-2.5 bg-indigo-600 text-white rounded-xl font-bold text-sm shadow-lg shadow-indigo-200 active:scale-95 transition-all hover:bg-indigo-700"
      >
        <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 mr-1.5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="3">
          <path stroke-linecap="round" stroke-linejoin="round" d="M12 4v16m8-8H4" />
        </svg>
        記録する
      </button>
    </div>

    <!-- 期間選択（ヘッダーの下に配置） -->
    <div class="flex justify-end">
      <div class="inline-flex p-1 bg-gray-100 rounded-xl">
        <button 
          v-for="p in periods" 
          :key="p.value"
          @click="selectedPeriod = p.value"
          class="px-3 py-1.5 text-[10px] font-black uppercase tracking-wider rounded-lg transition-all"
          :class="selectedPeriod === p.value ? 'bg-white text-indigo-600 shadow-sm' : 'text-gray-400 hover:text-gray-600'"
        >
          {{ p.label }}
        </button>
      </div>
    </div>

    <!-- 目標と進捗状況 -->
    <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
      <div class="bg-white p-5 rounded-2xl shadow-sm border border-gray-100 flex items-center justify-between">
        <div class="space-y-1">
          <p class="text-[10px] font-black text-gray-400 uppercase tracking-widest leading-none">現在の目標体重</p>
          <div class="flex items-baseline space-x-2">
            <template v-if="editingGoal">
              <input v-model.number="tempTargetWeight" type="number" step="0.1" class="w-20 text-xl font-black text-indigo-900 border-b border-indigo-200 focus:outline-none focus:border-indigo-500" />
              <span class="text-sm font-normal text-gray-400">kg</span>
            </template>
            <template v-else>
              <p class="text-2xl font-black text-indigo-900 leading-none">{{ profile?.target_weight || '--' }}<span class="text-sm font-normal ml-1 text-gray-400">kg</span></p>
            </template>
          </div>
        </div>
        <button @click="toggleGoalEdit" class="p-2 hover:bg-gray-50 rounded-xl transition-colors text-gray-400 hover:text-indigo-600">
          <svg v-if="editingGoal" xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M5 13l4 4L19 7" />
          </svg>
          <svg v-else xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
          </svg>
        </button>
      </div>

      <div class="bg-indigo-50 p-5 rounded-2xl border border-indigo-100 flex items-center justify-between">
        <div class="space-y-1">
          <p class="text-[10px] font-black text-indigo-400 uppercase tracking-widest leading-none">目標まであと</p>
          <p class="text-2xl font-black text-indigo-600 leading-none">
            {{ targetDiff !== null ? targetDiff.toFixed(1) : '--' }}<span class="text-sm font-normal ml-1">kg</span>
          </p>
        </div>
        <div class="h-10 w-10 rounded-full bg-white flex items-center justify-center text-indigo-600 shadow-sm">
          <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5">
            <path stroke-linecap="round" stroke-linejoin="round" d="M13 7h8m0 0v8m0-8l-8 8-4-4-6 6" />
          </svg>
        </div>
      </div>
    </div>

    <!-- 推移グラフ -->
    <div class="bg-white p-6 rounded-2xl shadow-sm border border-gray-100">
      <div class="flex items-center justify-between mb-6">
        <h3 class="text-xs font-black text-gray-400 uppercase tracking-[0.2em]">推移グラフ</h3>
        <span class="text-[10px] font-bold text-gray-300 uppercase">
          {{ selectedPeriod === 0 ? '全期間' : `過去 ${selectedPeriodLabel}` }}
        </span>
      </div>
      <div class="h-72">
        <ClientOnly>
          <BodyChart 
            :labels="chartData.labels" 
            :weight-data="chartData.weights" 
            :body-fat-data="chartData.fats"
            :target-weight="profile?.target_weight"
          />
          <template #fallback>
            <div class="h-full bg-gray-50 rounded-xl flex items-center justify-center text-gray-300 text-xs italic">
              読み込み中...
            </div>
          </template>
        </ClientOnly>
      </div>
    </div>

    <!-- 履歴リスト -->
    <div class="bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden">
      <div class="px-6 py-4 border-b border-gray-50 flex justify-between items-center">
        <h3 class="text-xs font-black text-gray-400 uppercase tracking-[0.2em]">過去の記録</h3>
      </div>
      <div class="overflow-x-auto">
        <table class="w-full text-left border-collapse">
          <thead>
            <tr class="bg-gray-50/50">
              <th class="px-6 py-3 text-[10px] font-black text-gray-400 uppercase tracking-widest">日付</th>
              <th class="px-6 py-3 text-[10px] font-black text-gray-400 uppercase tracking-widest text-right">体重</th>
              <th class="px-6 py-3 text-[10px] font-black text-gray-400 uppercase tracking-widest text-right">体脂肪率</th>
              <th class="px-6 py-3 text-[10px] font-black text-gray-400 uppercase tracking-widest text-right">変化</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-gray-50">
            <tr v-for="(record, idx) in sortedFilteredHistory" :key="record.id" class="hover:bg-gray-50/50 transition-colors">
              <td class="px-6 py-3 text-xs font-bold text-gray-500">{{ formatDate(record.date) }}</td>
              <td class="px-6 py-3 text-xs font-black text-indigo-900 text-right">{{ record.weight }} kg</td>
              <td class="px-6 py-3 text-xs font-bold text-gray-400 text-right">{{ record.body_fat ? record.body_fat + ' %' : '-' }}</td>
              <td class="px-6 py-3 text-xs font-black text-right">
                <span v-if="idx < sortedFilteredHistory.length - 1" :class="getDiffClass(record, sortedFilteredHistory[idx+1])">
                  {{ getDiffText(record, sortedFilteredHistory[idx+1]) }}
                </span>
                <span v-else class="text-gray-300">-</span>
              </td>
            </tr>
            <tr v-if="periodHistory.length === 0">
              <td colspan="4" class="px-6 py-8 text-center text-sm italic text-gray-300">期間内の記録がありません</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- 記録入力モーダル -->
    <div v-if="showRecordModal" class="fixed inset-0 z-[60] flex items-center justify-center p-4">
      <div class="absolute inset-0 bg-indigo-950/40 backdrop-blur-sm" @click="showRecordModal = false"></div>
      <div class="relative bg-white w-full max-w-sm rounded-3xl shadow-2xl overflow-hidden animate-in fade-in zoom-in duration-200">
        <div class="bg-indigo-600 p-6 text-white text-center">
          <h3 class="text-xl font-black tracking-tight">記録を入力</h3>
          <p class="text-indigo-200 text-[10px] font-bold uppercase tracking-widest mt-1">過去の日付も選べます</p>
        </div>
        <div class="p-6">
          <form @submit.prevent="saveMetrics" class="space-y-6">
            <div class="space-y-1.5">
              <label class="text-[10px] font-black text-gray-400 uppercase tracking-widest">日付</label>
              <input 
                v-model="form.date" 
                type="date" 
                class="w-full bg-gray-50 border-none rounded-2xl px-4 py-3 text-sm font-bold text-indigo-900 focus:ring-2 focus:ring-indigo-500 transition-all font-mono" 
                required 
              />
            </div>

            <div class="grid grid-cols-2 gap-4">
              <div class="space-y-1.5">
                <label class="text-[10px] font-black text-gray-400 uppercase tracking-widest">体重 (kg)</label>
                <input 
                  v-model.number="form.weight" 
                  type="number" 
                  step="0.1" 
                  placeholder="00.0" 
                  class="w-full bg-gray-50 border-none rounded-2xl px-4 py-3 text-xl font-black text-indigo-900 focus:ring-2 focus:ring-indigo-500 transition-all" 
                  required 
                />
              </div>
              <div class="space-y-1.5">
                <label class="text-[10px] font-black text-gray-400 uppercase tracking-widest">体脂肪 (%)</label>
                <input 
                  v-model.number="form.bodyFat" 
                  type="number" 
                  step="0.1" 
                  placeholder="00.0" 
                  class="w-full bg-gray-50 border-none rounded-2xl px-4 py-3 text-xl font-black text-indigo-900 focus:ring-2 focus:ring-indigo-500 transition-all" 
                />
              </div>
            </div>
            
            <div class="flex space-x-3">
              <button 
                type="button" 
                @click="showRecordModal = false"
                class="flex-1 px-4 py-3 text-sm font-bold text-gray-400 hover:text-gray-600 transition-colors"
              >
                キャンセル
              </button>
              <button 
                type="submit" 
                :disabled="saving"
                class="flex-[2] bg-indigo-600 text-white font-black px-6 py-3 rounded-2xl shadow-lg shadow-indigo-100 hover:bg-indigo-700 active:scale-95 transition-all disabled:opacity-50"
              >
                {{ saving ? '保存中...' : '記録を保存' }}
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  </div>
  <div v-else class="text-center py-20 text-gray-400">
    読み込み中...
  </div>
</template>

<script setup lang="ts">
import type { Database } from "~/types/database";
import BodyChart from "~/components/charts/BodyChart.vue";

const client = useSupabaseClient<Database>();
const user = useSupabaseUser();

const { getTodayJST } = useDate();

const loading = ref(true);
const saving = ref(false);
const showRecordModal = ref(false);
const profile = ref<Database["public"]["Tables"]["user_profiles"]["Row"] | null>(null);
const history = ref<Database["public"]["Tables"]["body_metrics"]["Row"][]>([]);

const form = ref({
  date: getTodayJST(),
  weight: null as number | null,
  bodyFat: null as number | null,
});

const editingGoal = ref(false);
const tempTargetWeight = ref<number | null>(null);

const periods = [
  { label: '1週間', value: 7 },
  { label: '1ヶ月', value: 30 },
  { label: '3ヶ月', value: 90 },
  { label: '6ヶ月', value: 180 },
  { label: '全期間', value: 0 },
];
const selectedPeriod = ref(30);

const selectedPeriodLabel = computed(() => {
  return periods.find(p => p.value === selectedPeriod.value)?.label || '';
});

// 信頼性の高いユーザーIDを取得するためのヘルパー
const getValidUserId = async () => {
  const { data: { user: authUser } } = await client.auth.getUser();
  const id = authUser?.id || user.value?.id;
  
  if (!id || id === 'undefined') {
    return null;
  }
  return id;
};

const openModal = () => {
  form.value.date = new Date().toISOString().split('T')[0];
  updateFormFromHistory();
  showRecordModal.value = true;
};

const updateFormFromHistory = () => {
  const record = history.value.find(h => h.date === form.value.date);
  if (record) {
    form.value.weight = record.weight;
    form.value.bodyFat = record.body_fat;
  } else {
    form.value.weight = null;
    form.value.bodyFat = null;
  }
};

watch(() => form.value.date, () => {
  if (showRecordModal.value) {
    updateFormFromHistory();
  }
});

const fetchData = async () => {
  const userId = await getValidUserId();
  if (!userId) {
    loading.value = false;
    return;
  }
  
  loading.value = true;
  try {
    const { data: pData, error: pError } = await client
      .from("user_profiles")
      .select("*")
      .eq("user_id", userId)
      .maybeSingle(); 
    
    if (pError && pError.code !== 'PGRST116') console.error("Profile fetch error:", pError);
    
    profile.value = pData;
    tempTargetWeight.value = pData?.target_weight || null;

    const { data: hData, error: hError } = await client
      .from("body_metrics")
      .select("*")
      .eq("user_id", userId)
      .order("date", { ascending: false })
      .limit(500); // 全期間表示に対応するため多めに取得
    
    if (hError) console.error("History fetch error:", hError);
    
    history.value = hData || [];

    const today = new Date().toISOString().split('T')[0];
    if (form.value.date === today && !showRecordModal.value) {
        updateFormFromHistory();
    }
  } catch (err) {
    console.error("fetchData unexpected error:", err);
  } finally {
    loading.value = false;
  }
};

const saveMetrics = async () => {
  const userId = await getValidUserId();
  if (!userId || !form.value.weight || !form.value.date) {
    if (!userId) alert("ログインセッションが有効ではありません。");
    return;
  }
  
  saving.value = true;
  
  try {
    const { error } = await client
      .from("body_metrics")
      .upsert({
        user_id: userId,
        date: form.value.date,
        weight: form.value.weight,
        body_fat: (form.value.bodyFat === 0 || form.value.bodyFat === null) ? null : form.value.bodyFat,
      }, {
        onConflict: 'user_id,date'
      });

    if (error) {
      alert("エラーが発生しました: " + error.message);
    } else {
      showRecordModal.value = false;
      await fetchData();
    }
  } catch (err) {
    console.error("saveMetrics unexpected error:", err);
  } finally {
    saving.value = false;
  }
};

const toggleGoalEdit = async () => {
  if (editingGoal.value) {
    await saveGoal();
  } else {
    editingGoal.value = true;
  }
};

const saveGoal = async () => {
  const userId = await getValidUserId();
  if (!userId) {
    alert("ログインセッションが見つかりません。再読み込みまたは再ログインをお試しください。");
    return;
  }
  
  try {
    const { error } = await client
      .from("user_profiles")
      .upsert({
        user_id: userId,
        target_weight: tempTargetWeight.value,
        updated_at: new Date().toISOString()
      }, {
        onConflict: 'user_id'
      });

    if (error) {
      console.error("Save Goal DB Error:", error);
      alert("保存中にエラーが発生しました: " + error.message);
    } else {
      editingGoal.value = false;
      await fetchData();
    }
  } catch (err: any) {
    console.error("Unexpected error in saveGoal:", err);
    alert("予期せぬエラーが発生しました: " + err.message);
  }
};

const targetDiff = computed(() => {
  if (!profile.value?.target_weight || history.value.length === 0) return null;
  const currentWeight = history.value[0].weight || 0;
  return currentWeight - profile.value.target_weight;
});

const periodHistory = computed(() => {
  if (selectedPeriod.value === 0) return [...history.value].reverse();
  
  const today = new Date();
  const cutoff = new Date();
  cutoff.setDate(today.getDate() - selectedPeriod.value);
  return history.value.filter(h => new Date(h.date) >= cutoff).reverse();
});

// グラフ用データの整形
const chartData = computed(() => {
  return {
    labels: periodHistory.value.map(h => {
      const d = new Date(h.date);
      return `${d.getMonth() + 1}/${d.getDate()}`;
    }),
    weights: periodHistory.value.map(h => h.weight || 0),
    fats: periodHistory.value.map(h => h.body_fat)
  };
});

const sortedFilteredHistory = computed(() => {
  return [...periodHistory.value].sort((a, b) => b.date.localeCompare(a.date));
});

const formatDate = (dateStr: string) => {
  const d = new Date(dateStr);
  return d.toLocaleDateString("ja-JP", { month: "2-digit", day: "2-digit", weekday: "short" });
};

const getDiffText = (current: any, prev: any) => {
  const diff = current.weight - prev.weight;
  if (diff === 0) return "±0";
  return (diff > 0 ? "+" : "") + diff.toFixed(1) + "kg";
};

const getDiffClass = (current: any, prev: any) => {
  const diff = current.weight - prev.weight;
  if (diff > 0) return "text-red-400 font-bold";
  if (diff < 0) return "text-blue-400 font-bold";
  return "text-gray-300";
};

watch(user, (newUser) => {
  if (newUser) fetchData();
}, { immediate: true });

onMounted(() => {
  if (user.value) fetchData();
});
</script>
