<template>
  <div class="min-h-screen flex items-center justify-center bg-gray-50">
    <div class="max-w-md w-full space-y-8 text-center">
      <h2 class="mt-6 text-3xl font-extrabold text-gray-900">
        Authenticating...
      </h2>
      <p class="mt-2 text-sm text-gray-600">Please wait while we log you in.</p>
    </div>
  </div>
</template>

<script setup lang="ts">
const user = useSupabaseUser();

watch(
  user,
  () => {
    if (user.value) {
      return navigateTo("/");
    }
  },
  { immediate: true }
);
</script>
