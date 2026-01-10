<template>
  <div class="relative w-full h-full">
    <canvas ref="chartCanvas"></canvas>
  </div>
</template>

<script setup lang="ts">
import { onMounted, ref, watch, onUnmounted } from 'vue';
import Chart from 'chart.js/auto';

const props = defineProps<{
  labels: string[];
  weightData: number[];
  bodyFatData: (number | null)[];
  targetWeight?: number | null;
}>();

const chartCanvas = ref<HTMLCanvasElement | null>(null);
let chartInstance: Chart | null = null;

const initChart = () => {
  if (!chartCanvas.value) return;

  const ctx = chartCanvas.value.getContext('2d');
  if (!ctx) return;

  if (chartInstance) {
    chartInstance.destroy();
  }

  const datasets: any[] = [
    {
      label: '体重 (kg)',
      data: props.weightData,
      borderColor: '#4f46e5', // indigo-600
      backgroundColor: '#4f46e522',
      borderWidth: 3,
      tension: 0.4,
      pointRadius: 4,
      pointBackgroundColor: '#4f46e5',
      yAxisID: 'yWeight',
    },
    {
      label: '体脂肪率 (%)',
      data: props.bodyFatData,
      borderColor: '#ec4899', // pink-500
      backgroundColor: '#ec489922',
      borderWidth: 2,
      borderDash: [5, 5],
      tension: 0.4,
      pointRadius: 3,
      pointBackgroundColor: '#ec4899',
      yAxisID: 'yFat',
      spanGaps: true,
    }
  ];

  if (props.targetWeight) {
    datasets.push({
      label: '目標体重',
      data: props.labels.map(() => props.targetWeight),
      borderColor: '#10b981', // emerald-500
      borderWidth: 1,
      borderDash: [2, 2],
      pointRadius: 0,
      fill: false,
      yAxisID: 'yWeight',
    });
  }

  // Calculate weight axis range
  const allWeights = props.targetWeight ? [...props.weightData, props.targetWeight] : props.weightData;
  const filteredWeights = allWeights.filter(w => w > 0);
  let yWeightMin, yWeightMax;
  
  if (filteredWeights.length > 0) {
    const minW = Math.min(...filteredWeights);
    const maxW = Math.max(...filteredWeights);
    const padding = Math.max((maxW - minW) * 0.2, 5); // At least 5kg padding or 20% of range
    yWeightMin = Math.floor(minW - padding);
    yWeightMax = Math.ceil(maxW + padding);
  }

  chartInstance = new Chart(ctx, {
    type: 'line',
    data: {
      labels: props.labels,
      datasets: datasets,
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      interaction: {
        mode: 'index',
        intersect: false,
      },
      plugins: {
        legend: {
          display: true,
          position: 'top',
          labels: {
            boxWidth: 12,
            font: {
              size: 10,
              weight: 'bold',
            }
          }
        },
        tooltip: {
          backgroundColor: 'rgba(255, 255, 255, 0.9)',
          titleColor: '#1e293b',
          bodyColor: '#475569',
          borderColor: '#e2e8f0',
          borderWidth: 1,
          padding: 12,
          boxPadding: 4,
          usePointStyle: true,
          callbacks: {
            label: function(context) {
              let label = context.dataset.label || '';
              if (label) {
                label += ': ';
              }
              if (context.parsed.y !== null) {
                label += context.parsed.y + (context.datasetIndex === 0 ? ' kg' : ' %');
              }
              return label;
            }
          }
        }
      },
      scales: {
        x: {
          grid: {
            display: false,
          },
          ticks: {
            font: {
              size: 10,
            }
          }
        },
        yWeight: {
          type: 'linear',
          display: true,
          position: 'left',
          min: yWeightMin,
          max: yWeightMax,
          title: {
            display: false,
            text: '体重 (kg)'
          },
          grid: {
            color: '#f1f5f9',
          },
          ticks: {
            font: {
              size: 10,
            }
          }
        },
        yFat: {
          type: 'linear',
          display: true,
          position: 'right',
          suggestedMin: 0,
          suggestedMax: 30,
          title: {
            display: false,
            text: '体脂肪率 (%)'
          },
          grid: {
            display: false,
          },
          ticks: {
            font: {
              size: 10,
            }
          }
        }
      }
    }
  });
};

onMounted(() => {
  initChart();
});

watch(() => props.labels, () => {
  initChart();
}, { deep: true });

onUnmounted(() => {
  if (chartInstance) {
    chartInstance.destroy();
  }
});
</script>
