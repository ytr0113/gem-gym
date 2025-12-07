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
    }
  }
}
