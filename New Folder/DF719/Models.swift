//
//  Models.swift
//  DF719
//
//  Created by IGOR on 14/10/2025.
//

import SwiftUI
import Foundation
import Combine

// MARK: - Color Theme
extension Color {
    static let vitalBackground = Color(red: 0.04, green: 0.0, blue: 0.08) // #0A0014
    static let vitalPrimary = Color(red: 0.898, green: 0.11, blue: 0.369) // #E51C5E
    static let vitalAccent = Color(red: 0.965, green: 0.722, blue: 0.0) // #F6B800
    static let vitalSecondary = Color(red: 0.2, green: 0.1, blue: 0.3) // Dark purple for cards
    static let vitalText = Color.white
    static let vitalTextSecondary = Color.white.opacity(0.7)
}

// MARK: - Workout Models
struct Workout: Identifiable, Codable {
    let id = UUID()
    let title: String
    let description: String
    let duration: Int // minutes
    let difficulty: WorkoutDifficulty
    let exercises: [Exercise]
    let iconName: String
}

struct Exercise: Identifiable, Codable {
    let id = UUID()
    let name: String
    let sets: Int
    let reps: String
    let restTime: Int // seconds
}

enum WorkoutDifficulty: String, CaseIterable, Codable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
    
    var color: Color {
        switch self {
        case .beginner: return .green
        case .intermediate: return .orange
        case .advanced: return .red
        }
    }
}

// MARK: - Meal Models
struct Meal: Identifiable, Codable {
    let id = UUID()
    let name: String
    let calories: Int
    let protein: Int
    let carbs: Int
    let fat: Int
    let description: String
    let tip: String
    let mealType: MealType
}

enum MealType: String, CaseIterable, Codable {
    case breakfast = "Breakfast"
    case lunch = "Lunch"
    case dinner = "Dinner"
    case snack = "Snack"
    
    var iconName: String {
        switch self {
        case .breakfast: return "sunrise.fill"
        case .lunch: return "sun.max.fill"
        case .dinner: return "moon.fill"
        case .snack: return "leaf.fill"
        }
    }
}

// MARK: - Badge Models
struct Badge: Identifiable, Codable {
    let id: UUID
    let name: String
    let description: String
    let iconName: String
    let isUnlocked: Bool
    let unlockedDate: Date?
    
    init(name: String, description: String, iconName: String, isUnlocked: Bool, unlockedDate: Date?) {
        self.id = UUID()
        self.name = name
        self.description = description
        self.iconName = iconName
        self.isUnlocked = isUnlocked
        self.unlockedDate = unlockedDate
    }
}

// MARK: - User Progress
class UserProgress: ObservableObject {
    @Published var completedWorkouts: Int = 0
    @Published var totalCalories: Int = 0
    @Published var waterIntake: Int = 0 // glasses
    @Published var currentStreak: Int = 0
    @Published var badges: [Badge] = []
    @Published var lastWorkoutDate: Date?
    @Published var dailyCalorieGoal: Int = 2000
    @Published var dailyWaterGoal: Int = 8
    @Published var workoutProgress: Double = 0.0
    @Published var hasCompletedOnboarding: Bool = false
    @Published var weeklyWorkouts: [Bool] = [false, false, false, false, false, false, false] // Mon-Sun
    @Published var totalProtein: Int = 0
    @Published var dailyProteinGoal: Int = 120
    
    init() {
        loadInitialBadges()
    }
    
    private func loadInitialBadges() {
        badges = [
            Badge(name: "First Step", description: "Complete your first workout", iconName: "figure.walk", isUnlocked: false, unlockedDate: nil),
            Badge(name: "Consistency", description: "Complete 7 workouts in a row", iconName: "calendar", isUnlocked: false, unlockedDate: nil),
            Badge(name: "Power Start", description: "Complete 10 workouts", iconName: "bolt.fill", isUnlocked: false, unlockedDate: nil),
            Badge(name: "Focus Mode", description: "Complete 5 advanced workouts", iconName: "target", isUnlocked: false, unlockedDate: nil),
            Badge(name: "Hydration Hero", description: "Reach water goal 10 times", iconName: "drop.fill", isUnlocked: false, unlockedDate: nil),
            Badge(name: "Nutrition Master", description: "Track meals for 30 days", iconName: "leaf.circle.fill", isUnlocked: false, unlockedDate: nil)
        ]
    }
    
    func completeWorkout() {
        completedWorkouts += 1
        workoutProgress = min(1.0, workoutProgress + 0.2)
        lastWorkoutDate = Date()
        
        // Update weekly progress (today's day of week)
        let today = Calendar.current.component(.weekday, from: Date())
        let mondayBasedIndex = (today == 1) ? 6 : today - 2 // Convert Sunday=1 to Monday=0 based
        if mondayBasedIndex >= 0 && mondayBasedIndex < 7 {
            weeklyWorkouts[mondayBasedIndex] = true
        }
        
        // Update streak
        updateStreak()
        checkBadgeUnlocks()
    }
    
    func addWater() {
        if waterIntake < dailyWaterGoal {
            waterIntake += 1
            checkBadgeUnlocks()
        }
    }
    
    func addCalories(_ calories: Int) {
        totalCalories += calories
    }
    
    func addProtein(_ protein: Int) {
        totalProtein += protein
    }
    
    func resetDailyProgress() {
        waterIntake = 0
        totalCalories = 0
        totalProtein = 0
        workoutProgress = 0.0
        // Note: Don't reset weekly workouts or streak on daily reset
    }
    
    private func updateStreak() {
        // Simple streak calculation based on recent workout completion
        if let lastDate = lastWorkoutDate {
            let daysSinceLastWorkout = Calendar.current.dateComponents([.day], from: lastDate, to: Date()).day ?? 0
            if daysSinceLastWorkout <= 1 {
                currentStreak += 1
            } else {
                currentStreak = 1 // Reset streak but count today's workout
            }
        } else {
            currentStreak = 1
        }
    }
    
    var weeklyWorkoutCount: Int {
        return weeklyWorkouts.filter { $0 }.count
    }
    
    private func checkBadgeUnlocks() {
        // First Step badge
        if completedWorkouts >= 1 && !badges[0].isUnlocked {
            unlockBadge(at: 0)
        }
        
        // Power Start badge
        if completedWorkouts >= 10 && !badges[2].isUnlocked {
            unlockBadge(at: 2)
        }
        
        // Hydration Hero badge (simplified check)
        if waterIntake >= dailyWaterGoal && !badges[4].isUnlocked {
            unlockBadge(at: 4)
        }
    }
    
    private func unlockBadge(at index: Int) {
        badges[index] = Badge(
            name: badges[index].name,
            description: badges[index].description,
            iconName: badges[index].iconName,
            isUnlocked: true,
            unlockedDate: Date()
        )
    }
}

// MARK: - Sample Data
extension Workout {
    static let sampleWorkouts: [Workout] = [
        Workout(
            title: "Morning Power",
            description: "Start your day with energy and strength",
            duration: 25,
            difficulty: .beginner,
            exercises: [
                Exercise(name: "Push-ups", sets: 3, reps: "10-15", restTime: 60),
                Exercise(name: "Squats", sets: 3, reps: "15-20", restTime: 60),
                Exercise(name: "Plank", sets: 3, reps: "30-60 sec", restTime: 45),
                Exercise(name: "Jumping Jacks", sets: 3, reps: "20", restTime: 30)
            ],
            iconName: "sunrise.fill"
        ),
        Workout(
            title: "Core Crusher",
            description: "Build a strong and stable core",
            duration: 20,
            difficulty: .intermediate,
            exercises: [
                Exercise(name: "Crunches", sets: 4, reps: "20", restTime: 45),
                Exercise(name: "Russian Twists", sets: 3, reps: "30", restTime: 45),
                Exercise(name: "Mountain Climbers", sets: 3, reps: "20", restTime: 60),
                Exercise(name: "Dead Bug", sets: 3, reps: "10 each", restTime: 45)
            ],
            iconName: "figure.core.training"
        ),
        Workout(
            title: "HIIT Blast",
            description: "High-intensity interval training for maximum burn",
            duration: 30,
            difficulty: .advanced,
            exercises: [
                Exercise(name: "Burpees", sets: 4, reps: "10", restTime: 90),
                Exercise(name: "High Knees", sets: 4, reps: "30 sec", restTime: 60),
                Exercise(name: "Jump Squats", sets: 4, reps: "15", restTime: 75),
                Exercise(name: "Push-up to T", sets: 3, reps: "8 each", restTime: 90)
            ],
            iconName: "flame.fill"
        ),
        Workout(
            title: "Strength Builder",
            description: "Build muscle and increase power",
            duration: 35,
            difficulty: .intermediate,
            exercises: [
                Exercise(name: "Pike Push-ups", sets: 4, reps: "8-12", restTime: 90),
                Exercise(name: "Single Leg Squats", sets: 3, reps: "5 each", restTime: 120),
                Exercise(name: "Diamond Push-ups", sets: 3, reps: "8-10", restTime: 90),
                Exercise(name: "Wall Sit", sets: 3, reps: "45-60 sec", restTime: 60)
            ],
            iconName: "dumbbell.fill"
        ),
        Workout(
            title: "Flexibility Flow",
            description: "Improve mobility and reduce tension",
            duration: 15,
            difficulty: .beginner,
            exercises: [
                Exercise(name: "Cat-Cow Stretch", sets: 2, reps: "10", restTime: 30),
                Exercise(name: "Hip Circles", sets: 2, reps: "10 each", restTime: 30),
                Exercise(name: "Shoulder Rolls", sets: 2, reps: "10", restTime: 30),
                Exercise(name: "Child's Pose", sets: 1, reps: "60 sec", restTime: 0)
            ],
            iconName: "figure.flexibility"
        )
    ]
}

extension Meal {
    static let sampleMeals: [Meal] = [
        // Breakfast
        Meal(
            name: "Power Protein Bowl",
            calories: 420,
            protein: 35,
            carbs: 25,
            fat: 18,
            description: "Greek yogurt with berries, nuts, and protein powder",
            tip: "Add chia seeds for extra omega-3s",
            mealType: .breakfast
        ),
        Meal(
            name: "Energizing Oatmeal",
            calories: 380,
            protein: 15,
            carbs: 55,
            fat: 12,
            description: "Steel-cut oats with banana, almond butter, and cinnamon",
            tip: "Prepare overnight for quick morning fuel",
            mealType: .breakfast
        ),
        Meal(
            name: "Green Smoothie Bowl",
            calories: 320,
            protein: 20,
            carbs: 35,
            fat: 10,
            description: "Spinach, banana, protein powder, and coconut flakes",
            tip: "Freeze fruits for thicker consistency",
            mealType: .breakfast
        ),
        
        // Lunch
        Meal(
            name: "Lean Muscle Salad",
            calories: 450,
            protein: 40,
            carbs: 20,
            fat: 22,
            description: "Grilled chicken, mixed greens, avocado, and quinoa",
            tip: "Meal prep for 3 days in advance",
            mealType: .lunch
        ),
        Meal(
            name: "Recovery Wrap",
            calories: 520,
            protein: 30,
            carbs: 45,
            fat: 20,
            description: "Turkey, hummus, vegetables in whole wheat tortilla",
            tip: "Perfect post-workout meal",
            mealType: .lunch
        ),
        Meal(
            name: "Buddha Bowl",
            calories: 480,
            protein: 25,
            carbs: 50,
            fat: 18,
            description: "Brown rice, roasted vegetables, chickpeas, tahini",
            tip: "Customize with seasonal vegetables",
            mealType: .lunch
        ),
        
        // Dinner
        Meal(
            name: "Strength Salmon",
            calories: 550,
            protein: 45,
            carbs: 30,
            fat: 25,
            description: "Baked salmon with sweet potato and asparagus",
            tip: "Rich in omega-3 for recovery",
            mealType: .dinner
        ),
        Meal(
            name: "Power Pasta",
            calories: 480,
            protein: 35,
            carbs: 55,
            fat: 12,
            description: "Whole grain pasta with lean ground turkey and vegetables",
            tip: "Great for carb loading before workouts",
            mealType: .dinner
        ),
        Meal(
            name: "Muscle Stir-fry",
            calories: 420,
            protein: 38,
            carbs: 25,
            fat: 18,
            description: "Tofu or chicken with mixed vegetables and brown rice",
            tip: "High protein, low calorie option",
            mealType: .dinner
        ),
        
        // Snacks
        Meal(
            name: "Pre-Workout Fuel",
            calories: 180,
            protein: 8,
            carbs: 25,
            fat: 6,
            description: "Apple slices with almond butter",
            tip: "Eat 30 minutes before training",
            mealType: .snack
        ),
        Meal(
            name: "Recovery Shake",
            calories: 220,
            protein: 25,
            carbs: 15,
            fat: 5,
            description: "Protein powder with banana and almond milk",
            tip: "Consume within 30 minutes post-workout",
            mealType: .snack
        ),
        Meal(
            name: "Energy Bites",
            calories: 160,
            protein: 6,
            carbs: 20,
            fat: 8,
            description: "Dates, nuts, and dark chocolate chips",
            tip: "Make a batch for the week",
            mealType: .snack
        )
    ]
}

// MARK: - Motivational Quotes
struct MotivationalQuote {
    let text: String
    let author: String
    
    static let quotes: [MotivationalQuote] = [
        MotivationalQuote(text: "The only bad workout is the one that didn't happen.", author: ""),
        MotivationalQuote(text: "Your body can do it. It's your mind you need to convince.", author: ""),
        MotivationalQuote(text: "Progress, not perfection.", author: ""),
        MotivationalQuote(text: "Every workout is a step closer to your goals.", author: ""),
        MotivationalQuote(text: "Strength doesn't come from what you can do. It comes from overcoming what you thought you couldn't.", author: ""),
        MotivationalQuote(text: "The groundwork for all happiness is good health.", author: ""),
        MotivationalQuote(text: "Take care of your body. It's the only place you have to live.", author: ""),
        MotivationalQuote(text: "Success is the sum of small efforts repeated day in and day out.", author: ""),
        MotivationalQuote(text: "Don't wish for it. Work for it.", author: ""),
        MotivationalQuote(text: "Your only limit is you.", author: "")
    ]
    
    static func random() -> MotivationalQuote {
        return quotes.randomElement() ?? quotes[0]
    }
}
