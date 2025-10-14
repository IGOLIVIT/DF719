//
//  StatisticsView.swift
//  DF719
//
//  Created by IGOR on 14/10/2025.
//

import SwiftUI

struct StatisticsView: View {
    @ObservedObject var userProgress: UserProgress
    @Environment(\.presentationMode) var presentationMode
    @State private var animateCards = false
    @State private var showResetAlert = false
    @State private var selectedUnit: WeightUnit = .kg
    @State private var showBadgeDetail = false
    @State private var selectedBadge: Badge?
    @State private var showCalorieGoalAlert = false
    @State private var showWaterGoalAlert = false
    @State private var showProteinGoalAlert = false
    @State private var tempCalorieGoal = ""
    @State private var tempWaterGoal = ""
    @State private var tempProteinGoal = ""
    
    enum WeightUnit: String, CaseIterable {
        case kg = "kg"
        case lb = "lb"
        
        var displayName: String {
            switch self {
            case .kg: return "Kilograms"
            case .lb: return "Pounds"
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Statistics")
                                    .font(.system(size: 32, weight: .bold, design: .rounded))
                                    .foregroundColor(.vitalText)
                                
                                Text("Track your progress and achievements")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.vitalTextSecondary)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.vitalTextSecondary)
                                    .frame(width: 32, height: 32)
                                    .background(Color.vitalSecondary)
                                    .cornerRadius(16)
                            }
                        }
                        
                        // Overview stats
                        HStack(spacing: 16) {
                            OverviewStat(
                                title: "Workouts",
                                value: "\(userProgress.completedWorkouts)",
                                subtitle: "Completed",
                                color: .vitalPrimary,
                                iconName: "dumbbell.fill"
                            )
                            
                            OverviewStat(
                                title: "Streak",
                                value: "\(userProgress.currentStreak)",
                                subtitle: "Days",
                                color: .vitalAccent,
                                iconName: "flame.fill"
                            )
                        }
                        .opacity(animateCards ? 1.0 : 0.0)
                        .offset(y: animateCards ? 0 : 20)
                        .animation(.easeOut(duration: 0.6).delay(0.2), value: animateCards)
                    }
                    .padding(.horizontal, 20)
                    
                    // Weekly progress chart
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Weekly Progress")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.vitalText)
                            .padding(.horizontal, 20)
                            .opacity(animateCards ? 1.0 : 0.0)
                            .offset(y: animateCards ? 0 : 20)
                            .animation(.easeOut(duration: 0.6).delay(0.3), value: animateCards)
                        
                        WeeklyProgressChart(userProgress: userProgress)
                            .padding(.horizontal, 20)
                            .opacity(animateCards ? 1.0 : 0.0)
                            .offset(y: animateCards ? 0 : 20)
                            .animation(.easeOut(duration: 0.6).delay(0.4), value: animateCards)
                    }
                    
                    // Achievement badges
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Achievement Badges")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.vitalText)
                            .padding(.horizontal, 20)
                            .opacity(animateCards ? 1.0 : 0.0)
                            .offset(y: animateCards ? 0 : 20)
                            .animation(.easeOut(duration: 0.6).delay(0.5), value: animateCards)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                            ForEach(Array(userProgress.badges.enumerated()), id: \.element.id) { index, badge in
                                BadgeCard(
                                    badge: badge,
                                    onTap: {
                                        selectedBadge = badge
                                        showBadgeDetail = true
                                    }
                                )
                                .scaleEffect(animateCards ? 1.0 : 0.9)
                                .opacity(animateCards ? 1.0 : 0.0)
                                .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(Double(index) * 0.1 + 0.6), value: animateCards)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Settings section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Settings")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.vitalText)
                            .padding(.horizontal, 20)
                            .opacity(animateCards ? 1.0 : 0.0)
                            .offset(y: animateCards ? 0 : 20)
                            .animation(.easeOut(duration: 0.6).delay(0.8), value: animateCards)
                        
                        VStack(spacing: 12) {
                            // Unit preference
                            SettingRow(
                                title: "Weight Unit",
                                subtitle: selectedUnit.displayName,
                                iconName: "scalemass.fill",
                                color: .blue,
                                action: {
                                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                        selectedUnit = selectedUnit == .kg ? .lb : .kg
                                    }
                                }
                            )
                            
                            // Calorie display
                            SettingRow(
                                title: "Daily Calorie Goal",
                                subtitle: "\(userProgress.dailyCalorieGoal) kcal",
                                iconName: "flame.fill",
                                color: .orange,
                                action: {
                                    tempCalorieGoal = "\(userProgress.dailyCalorieGoal)"
                                    showCalorieGoalAlert = true
                                }
                            )
                            
                            // Water goal
                            SettingRow(
                                title: "Daily Water Goal",
                                subtitle: "\(userProgress.dailyWaterGoal) glasses",
                                iconName: "drop.fill",
                                color: .cyan,
                                action: {
                                    tempWaterGoal = "\(userProgress.dailyWaterGoal)"
                                    showWaterGoalAlert = true
                                }
                            )
                            
                            // Protein goal
                            SettingRow(
                                title: "Daily Protein Goal",
                                subtitle: "\(userProgress.dailyProteinGoal)g",
                                iconName: "leaf.fill",
                                color: .green,
                                action: {
                                    tempProteinGoal = "\(userProgress.dailyProteinGoal)"
                                    showProteinGoalAlert = true
                                }
                            )
                            
                            // Reset progress
                            SettingRow(
                                title: "Reset Progress",
                                subtitle: "Clear all data and start fresh",
                                iconName: "arrow.clockwise",
                                color: .red,
                                action: {
                                    showResetAlert = true
                                }
                            )
                        }
                        .padding(.horizontal, 20)
                        .opacity(animateCards ? 1.0 : 0.0)
                        .offset(y: animateCards ? 0 : 20)
                        .animation(.easeOut(duration: 0.6).delay(0.9), value: animateCards)
                    }
                    
                    Spacer(minLength: 30)
                }
                .padding(.top, 10)
            }
            .background(Color.vitalBackground.ignoresSafeArea())
            .navigationBarHidden(true)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.8)) {
                    animateCards = true
                }
            }
        }
        .alert("Reset Progress", isPresented: $showResetAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    resetProgress()
                }
            }
        } message: {
            Text("Are you sure you want to reset all your progress? This action cannot be undone.")
        }
        .alert("Daily Calorie Goal", isPresented: $showCalorieGoalAlert) {
            TextField("Calories", text: $tempCalorieGoal)
                .keyboardType(.numberPad)
            Button("Cancel", role: .cancel) {}
            Button("Save") {
                if let newGoal = Int(tempCalorieGoal), newGoal > 0 {
                    userProgress.dailyCalorieGoal = newGoal
                }
            }
        } message: {
            Text("Enter your daily calorie goal (recommended: 1800-2500 kcal)")
        }
        .alert("Daily Water Goal", isPresented: $showWaterGoalAlert) {
            TextField("Glasses", text: $tempWaterGoal)
                .keyboardType(.numberPad)
            Button("Cancel", role: .cancel) {}
            Button("Save") {
                if let newGoal = Int(tempWaterGoal), newGoal > 0 {
                    userProgress.dailyWaterGoal = newGoal
                }
            }
        } message: {
            Text("Enter your daily water goal (recommended: 6-10 glasses)")
        }
        .alert("Daily Protein Goal", isPresented: $showProteinGoalAlert) {
            TextField("Grams", text: $tempProteinGoal)
                .keyboardType(.numberPad)
            Button("Cancel", role: .cancel) {}
            Button("Save") {
                if let newGoal = Int(tempProteinGoal), newGoal > 0 {
                    userProgress.dailyProteinGoal = newGoal
                }
            }
        } message: {
            Text("Enter your daily protein goal (recommended: 80-150g)")
        }
        .sheet(isPresented: $showBadgeDetail) {
            if let badge = selectedBadge {
                BadgeDetailView(badge: badge)
            }
        }
    }
    
    private func resetProgress() {
        userProgress.completedWorkouts = 0
        userProgress.totalCalories = 0
        userProgress.totalProtein = 0
        userProgress.waterIntake = 0
        userProgress.currentStreak = 0
        userProgress.workoutProgress = 0.0
        userProgress.lastWorkoutDate = nil
        userProgress.weeklyWorkouts = [false, false, false, false, false, false, false]
        
        // Reset badges
        for i in 0..<userProgress.badges.count {
            userProgress.badges[i] = Badge(
                name: userProgress.badges[i].name,
                description: userProgress.badges[i].description,
                iconName: userProgress.badges[i].iconName,
                isUnlocked: false,
                unlockedDate: nil
            )
        }
    }
}

struct OverviewStat: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    let iconName: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: iconName)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.vitalText)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(color)
                
                Text(subtitle)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.vitalTextSecondary)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.vitalSecondary)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
        )
    }
}

struct WeeklyProgressChart: View {
    @ObservedObject var userProgress: UserProgress
    private let weekDays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("This Week")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.vitalText)
                
                Spacer()
                
                Text("\(userProgress.weeklyWorkoutCount)/7 days")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.vitalAccent)
            }
            
            HStack(spacing: 8) {
                ForEach(Array(weekDays.enumerated()), id: \.offset) { index, day in
                    VStack(spacing: 8) {
                        Text(day)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.vitalTextSecondary)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(userProgress.weeklyWorkouts[index] ? Color.vitalPrimary : Color.vitalSecondary)
                            .frame(height: 40)
                            .overlay(
                                Image(systemName: userProgress.weeklyWorkouts[index] ? "checkmark" : "")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                            )
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.vitalSecondary)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
        )
    }
}

struct BadgeCard: View {
    let badge: Badge
    let onTap: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isPressed = false
                }
                onTap()
            }
        }) {
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: badge.isUnlocked ? [Color.vitalAccent, Color.vitalAccent.opacity(0.7)] : [Color.vitalSecondary, Color.vitalSecondary.opacity(0.5)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: badge.iconName)
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(badge.isUnlocked ? .white : .vitalTextSecondary)
                    
                    if !badge.isUnlocked {
                        Circle()
                            .fill(Color.black.opacity(0.6))
                            .frame(width: 60, height: 60)
                        
                        Image(systemName: "lock.fill")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.vitalTextSecondary)
                    }
                }
                
                VStack(spacing: 4) {
                    Text(badge.name)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(badge.isUnlocked ? .vitalText : .vitalTextSecondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                    
                    Text(badge.description)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.vitalTextSecondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.vitalSecondary)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SettingRow: View {
    let title: String
    let subtitle: String
    let iconName: String
    let color: Color
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isPressed = false
                }
                action()
            }
        }) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(color)
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: iconName)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.vitalText)
                    
                    Text(subtitle)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.vitalTextSecondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.vitalTextSecondary)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.vitalSecondary)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct BadgeDetailView: View {
    let badge: Badge
    @Environment(\.presentationMode) var presentationMode
    @State private var animateContent = false
    
    var body: some View {
        VStack(spacing: 30) {
            // Header
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.vitalTextSecondary)
                        .frame(width: 32, height: 32)
                        .background(Color.vitalSecondary)
                        .cornerRadius(16)
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            
            Spacer()
            
            // Badge display
            VStack(spacing: 30) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: badge.isUnlocked ? [Color.vitalAccent, Color.vitalAccent.opacity(0.7)] : [Color.vitalSecondary, Color.vitalSecondary.opacity(0.5)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                        .scaleEffect(animateContent ? 1.0 : 0.8)
                        .animation(.spring(response: 0.8, dampingFraction: 0.6), value: animateContent)
                    
                    Image(systemName: badge.iconName)
                        .font(.system(size: 50, weight: .medium))
                        .foregroundColor(badge.isUnlocked ? .white : .vitalTextSecondary)
                    
                    if !badge.isUnlocked {
                        Circle()
                            .fill(Color.black.opacity(0.6))
                            .frame(width: 120, height: 120)
                        
                        Image(systemName: "lock.fill")
                            .font(.system(size: 30, weight: .medium))
                            .foregroundColor(.vitalTextSecondary)
                    }
                }
                .shadow(color: (badge.isUnlocked ? Color.vitalAccent : Color.vitalSecondary).opacity(0.3), radius: 20, x: 0, y: 10)
                
                VStack(spacing: 16) {
                    Text(badge.name)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.vitalText)
                        .opacity(animateContent ? 1.0 : 0.0)
                        .offset(y: animateContent ? 0 : 20)
                        .animation(.easeOut(duration: 0.6).delay(0.2), value: animateContent)
                    
                    Text(badge.description)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.vitalTextSecondary)
                        .multilineTextAlignment(.center)
                        .opacity(animateContent ? 1.0 : 0.0)
                        .offset(y: animateContent ? 0 : 20)
                        .animation(.easeOut(duration: 0.6).delay(0.3), value: animateContent)
                    
                    if badge.isUnlocked, let unlockedDate = badge.unlockedDate {
                        Text("Unlocked on \(DateFormatter.shortDate.string(from: unlockedDate))")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.vitalAccent)
                            .opacity(animateContent ? 1.0 : 0.0)
                            .offset(y: animateContent ? 0 : 20)
                            .animation(.easeOut(duration: 0.6).delay(0.4), value: animateContent)
                    } else {
                        Text("Keep working to unlock this badge!")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.vitalTextSecondary)
                            .opacity(animateContent ? 1.0 : 0.0)
                            .offset(y: animateContent ? 0 : 20)
                            .animation(.easeOut(duration: 0.6).delay(0.4), value: animateContent)
                    }
                }
                .padding(.horizontal, 30)
            }
            
            Spacer()
        }
        .background(Color.vitalBackground.ignoresSafeArea())
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8)) {
                animateContent = true
            }
        }
    }
}

extension DateFormatter {
    static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
}

#Preview {
    StatisticsView(userProgress: UserProgress())
}
