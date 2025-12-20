export default defineNuxtPlugin(async (nuxtApp) => {
  // Only run in development mode
  if (!import.meta.dev) return

  const user = useSupabaseUser()
  const client = useSupabaseClient()
  const config = useRuntimeConfig()

  const devEmail = config.public.devEmail as string
  const devPassword = config.public.devPassword as string

  // If credentials are setup and user is not logged in
  if (!user.value && devEmail && devPassword) {
    console.log('[Dev Auth] Attempting auto-login...')
    
    // Support either full email or Gym ID
    const emailToUse = devEmail.includes('@') ? devEmail : `${devEmail}@gem-gym.internal`

    const { data, error } = await client.auth.signInWithPassword({
      email: emailToUse,
      password: devPassword
    })

    if (error) {
      console.error('[Dev Auth] Auto-login failed:', error.message)
    } else {
      console.log('[Dev Auth] Successfully logged in as:', data.user.email)
    }
  }
})
