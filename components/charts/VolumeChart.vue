<template>
  <div class="cursor-default h-full w-full min-h-[200px]">
    <Bar :data="chartData" :options="chartOptions" />
  </div>
</template>

<script setup lang="ts">
import {
  Chart as ChartJS,
  Title,
  Tooltip,
  Legend,
  BarElement,
  CategoryScale,
  LinearScale,
} from "chart.js";
import { Bar } from "vue-chartjs";

ChartJS.register(
  CategoryScale,
  LinearScale,
  BarElement,
  Title,
  Tooltip,
  Legend
);

const props = defineProps<{
  labels: string[];
  data: number[];
}>();

const chartData = computed(() => ({
  labels: props.labels,
  datasets: [
    {
      label: "ボリューム (kg)",
      backgroundColor: "#4f46e5",
      data: props.data,
    },
  ],
}));

const chartOptions = {
  responsive: true,
  maintainAspectRatio: false,
  plugins: {
    legend: {
      display: false,
    },
  },
};
</script>
