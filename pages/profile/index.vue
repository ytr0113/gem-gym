<template>
  <div v-if="user" class="max-w-2xl mx-auto space-y-6 pb-20">
    <!-- ヘッダー -->
    <div class="flex justify-between items-end">
      <div>
        <h2 class="text-2xl font-black text-indigo-900 tracking-tight">プロフィール</h2>
        <p class="text-[10px] font-black text-gray-400 uppercase tracking-widest leading-none mt-1">あなたの属性と目標設定</p>
      </div>
      <button 
        v-if="!isEditing"
        @click="isEditing = true"
        class="bg-white text-indigo-600 border-2 border-indigo-50 font-black px-4 py-2 rounded-xl text-xs hover:bg-indigo-50 active:scale-95 transition-all flex items-center space-x-2"
      >
        <svg xmlns="http://www.w3.org/2000/svg" class="h-3.5 w-3.5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
        </svg>
        <span>編集する</span>
      </button>
    </div>

    <!-- 閲覧モード -->
    <div v-if="loading" class="flex flex-col items-center justify-center py-20 space-y-4 animate-pulse">
      <div class="h-12 w-12 rounded-2xl bg-indigo-50 flex items-center justify-center text-indigo-200">
        <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 animate-spin" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
        </svg>
      </div>
      <p class="text-[10px] font-black text-gray-400 uppercase tracking-widest">読み込み中...</p>
    </div>

    <div v-else-if="!isEditing" class="space-y-6 animate-in fade-in slide-in-from-bottom-2 duration-500">
      <div class="bg-white rounded-3xl shadow-sm border border-gray-100 p-8 space-y-8">
        <!-- ニックネーム & 基本情報 -->
        <div class="flex items-center space-x-6">
          <div class="h-20 w-20 rounded-3xl bg-indigo-50 flex items-center justify-center text-indigo-600">
            <svg xmlns="http://www.w3.org/2000/svg" class="h-10 w-10" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
            </svg>
          </div>
          <div>
            <h3 class="text-2xl font-black text-indigo-900">{{ form.nickname || '未設定' }}</h3>
            <div class="flex items-center space-x-3 mt-1">
              <span v-if="calculatedAge !== null" class="bg-indigo-50 text-indigo-600 text-[10px] font-black px-2 py-0.5 rounded-full uppercase tracking-widest">{{ calculatedAge }} 歳</span>
              <span v-if="genderLabel" class="bg-pink-50 text-pink-500 text-[10px] font-black px-2 py-0.5 rounded-full uppercase tracking-widest">{{ genderLabel }}</span>
            </div>
          </div>
        </div>

        <div class="grid grid-cols-2 gap-6 pt-4 border-t border-gray-50">
          <div class="space-y-1">
            <p class="text-[9px] font-black text-gray-400 uppercase tracking-widest">目標体重</p>
            <p class="text-lg font-black text-indigo-900">
              {{ form.target_weight ? form.target_weight + ' kg' : '未設定' }}
            </p>
          </div>
          <div class="space-y-1">
            <p class="text-[9px] font-black text-gray-400 uppercase tracking-widest">生年月日</p>
            <p class="text-lg font-black text-indigo-900">
              {{ form.birthday || '未設定' }}
            </p>
          </div>
        </div>
      </div>

      <!-- アカウント情報カード -->
      <div class="bg-gray-50/50 p-6 rounded-3xl border border-gray-100">
        <h3 class="text-[10px] font-black text-gray-400 uppercase tracking-widest mb-4">アカウント情報</h3>
        <div class="space-y-3">
          <div class="flex justify-between items-center text-xs">
            <span class="text-gray-400">メールアドレス</span>
            <span class="font-bold text-gray-600">{{ user?.email }}</span>
          </div>
          <div class="flex justify-between items-center text-xs">
            <span class="text-gray-400">UUID</span>
            <span class="font-mono text-[10px] text-gray-300">{{ user?.id }}</span>
          </div>
        </div>
      </div>
    </div>

    <!-- 編集モード -->
    <div v-else-if="isEditing" class="bg-white rounded-3xl shadow-sm border border-gray-100 overflow-hidden animate-in fade-in slide-in-from-bottom-2 duration-500">
      <div class="p-6 border-b border-gray-50 flex items-center justify-between">
        <div class="flex items-center space-x-3">
          <div class="h-8 w-8 rounded-xl bg-indigo-50 flex items-center justify-center text-indigo-600">
            <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
            </svg>
          </div>
          <h3 class="text-sm font-black text-gray-700 uppercase tracking-wider">プロフィール編集</h3>
        </div>
        <button @click="isEditing = false" class="text-gray-400 hover:text-gray-600 transition-colors">
          <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
          </svg>
        </button>
      </div>

      <div class="p-6 space-y-6">
        <!-- ニックネーム -->
        <div class="space-y-1.5">
          <label class="text-[10px] font-black text-gray-400 uppercase tracking-widest px-1">ニックネーム</label>
          <input 
            v-model="form.nickname" 
            type="text" 
            placeholder="例: たろう"
            class="w-full bg-gray-50 border-none rounded-2xl px-4 py-3 text-sm font-bold text-indigo-900 focus:ring-2 focus:ring-indigo-500 transition-all" 
          />
        </div>

        <div class="grid grid-cols-2 gap-4">
          <!-- 生年月日 -->
          <div class="space-y-1.5">
            <label class="text-[10px] font-black text-gray-400 uppercase tracking-widest px-1">生年月日</label>
            <input 
              v-model="form.birthday" 
              type="date" 
              class="w-full bg-gray-50 border-none rounded-2xl px-4 py-3 text-sm font-bold text-indigo-900 focus:ring-2 focus:ring-indigo-500 transition-all" 
            />
            <p v-if="calculatedAge !== null" class="text-[9px] text-indigo-500 px-1 font-bold">{{ calculatedAge }} 歳</p>
          </div>
          <!-- 性別 -->
          <div class="space-y-1.5">
            <label class="text-[10px] font-black text-gray-400 uppercase tracking-widest px-1">性別</label>
            <select 
              v-model="form.gender" 
              class="w-full bg-gray-50 border-none rounded-2xl px-4 py-3 text-sm font-bold text-indigo-900 focus:ring-2 focus:ring-indigo-500 transition-all appearance-none"
            >
              <option value="">未設定</option>
              <option value="male">男性</option>
              <option value="female">女性</option>
              <option value="other">その他</option>
            </select>
          </div>
        </div>

        <!-- 目標体重 -->
        <div class="space-y-1.5">
          <label class="text-[10px] font-black text-gray-400 uppercase tracking-widest px-1">目標体重 (kg)</label>
          <div class="flex items-center space-x-3">
            <input 
              v-model.number="form.target_weight" 
              type="number" 
              step="0.1"
              placeholder="00.0"
              class="w-full bg-gray-50 border-none rounded-2xl px-4 py-3 text-sm font-bold text-indigo-900 focus:ring-2 focus:ring-indigo-500 transition-all" 
            />
            <span class="text-sm font-bold text-gray-400">kg</span>
          </div>
        </div>

        <div class="pt-4 flex space-x-3">
          <button 
            @click="isEditing = false"
            class="flex-1 bg-gray-100 text-gray-600 font-black px-6 py-4 rounded-2xl hover:bg-gray-200 active:scale-95 transition-all"
          >
            キャンセル
          </button>
          <button 
            @click="saveProfile"
            :disabled="saving"
            class="flex-[2] bg-indigo-600 text-white font-black px-6 py-4 rounded-2xl shadow-lg shadow-indigo-100 hover:bg-indigo-700 active:scale-95 transition-all disabled:opacity-50 flex items-center justify-center space-x-2"
          >
            <span v-if="saving">保存中...</span>
            <span v-else>変更を保存する</span>
          </button>
        </div>
      </div>
    </div>

    <!-- トースト通知 -->
    <transition name="fade">
      <div v-if="saveSuccess" class="fixed bottom-24 left-1/2 -translate-x-1/2 bg-emerald-500 text-white px-6 py-3 rounded-2xl shadow-xl font-black text-sm z-50">
        プロフィールを保存しました！
      </div>
    </transition>
  </div>
</template>

<script setup lang="ts">
import type { Database } from "~/types/database";

const client = useSupabaseClient<Database>();
const user = useSupabaseUser();

const loading = ref(true);
const saving = ref(false);
const saveSuccess = ref(false);
const isEditing = ref(false);
const nicknameState = useState<string | null>('nickname', () => null);

const form = ref({
  nickname: "",
  birthday: "" as string,
  gender: "",
  target_weight: null as number | null,
});

const genderLabel = computed(() => {
  const map: Record<string, string> = {
    male: '男性',
    female: '女性',
    other: 'その他'
  };
  return form.value.gender ? map[form.value.gender] : '';
});

// 生年月日から年齢を計算する computed プロパティ
const calculatedAge = computed(() => {
  if (!form.value.birthday) return null;
  const birthDate = new Date(form.value.birthday);
  const today = new Date();
  let age = today.getFullYear() - birthDate.getFullYear();
  const m = today.getMonth() - birthDate.getMonth();
  if (m < 0 || (m === 0 && today.getDate() < birthDate.getDate())) {
    age--;
  }
  return age;
});

const fetchProfile = async () => {
  // すでに読み込み中ならスキップ
  if (saving.value) return;
  
  try {
    const { data: { user: authUser } } = await client.auth.getUser();
    const userId = authUser?.id;
    
    if (!userId || userId === 'undefined') {
      console.warn("Fetch attempted without valid userId");
      loading.value = false;
      return;
    }
    
    loading.value = true;
    console.log("Fetching profile for:", userId);

    const { data, error } = await client
      .from("user_profiles")
      .select("*")
      .eq("user_id", userId)
      .maybeSingle();
      
    if (error && error.code !== 'PGRST116') throw error;
    
    if (data) {
      form.value.nickname = (data as any).nickname || "";
      form.value.birthday = (data as any).birthday || "";
      form.value.gender = (data as any).gender || "";
      form.value.target_weight = data.target_weight || null;
      
      // グローバル状態の同期
      nicknameState.value = form.value.nickname;
      
      console.log("Profile successfully fetched:", form.value);
    } else {
      console.log("No profile found for this user.");
    }
  } catch (err) {
    console.error("プロフィール取得エラー:", err);
  } finally {
    loading.value = false;
  }
};

const saveProfile = async () => {
  if (saving.value) return;
  
  saving.value = true;
  saveSuccess.value = false;
  
  try {
    const { data: { user: authUser } } = await client.auth.getUser();
    const userId = authUser?.id;

    if (!userId || userId === 'undefined') {
      alert("ユーザー情報の取得に失敗しました。再ログインしてください。");
      return;
    }

    const { error } = await client
      .from("user_profiles")
      .upsert({
        user_id: userId,
        nickname: form.value.nickname,
        birthday: form.value.birthday || null,
        gender: form.value.gender,
        target_weight: form.value.target_weight,
        updated_at: new Date().toISOString()
      } as any, {
        onConflict: 'user_id'
      });
      
    if (error) throw error;
    
    saveSuccess.value = true;
    isEditing.value = false;
    setTimeout(() => {
      saveSuccess.value = false;
    }, 3000);

    await fetchProfile();
  } catch (err: any) {
    alert("保存中にエラーが発生しました: " + err.message);
  } finally {
    saving.value = false;
  }
};

// 初回およびユーザー変更時にデータを取得
watch(() => user.value?.id, (newId) => {
  if (newId && newId !== 'undefined') {
    fetchProfile();
  } else {
    loading.value = false;
  }
}, { immediate: true });

onMounted(() => {
  fetchProfile();
});
</script>

<style scoped>
.fade-enter-active, .fade-leave-active {
  transition: all 0.3s ease;
}
.fade-enter-from, .fade-leave-to {
  opacity: 0;
  transform: translate(-50%, 20px);
}
</style>
