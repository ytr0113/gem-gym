<template>
  <div class="min-h-screen bg-gray-100">
    <!-- Top Navigation (Simplified for Mobile) -->
    <nav v-if="user" class="bg-white shadow sticky top-0 z-40">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex justify-between h-14 sm:h-16">
          <div class="flex">
            <div class="flex-shrink-0 flex items-center">
              <NuxtLink to="/" class="text-xl font-black tracking-tighter text-indigo-600">
                GemGym
              </NuxtLink>
            </div>
            <!-- Desktop Nav -->
            <div class="hidden sm:ml-6 sm:flex sm:space-x-8">
              <NuxtLink
                to="/"
                class="border-transparent text-gray-500 hover:border-gray-300 hover:text-gray-700 inline-flex items-center px-1 pt-1 border-b-2 text-sm font-medium"
                active-class="border-indigo-500 text-gray-900 font-bold"
              >
                ダッシュボード
              </NuxtLink>
              <NuxtLink
                to="/workouts"
                class="border-transparent text-gray-500 hover:border-gray-300 hover:text-gray-700 inline-flex items-center px-1 pt-1 border-b-2 text-sm font-medium"
                active-class="border-indigo-500 text-gray-900 font-bold"
              >
                トレーニング履歴
              </NuxtLink>
              <NuxtLink
                to="/stats"
                class="border-transparent text-gray-500 hover:border-gray-300 hover:text-gray-700 inline-flex items-center px-1 pt-1 border-b-2 text-sm font-medium"
                active-class="border-indigo-500 text-gray-900 font-bold"
              >
                分析
              </NuxtLink>
            </div>
          </div>
          <div class="flex items-center">
            <span class="hidden sm:block text-xs text-gray-500 mr-4">{{ user.email }}</span>
            <button
              @click="logout"
              class="inline-flex items-center px-3 py-1.5 border border-gray-200 text-xs font-medium rounded-full text-gray-700 bg-white hover:bg-gray-50 transition-colors"
            >
              ログアウト
            </button>
          </div>
        </div>
      </div>
    </nav>

    <!-- Main Content Area -->
    <div class="pb-20 sm:pb-10 pt-4 sm:pt-6">
      <main>
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <NuxtPage />
        </div>
      </main>
    </div>

    <!-- Mobile Bottom Navigation (Visible only on SP) -->
    <div v-if="user" class="sm:hidden fixed bottom-0 left-0 right-0 bg-white border-t border-gray-100 px-6 py-2 flex justify-around items-center z-50 pb-safe shadow-[0_-1px_10px_rgba(0,0,0,0.05)]">
      <NuxtLink to="/" class="flex flex-col items-center space-y-1 p-2 transition-all active:scale-90" active-class="text-indigo-600">
        <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" :class="$route.path === '/' ? 'fill-indigo-600' : 'fill-none'" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
          <path stroke-linecap="round" stroke-linejoin="round" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6" />
        </svg>
        <span class="text-[10px] font-bold">ホーム</span>
      </NuxtLink>
      
      <NuxtLink to="/workouts" class="flex flex-col items-center space-y-1 p-2 transition-all active:scale-90" active-class="text-indigo-600">
        <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" :class="$route.path.startsWith('/workouts') ? 'fill-indigo-600' : 'fill-none'" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
          <path stroke-linecap="round" stroke-linejoin="round" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
        </svg>
        <span class="text-[10px] font-bold">履歴</span>
      </NuxtLink>

      <NuxtLink to="/stats" class="flex flex-col items-center space-y-1 p-2 transition-all active:scale-90" active-class="text-indigo-600">
        <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" :class="$route.path === '/stats' ? 'fill-indigo-600' : 'fill-none'" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
          <path stroke-linecap="round" stroke-linejoin="round" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
        </svg>
        <span class="text-[10px] font-bold">分析</span>
      </NuxtLink>
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
