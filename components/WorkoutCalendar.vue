<template>
  <div class="bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden">
    <!-- Header -->
    <div class="px-4 py-2 flex items-center justify-between border-b border-gray-50">
      <h3 class="text-xs font-black text-gray-900 uppercase tracking-widest">
        {{ currentMonthName }} {{ currentYear }}
      </h3>
      <div class="flex space-x-1">
        <button @click="prevMonth" class="p-1.5 hover:bg-gray-50 rounded-full text-gray-400 transition-colors">
          <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
          </svg>
        </button>
        <button @click="nextMonth" class="p-1.5 hover:bg-gray-50 rounded-full text-gray-400 transition-colors">
          <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
          </svg>
        </button>
      </div>
    </div>

    <!-- Calendar Grid -->
    <div class="p-2">
      <!-- Weekdays -->
      <div class="grid grid-cols-7 mb-1">
        <div v-for="day in ['日', '月', '火', '水', '木', '金', '土']" :key="day" class="text-center text-[9px] font-bold text-gray-300">
          {{ day }}
        </div>
      </div>

      <!-- Days -->
      <div class="grid grid-cols-7 gap-y-0">
        <div 
          v-for="(day, index) in calendarDays" 
          :key="index"
          class="aspect-square flex flex-col items-center justify-center relative rounded-lg transition-colors cursor-pointer hover:bg-indigo-50/50 active:scale-95"
          :class="{ 
            'opacity-50 pointer-events-none': !day 
          }"
          @click="day && onDayClick(day)"
        >
          <span 
            v-if="day"
            class="text-xs font-bold transition-all relative z-10"
            :class="[
              isToday(day) ? 'text-indigo-600 underline decoration-2 underline-offset-2' : 'text-gray-700',
            ]"
          >
            {{ day }}
          </span>
          
          <!-- Workout Indicator -->
          <div 
            v-if="day && hasWorkout(day)" 
            class="absolute inset-x-1 bottom-1 flex justify-center"
          >
            <div class="w-1 h-1 bg-indigo-500 rounded-full"></div>
          </div>
          
          <!-- Selected/Active Indicator Background (if we wanted to highlight) -->
          <div 
            v-if="day && hasWorkout(day)" 
            class="absolute inset-0.5 bg-indigo-50/30 rounded-md -z-0"
          ></div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
const props = defineProps<{
  workoutsByDate: Record<string, string>;
}>();

const emit = defineEmits(['select-day']);

const date = ref(new Date());

const currentYear = computed(() => date.value.getFullYear());
const currentMonth = computed(() => date.value.getMonth());
const currentMonthName = computed(() => {
  return new Intl.DateTimeFormat('ja-JP', { month: 'long' }).format(date.value);
});

const prevMonth = () => {
  date.value = new Date(currentYear.value, currentMonth.value - 1, 1);
};

const nextMonth = () => {
  date.value = new Date(currentYear.value, currentMonth.value + 1, 1);
};

const { getTodayJST, formatToJSTDate } = useDate();

const isToday = (day: number) => {
  return getDateStr(day) === getTodayJST();
};

const getDateStr = (day: number) => {
  const d = new Date(currentYear.value, currentMonth.value, day);
  return formatToJSTDate(d);
};

const hasWorkout = (day: number) => {
  return !!props.workoutsByDate[getDateStr(day)];
};

const onDayClick = (day: number) => {
  emit('select-day', getDateStr(day));
};

const calendarDays = computed(() => {
  const firstDay = new Date(currentYear.value, currentMonth.value, 1).getDay();
  const lastDate = new Date(currentYear.value, currentMonth.value + 1, 0).getDate();
  
  const days = [];
  for (let i = 0; i < firstDay; i++) {
    days.push(null);
  }
  for (let i = 1; i <= lastDate; i++) {
    days.push(i);
  }
  return days;
});
</script>
