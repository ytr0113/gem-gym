<template>
  <div class="min-h-screen bg-gray-100">
    <nav v-if="user" class="bg-white shadow">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex justify-between h-16">
          <div class="flex">
            <div class="flex-shrink-0 flex items-center">
              <h1 class="text-xl font-bold text-indigo-600">Gem-Gym</h1>
            </div>
          </div>
          <div class="flex items-center">
            <span class="text-gray-700 mr-4">{{ user.email }}</span>
            <button
              @click="logout"
              class="ml-3 inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
            >
              ログアウト
            </button>
          </div>
        </div>
      </div>
    </nav>
    <div class="py-10">
      <header v-if="user">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <h1 class="text-3xl font-bold leading-tight text-gray-900">
            Dashboard
          </h1>
        </div>
      </header>
      <main>
        <div class="max-w-7xl mx-auto sm:px-6 lg:px-8">
          <NuxtPage />
        </div>
      </main>
    </div>
  </div>
</template>

<script setup lang="ts">
const user = useSupabaseUser();
const supabase = useSupabaseClient();

const logout = async () => {
  const { error } = await supabase.auth.signOut();
  if (error) {
    console.error(error);
  } else {
    navigateTo("/login");
  }
};
</script>
