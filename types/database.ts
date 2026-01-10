export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export interface Database {
  public: {
    Tables: {
      exercises: {
        Row: {
          id: string
          user_id: string
          name: string
          target_muscle: string | null
          created_at: string
        }
        Insert: {
          id?: string
          user_id: string
          name: string
          target_muscle?: string | null
          created_at?: string
        }
        Update: {
          id?: string
          user_id?: string
          name?: string
          target_muscle?: string | null
          created_at?: string
        }
      }
      workouts: {
        Row: {
          id: string
          user_id: string
          date: string
          note: string | null
          created_at: string
        }
        Insert: {
          id?: string
          user_id: string
          date?: string
          note?: string | null
          created_at?: string
        }
        Update: {
          id?: string
          user_id?: string
          date?: string
          note?: string | null
          created_at?: string
        }
      }
      workout_items: {
        Row: {
          id: string
          workout_id: string
          exercise_id: string
          note: string | null
          order_index: number
          created_at: string
        }
        Insert: {
          id?: string
          workout_id: string
          exercise_id: string
          note?: string | null
          order_index?: number
          created_at?: string
        }
        Update: {
          id?: string
          workout_id?: string
          exercise_id?: string
          note?: string | null
          order_index?: number
          created_at?: string
        }
      }
      sets: {
        Row: {
          id: string
          workout_item_id: string
          weight: number | null
          reps: number | null
          rpe: number | null
          order_index: number
          created_at: string
        }
        Insert: {
          id?: string
          workout_item_id: string
          weight?: number | null
          reps?: number | null
          rpe?: number | null
          order_index?: number
          created_at?: string
        }
        Update: {
          id?: string
          workout_item_id?: string
          weight?: number | null
          reps?: number | null
          rpe?: number | null
          order_index?: number
          created_at?: string
        }
      }
      body_metrics: {
        Row: {
          id: string
          user_id: string
          date: string
          weight: number | null
          body_fat: number | null
          created_at: string
        }
        Insert: {
          id?: string
          user_id: string
          date?: string
          weight?: number | null
          body_fat?: number | null
          created_at?: string
        }
        Update: {
          id?: string
          user_id?: string
          date?: string
          weight?: number | null
          body_fat?: number | null
          created_at?: string
        }
      }
      user_profiles: {
        Row: {
          user_id: string
          target_weight: number | null
          target_body_fat: number | null
          updated_at: string
        }
        Insert: {
          user_id: string
          target_weight?: number | null
          target_body_fat?: number | null
          updated_at?: string
        }
        Update: {
          user_id?: string
          target_weight?: number | null
          target_body_fat?: number | null
          updated_at?: string
        }
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      [_ in never]: never
    }
    Enums: {
      [_ in never]: never
    }
  }
}
