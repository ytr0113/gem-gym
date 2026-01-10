<template>
  <div class="min-h-screen bg-gray-50 antialiased text-gray-900">
    <!-- Top Navigation -->
    <nav class="bg-white border-b border-gray-100 sticky top-0 z-40 h-16 flex items-center">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 w-full">
        <div class="flex justify-between items-center">
          <div class="flex items-center space-x-10">
            <NuxtLink to="/" class="text-xl font-black tracking-tighter text-indigo-600">
              GemGym
            </NuxtLink>
            
            <!-- Desktop Nav Items (Only if logged in) -->
            <div v-if="user" class="hidden sm:flex items-center space-x-6">
              <NuxtLink 
                v-for="item in navItems" 
                :key="item.to"
                :to="item.to"
                class="text-sm font-bold transition-colors py-5 border-b-2"
                :class="isActive(item.to) ? 'text-indigo-600 border-indigo-600' : 'text-gray-400 border-transparent hover:text-gray-600'"
              >
                {{ item.label }}
              </NuxtLink>
            </div>
          </div>

          <!-- User Menu (Only if logged in) -->
          <div v-if="user" class="flex items-center space-x-4">
            <span class="hidden md:block text-[10px] font-black text-gray-300 uppercase tracking-widest">{{ user?.email }}</span>
            <button @click="handleLogout" class="text-[10px] font-black text-gray-400 uppercase tracking-widest hover:text-red-500 transition-colors">
              ログアウト
            </button>
          </div>
          <!-- Login link (If not logged in) -->
          <div v-else-if="$route.path !== '/login'" class="flex items-center">
            <NuxtLink to="/login" class="text-xs font-black text-indigo-600 uppercase tracking-widest">ログイン</NuxtLink>
          </div>
        </div>
      </div>
    </nav>

    <!-- Main Content -->
    <main class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
      <div class="pb-24 sm:pb-8">
        <NuxtPage />
      </div>
    </main>

    <!-- Mobile Bottom Navigation (Only if logged in) -->
    <nav v-if="user" class="sm:hidden fixed bottom-5 left-4 right-4 z-50">
      <div class="bg-white shadow-xl border border-gray-100 rounded-2xl px-2 py-2 flex justify-around items-center">
        <NuxtLink 
          v-for="item in navItems" 
          :key="item.to"
          :to="item.to"
          class="flex flex-col items-center space-y-1 py-1.5 px-3 rounded-xl transition-all active:scale-90"
          :class="isActive(item.to) ? 'text-indigo-600 bg-indigo-50/50' : 'text-gray-300'"
        >
          <div class="h-6 w-6">
            <svg v-if="item.id === 'home'" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5"><path stroke-linecap="round" stroke-linejoin="round" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6"/></svg>
            <svg v-if="item.id === 'history'" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5"><path stroke-linecap="round" stroke-linejoin="round" d="M12 6v6h4.5m4.5 0a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z"/></svg>
            <svg v-if="item.id === 'stats'" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5"><path stroke-linecap="round" stroke-linejoin="round" d="M3 13.125C3 12.504 3.504 12 4.125 12h2.25c.621 0 1.125.504 1.125 1.125v6.75c0 .621-.504 1.125-1.125 1.125h-2.25a1.125 1.125 0 0 1-1.125-1.125v-6.75ZM9.75 8.625c0-.621.504-1.125 1.125-1.125h2.25c.621 0 1.125.504 1.125 1.125v11.25c0 .621-.504 1.125-1.125 1.125h-2.25a1.125 1.125 0 0 1-1.125-1.125V8.625ZM16.5 4.125c0-.621.504-1.125 1.125-1.125h2.25C20.496 3 21 3.504 21 4.125v15.75c0 .621-.504 1.125-1.125 1.125h-2.25a1.125 1.125 0 0 1-1.125-1.125V4.125Z"/></svg>
            <svg v-if="item.id === 'body'" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5"><path stroke-linecap="round" stroke-linejoin="round" d="M15.75 6a3.75 3.75 0 1 1-7.5 0 3.75 3.75 0 0 1 7.5 0ZM4.501 20.118a7.5 7.5 0 0 1 14.998 0A17.933 17.933 0 0 1 12 21.75c-2.676 0-5.216-.584-7.499-1.632Z"/></svg>
          </div>
          <span class="text-[9px] font-black uppercase tracking-widest">{{ item.shortLabel }}</span>
        </NuxtLink>
      </div>
    </nav>
  </div>
</template>

<script setup lang="ts">
const user = useSupabaseUser();
const client = useSupabaseClient();
const route = useRoute();

const navItems = [
  { id: 'home', to: '/', label: 'ダッシュボード', shortLabel: 'ホーム' },
  { id: 'history', to: '/workouts', label: 'トレーニング履歴', shortLabel: '履歴' },
  { id: 'stats', to: '/stats', label: '分析', shortLabel: '分析' },
  { id: 'body', to: '/body', label: '身体データ', shortLabel: '身体' },
];

const isActive = (path: string) => {
  if (path === '/') return route.path === '/';
  return route.path.startsWith(path);
};

const handleLogout = async () => {
  await client.auth.signOut();
  navigateTo('/login');
};
</script>

<style>
.page-enter-active,
.page-leave-active {
  transition: all 0.2s;
}
.page-enter-from,
.page-leave-to {
  opacity: 0;
  filter: blur(1rem);
}
</style>
