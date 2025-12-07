<template>
  <div class="h-64 cursor-default">
    <Line :data="chartData" :options="chartOptions" />
  </div>
</template>

<script setup lang="ts">
import {
  Chart as ChartJS,
  Title,
  Tooltip,
  Legend,
  LineElement,
  PointElement,
  CategoryScale,
  LinearScale,
} from "chart.js";
import { Line } from "vue-chartjs";

ChartJS.register(
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  Title,
  Tooltip,
  Legend
);

const props = defineProps<{
  labels: string[];
  data: number[];
  label: string;
}>();

const chartData = computed(() => ({
  labels: props.labels,
  datasets: [
    {
      label: props.label,
      borderColor: "#4f46e5",
      backgroundColor: "rgba(79, 70, 229, 0.2)",
      data: props.data,
      tension: 0.3,
    },
  ],
}));

const chartOptions = {
  responsive: true,
  maintainAspectRatio: false,
};
</script>
