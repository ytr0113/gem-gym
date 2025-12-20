<template>
  <div
    class="min-h-screen flex items-center justify-center bg-gray-50 py-12 px-4 sm:px-6 lg:px-8"
  >
    <div class="max-w-md w-full space-y-8">
      <div>
        <h2 class="mt-6 text-center text-3xl font-extrabold text-gray-900">
          {{ isSignUp ? "アカウント作成" : "ログイン" }}
        </h2>
      </div>
      <form class="mt-8 space-y-6" @submit.prevent="handleAuth">
        <input type="hidden" name="remember" value="true" />
        <div class="rounded-md shadow-sm -space-y-px">
          <div>
            <label for="gym-id" class="sr-only">ジムID</label>
            <input
              id="gym-id"
              name="gym-id"
              type="text"
              required
              class="appearance-none rounded-none relative block w-full px-3 py-2 border border-gray-300 placeholder-gray-500 text-gray-900 rounded-t-md focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 focus:z-10 sm:text-sm"
              placeholder="ジムID"
              v-model="gymId"
            />
          </div>
          <div>
            <label for="password" class="sr-only">パスワード</label>
            <input
              id="password"
              name="password"
              type="password"
              autocomplete="current-password"
              required
              class="appearance-none rounded-none relative block w-full px-3 py-2 border border-gray-300 placeholder-gray-500 text-gray-900 rounded-b-md focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 focus:z-10 sm:text-sm"
              placeholder="パスワード"
              v-model="password"
            />
          </div>
        </div>

        <div>
          <button
            type="submit"
            class="group relative w-full flex justify-center py-2 px-4 border border-transparent text-sm font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
            :disabled="loading"
          >
            <span class="absolute left-0 inset-y-0 flex items-center pl-3">
              <!-- Heroicon name: solid/lock-closed -->
              <svg
                class="h-5 w-5 text-indigo-500 group-hover:text-indigo-400"
                xmlns="http://www.w3.org/2000/svg"
                viewBox="0 0 20 20"
                fill="currentColor"
                aria-hidden="true"
              >
                <path
                  fill-rule="evenodd"
                  d="M5 9V7a5 5 0 0110 0v2a2 2 0 012 2v5a2 2 0 01-2 2H5a2 2 0 01-2-2v-5a2 2 0 012-2zm8-2v2H7V7a3 3 0 016 0z"
                  clip-rule="evenodd"
                />
              </svg>
            </span>
            {{ loading ? "処理中..." : isSignUp ? "登録" : "ログイン" }}
          </button>
        </div>
      </form>
      <div class="text-center">
        <button
          @click="isSignUp = !isSignUp"
          class="font-medium text-indigo-600 hover:text-indigo-500"
        >
          {{
            isSignUp
              ? "すでにアカウントをお持ちですか？ログイン"
              : "アカウントをお持ちでないですか？登録"
          }}
        </button>
      </div>
      <div v-if="errorMsg" class="text-red-500 text-center text-sm">
        {{ errorMsg }}
      </div>
      <div v-if="successMsg" class="text-green-500 text-center text-sm">
        {{ successMsg }}
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
const supabase = useSupabaseClient();
const user = useSupabaseUser();

const gymId = ref("");
const password = ref("");
const isSignUp = ref(false);
const loading = ref(false);
const errorMsg = ref<string | null>(null);
const successMsg = ref<string | null>(null);

const handleAuth = async () => {
  loading.value = true;
  errorMsg.value = null;
  successMsg.value = null;

  // Convert ID to Email format for Supabase
  const fakeEmail = `${gymId.value}@gem-gym.internal`;

  try {
    if (isSignUp.value) {
      const { error } = await supabase.auth.signUp({
        email: fakeEmail,
        password: password.value,
      });
      if (error) throw error;
      
      // Since confirmation is disabled, we might be logged in already or need to sign in
      // Let's try to sign in immediately to ensure session is created if signUp didn't do it
      const { error: signInError } = await supabase.auth.signInWithPassword({
        email: fakeEmail,
        password: password.value,
      });
      if (signInError) throw signInError;
      
      navigateTo("/");
    } else {
      const { error } = await supabase.auth.signInWithPassword({
        email: fakeEmail,
        password: password.value,
      });
      if (error) throw error;
      navigateTo("/");
    }
  } catch (error: any) {
    errorMsg.value = error.message;
  } finally {
    loading.value = false;
  }
};

watch(user, () => {
  if (user.value) {
    navigateTo("/");
  }
});
</script>
