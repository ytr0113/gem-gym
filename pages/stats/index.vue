<template>
  <div class="space-y-6">
    <!-- ヘッダーと期間選択 -->
    <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
      <div>
        <h2 class="text-2xl font-black text-indigo-900 tracking-tight">分析</h2>
        <p class="text-[10px] font-black text-gray-400 uppercase tracking-widest mt-1">
          全 {{ stats.totalWorkouts }} セッションの記録
        </p>
      </div>
      
      <!-- 期間選択ボタン -->
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

    <!-- 概要統計 -->
    <div class="grid grid-cols-1 sm:grid-cols-3 gap-4">
      <div class="bg-white p-5 rounded-2xl shadow-sm border border-gray-100">
        <p class="text-[10px] font-black text-gray-400 uppercase tracking-widest leading-none mb-1">合計トレーニング回数</p>
        <p class="text-2xl font-black text-indigo-900 leading-none">{{ periodWorkoutsCount }}<span class="text-sm font-normal ml-1">回</span></p>
      </div>
      <div class="bg-white p-5 rounded-2xl shadow-sm border border-gray-100">
        <p class="text-[10px] font-black text-gray-400 uppercase tracking-widest leading-none mb-1">合計ボリューム</p>
        <p class="text-2xl font-black text-indigo-900 leading-none">{{ formatVolume(periodTotalVolume) }}<span class="text-sm font-normal ml-1">kg</span></p>
      </div>
      <div class="bg-white p-5 rounded-2xl shadow-sm border border-gray-100">
        <p class="text-[10px] font-black text-gray-400 uppercase tracking-widest leading-none mb-1">平均ボリューム / 回</p>
        <p class="text-2xl font-black text-indigo-900 leading-none">{{ formatVolume(periodAvgVolume) }}<span class="text-sm font-normal ml-1">kg</span></p>
      </div>
    </div>

    <!-- ボリューム推移グラフ（部位別積み上げ） -->
    <div class="bg-white p-6 rounded-2xl shadow-sm border border-gray-100">
      <h3 class="text-xs font-black text-gray-400 uppercase tracking-[0.2em] mb-6">ボリュームの推移（部位別）</h3>
      <div class="h-64">
        <ClientOnly>
          <VolumeChart :labels="volumeLabels" :datasets="volumeDatasets" />
          <template #fallback>
            <div class="h-full bg-gray-50 rounded-xl flex items-center justify-center text-gray-300 text-xs italic">
              読み込み中...
            </div>
          </template>
        </ClientOnly>
      </div>
    </div>

    <!-- 部位別ボリューム比率（プログレスバー形式） -->
    <div class="bg-white p-6 rounded-2xl shadow-sm border border-gray-100">
      <h3 class="text-xs font-black text-gray-400 uppercase tracking-[0.2em] mb-6">期間内ボリューム比率</h3>
      <div class="space-y-4">
        <NuxtLink 
          v-for="muscle in periodMuscleDistribution" 
          :key="muscle.name"
          :to="`/stats/${muscle.slug}`"
          class="block group cursor-pointer"
        >
          <div class="flex justify-between items-center mb-1">
            <span class="text-sm font-bold text-gray-700 group-hover:text-indigo-600 transition-colors">{{ muscle.name }}</span>
            <span class="text-xs font-bold text-gray-400 group-hover:text-gray-600 transition-colors">{{ formatVolume(muscle.volume) }} kg ({{ muscle.percentage }}%)</span>
          </div>
          <div class="w-full bg-gray-100 rounded-full h-2">
            <div 
              class="h-2 rounded-full transition-all duration-1000" 
              :style="{ width: muscle.percentage + '%', backgroundColor: muscle.color }"
            ></div>
          </div>
        </NuxtLink>
        <div v-if="periodMuscleDistribution.length === 0" class="text-center py-8 text-gray-300 text-sm italic">
          記録がありません
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

const MUSCLE_COLORS: Record<string, string> = {
  '胸': '#ef4444',
  '背中': '#3b82f6',
  '肩': '#f59e0b',
  '腕': '#8b5cf6',
  '脚': '#10b981',
  '下半身': '#10b981',
  'その他': '#94a3b8'
};

const MUSCLE_SLUGS: Record<string, string> = {
  '胸': 'chest',
  '背中': 'back',
  '肩': 'shoulders',
  '腕': 'arms',
  '脚': 'legs',
  '下半身': 'legs',
  'その他': 'other'
};

const periods = [
  { label: '1週', value: 7 },
  { label: '1ヶ月', value: 30 },
  { label: '3ヶ月', value: 90 },
  { label: '6ヶ月', value: 180 },
];

const selectedPeriod = ref(30);
const rawWorkouts = ref<any[]>([]);

const stats = ref({
  totalWorkouts: 0,
});

// 選択された期間に基づいてフィルタリング・加工されたデータ
const periodWorkouts = computed(() => {
  const cutoff = new Date();
  cutoff.setDate(cutoff.getDate() - selectedPeriod.value);
  return rawWorkouts.value.filter(w => new Date(w.date) >= cutoff);
});

const periodWorkoutsCount = computed(() => periodWorkouts.value.length);

const periodTotalVolume = computed(() => {
  let total = 0;
  periodWorkouts.value.forEach(w => {
    w.workout_items?.forEach((item: any) => {
      item.sets?.forEach((s: any) => {
        if (s.weight && s.reps) total += s.weight * s.reps;
      });
    });
  });
  return total;
});

const periodAvgVolume = computed(() => {
  return periodWorkoutsCount.value > 0 ? periodTotalVolume.value / periodWorkoutsCount.value : 0;
});

const periodMuscleDistribution = computed(() => {
  const muscleVolMap: Record<string, number> = {};
  let total = 0;
  
  periodWorkouts.value.forEach(w => {
    w.workout_items?.forEach((item: any) => {
      const muscle = item.exercise?.target_muscle || 'その他';
      if (!muscleVolMap[muscle]) muscleVolMap[muscle] = 0;
      item.sets?.forEach((s: any) => {
        if (s.weight && s.reps) {
          const vol = s.weight * s.reps;
          muscleVolMap[muscle] += vol;
          total += vol;
        }
      });
    });
  });

  const muscles = Object.keys(muscleVolMap).sort((a, b) => muscleVolMap[b] - muscleVolMap[a]);
  return muscles.map(name => ({
    name,
    slug: MUSCLE_SLUGS[name] || name, // Fallback to name if no slug
    volume: muscleVolMap[name],
    percentage: total > 0 ? Math.round((muscleVolMap[name] / total) * 100) : 0,
    color: MUSCLE_COLORS[name] || MUSCLE_COLORS['その他']
  }));
});

const volumeLabels = computed(() => {
  const labels = [];
  const today = new Date();
  
  // 1週間または1ヶ月：日単位
  if (selectedPeriod.value <= 30) {
    for (let i = selectedPeriod.value - 1; i >= 0; i--) {
      const d = new Date(today);
      d.setDate(today.getDate() - i);
      labels.push(d.toLocaleDateString("ja-JP", {
        month: "2-digit",
        day: "2-digit",
      }));
    }
  } 
  // 3ヶ月または6ヶ月：週単位（およそ）
  else {
    const weeks = Math.ceil(selectedPeriod.value / 7);
    for (let i = weeks - 1; i >= 0; i--) {
      const d = new Date(today);
      d.setDate(today.getDate() - (i * 7));
      labels.push(d.toLocaleDateString("ja-JP", {
        month: "2-digit",
        day: "2-digit",
      }) + '週');
    }
  }
  return labels;
});

const volumeDatasets = computed(() => {
  const muscleDataMap: Record<string, Record<string, number>> = {};
  const musclesFound = new Set<string>();

  periodWorkouts.value.forEach((w) => {
    const wDate = new Date(w.date);
    let dKey = '';

    if (selectedPeriod.value <= 30) {
      dKey = wDate.toLocaleDateString("ja-JP", {
        month: "2-digit",
        day: "2-digit",
      });
    } else {
      // Find the closest "week-start" label
      // 簡略化のため、このワークアウトが何週間前だったかを計算
      const today = new Date();
      const diffTime = Math.abs(today.getTime() - wDate.getTime());
      const diffWeeks = Math.floor(diffTime / (1000 * 60 * 60 * 24 * 7));
      
      const labelDate = new Date(today);
      labelDate.setDate(today.getDate() - (diffWeeks * 7));
      dKey = labelDate.toLocaleDateString("ja-JP", {
        month: "2-digit",
        day: "2-digit",
      }) + '週';
    }

    w.workout_items?.forEach((item: any) => {
      const muscle = item.exercise?.target_muscle || 'その他';
      musclesFound.add(muscle);

      if (!muscleDataMap[muscle]) muscleDataMap[muscle] = {};
      if (!muscleDataMap[muscle][dKey]) muscleDataMap[muscle][dKey] = 0;

      item.sets?.forEach((s: any) => {
        if (s.weight && s.reps) {
          muscleDataMap[muscle][dKey] += s.weight * s.reps;
        }
      });
    });
  });

  return Array.from(musclesFound).map(muscle => ({
    label: muscle,
    backgroundColor: MUSCLE_COLORS[muscle] || MUSCLE_COLORS['その他'],
    data: volumeLabels.value.map(label => muscleDataMap[muscle]?.[label] || 0)
  }));
});

const formatVolume = (val: number) => {
  return Math.round(val).toLocaleString();
};

const fetchAllData = async () => {
  if (!user.value) return;

  const { data: workouts, error } = await client
    .from("workouts")
    .select(`
      id,
      date,
      workout_items (
        exercise:exercises (
          target_muscle
        ),
        sets (
          weight,
          reps
        )
      )
    `)
    .order("date", { ascending: true });

  if (error) {
    console.error(error);
    return;
  }

  rawWorkouts.value = workouts || [];
  stats.value.totalWorkouts = rawWorkouts.value.length;
};

onMounted(() => {
  fetchAllData();
});
</script>
