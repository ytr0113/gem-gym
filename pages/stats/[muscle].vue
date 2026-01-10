<template>
  <div class="space-y-6">
    <!-- Header -->
    <div class="flex items-center space-x-4">
      <NuxtLink to="/stats" class="p-2 hover:bg-white rounded-xl transition-colors text-gray-400 hover:text-indigo-600">
        <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
          <path fill-rule="evenodd" d="M12.707 5.293a1 1 0 010 1.414L9.414 10l3.293 3.293a1 1 0 01-1.414 1.414l-4-4a1 1 0 010-1.414l4-4a1 1 0 011.414 0z" clip-rule="evenodd" />
        </svg>
      </NuxtLink>
      <h2 class="text-2xl font-black text-indigo-900 tracking-tight">{{ muscleName }} 詳細分析</h2>
    </div>

    <!-- Overview PRs -->
    <div v-if="prs.length > 0" class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
      <div v-for="pr in prs" :key="pr.name" class="bg-white p-5 rounded-2xl shadow-sm border border-gray-100">
        <p class="text-[10px] font-black text-gray-400 uppercase tracking-widest leading-none mb-1">{{ pr.name }}</p>
        <div class="flex items-baseline space-x-2">
          <p class="text-2xl font-black text-indigo-900 leading-none">{{ pr.weight }}<span class="text-sm font-normal ml-1">kg</span></p>
          <p class="text-[10px] font-bold text-green-500 uppercase tracking-tighter">PR</p>
        </div>
        <p class="text-[9px] font-bold text-gray-300 mt-2 uppercase">{{ pr.date }}</p>
      </div>
    </div>

    <!-- Charts Section -->
    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
      <!-- Volume Trend -->
      <div class="bg-white p-6 rounded-2xl shadow-sm border border-gray-100">
        <h3 class="text-xs font-black text-gray-400 uppercase tracking-[0.2em] mb-6">ボリュームの推移（日間）</h3>
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

      <!-- Sets Trend -->
      <div class="bg-white p-6 rounded-2xl shadow-sm border border-gray-100">
        <h3 class="text-xs font-black text-gray-400 uppercase tracking-[0.2em] mb-6">セット数の推移（日間）</h3>
        <div class="h-64">
          <ClientOnly>
            <VolumeChart :labels="volumeLabels" :datasets="setsDatasets" />
            <template #fallback>
              <div class="h-full bg-gray-50 rounded-xl flex items-center justify-center text-gray-300 text-xs italic">
                読み込み中...
              </div>
            </template>
          </ClientOnly>
        </div>
      </div>
    </div>

    <!-- Exercise Records Table (Recent) -->
    <div class="bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden">
      <div class="px-6 py-4 border-b border-gray-50">
        <h3 class="text-xs font-black text-gray-400 uppercase tracking-[0.2em]">最近の記録</h3>
      </div>
      <div class="overflow-x-auto">
        <table class="w-full text-left border-collapse">
          <thead>
            <tr class="bg-gray-50/50">
              <th class="px-6 py-3 text-[10px] font-black text-gray-400 uppercase tracking-widest">日付</th>
              <th class="px-6 py-3 text-[10px] font-black text-gray-400 uppercase tracking-widest">種目</th>
              <th class="px-6 py-3 text-[10px] font-black text-gray-400 uppercase tracking-widest text-right">MAX重量</th>
              <th class="px-6 py-3 text-[10px] font-black text-gray-400 uppercase tracking-widest text-right">推定1RM</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-gray-50">
            <tr v-for="(record, idx) in recentRecords" :key="idx" class="hover:bg-gray-50/50 transition-colors">
              <td class="px-6 py-3 text-xs font-bold text-gray-500">{{ record.date }}</td>
              <td class="px-6 py-3 text-xs font-black text-gray-900">{{ record.exerciseName }}</td>
              <td class="px-6 py-3 text-xs font-black text-indigo-600 text-right">{{ record.maxWeight }} kg</td>
              <td class="px-6 py-3 text-xs font-bold text-gray-400 text-right">{{ record.oneRm }} kg</td>
            </tr>
            <tr v-if="recentRecords.length === 0">
              <td colspan="4" class="px-6 py-8 text-center text-sm italic text-gray-300">データがありません</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import type { Database } from "~/types/database";
import VolumeChart from "~/components/charts/VolumeChart.vue";

const route = useRoute();
const muscle = computed(() => route.params.muscle as string);

const client = useSupabaseClient<Database>();
const user = useSupabaseUser();

const MUSCLE_MAP: Record<string, string> = {
  'chest': '胸',
  'back': '背中',
  'shoulders': '肩',
  'arms': '腕',
  'legs': '脚',
  'other': 'その他'
};

const muscleName = computed(() => MUSCLE_MAP[route.params.muscle as string] || route.params.muscle as string);

const MUSCLE_COLORS: Record<string, string> = {
  '胸': '#ef4444',
  '背中': '#3b82f6',
  '肩': '#f59e0b',
  '腕': '#8b5cf6',
  '脚': '#10b981',
  '下半身': '#10b981',
  'その他': '#94a3b8'
};

const rawWorkouts = ref<any[]>([]);
const prs = ref<{ name: string; weight: number; date: string }[]>([]);
const recentRecords = ref<{ date: string; exerciseName: string; maxWeight: number; oneRm: number }[]>([]);

const muscleColor = computed(() => MUSCLE_COLORS[muscleName.value] || MUSCLE_COLORS['その他']);

const volumeLabels = computed(() => {
  const labels = new Set<string>();
  rawWorkouts.value.forEach(w => {
    labels.add(new Date(w.date).toLocaleDateString("ja-JP", {
      month: "2-digit",
      day: "2-digit",
    }));
  });
  return Array.from(labels).sort();
});

const volumeDatasets = computed(() => {
  const dataMap: Record<string, number> = {};
  rawWorkouts.value.forEach(w => {
    const dKey = new Date(w.date).toLocaleDateString("ja-JP", {
      month: "2-digit",
      day: "2-digit",
    });
    let vol = 0;
    w.workout_items?.forEach((item: any) => {
      if ((item.exercise?.target_muscle || 'その他') === muscleName.value) {
        item.sets?.forEach((s: any) => {
          if (s.weight && s.reps) vol += s.weight * s.reps;
        });
      }
    });
    dataMap[dKey] = (dataMap[dKey] || 0) + vol;
  });

  return [{
    label: 'ボリューム (kg)',
    backgroundColor: muscleColor.value,
    data: volumeLabels.value.map(l => dataMap[l] || 0)
  }];
});

const setsDatasets = computed(() => {
  const dataMap: Record<string, number> = {};
  rawWorkouts.value.forEach(w => {
    const dKey = new Date(w.date).toLocaleDateString("ja-JP", {
      month: "2-digit",
      day: "2-digit",
    });
    let sets = 0;
    w.workout_items?.forEach((item: any) => {
      if ((item.exercise?.target_muscle || 'その他') === muscleName.value) {
        sets += item.sets?.length || 0;
      }
    });
    dataMap[dKey] = (dataMap[dKey] || 0) + sets;
  });

  return [{
    label: 'セット数',
    backgroundColor: muscleColor.value + '80', // semi-transparent
    data: volumeLabels.value.map(l => dataMap[l] || 0)
  }];
});

const fetchMuscleStats = async () => {
  if (!user.value) return;

  const { data: workouts, error } = await client
    .from("workouts")
    .select(`
      id,
      date,
      workout_items (
        exercise:exercises (
          name,
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

  // Filter only workouts that contain this muscle
  const filteredWorkouts = workouts?.filter(w => 
    w.workout_items?.some((item: any) => (item.exercise?.target_muscle || 'その他') === muscleName.value)
  ) || [];

  rawWorkouts.value = filteredWorkouts;

  // Calculate PRs and Records
  const prMap: Record<string, { weight: number; date: string }> = {};
  const records: any[] = [];

  filteredWorkouts.forEach(w => {
    const dateStr = new Date(w.date).toLocaleDateString("ja-JP", {
      month: "2-digit",
      day: "2-digit",
    });

    w.workout_items?.forEach((item: any) => {
      if ((item.exercise?.target_muscle || 'その他') === muscleName.value) {
        let maxW = 0;
        let bestOneRm = 0;

        item.sets?.forEach((s: any) => {
          if (s.weight > maxW) maxW = s.weight;
          
          if (s.weight && s.reps) {
            // Epley Formula: 1RM = weight * (1 + reps/30)
            const oneRm = Math.round(s.weight * (1 + s.reps / 30));
            if (oneRm > bestOneRm) bestOneRm = oneRm;
          }
        });

        if (maxW > 0) {
          const exName = item.exercise?.name;
          if (!prMap[exName] || maxW > prMap[exName].weight) {
            prMap[exName] = { weight: maxW, date: w.date };
          }

          records.push({
            date: dateStr,
            exerciseName: exName,
            maxWeight: maxW,
            oneRm: bestOneRm
          });
        }
      }
    });
  });

  prs.value = Object.keys(prMap).map(name => ({
    name,
    weight: prMap[name].weight,
    date: prMap[name].date
  })).sort((a, b) => b.weight - a.weight);

  recentRecords.value = records.reverse().slice(0, 10);
};

onMounted(() => {
  fetchMuscleStats();
});
</script>
