//
//  HomeView.swift
//  DF719
//
//  Created by IGOR on 14/10/2025.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var userProgress: UserProgress
    @State private var currentQuote = MotivationalQuote.random()
    @State private var animateCards = false
    @State private var animateProgress = false
    @State private var showWorkouts = false
    @State private var showMeals = false
    @State private var showStats = false
    
    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 25) {
                    // Header with greeting and quote
                    VStack(spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Good \(greetingTime())!")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.vitalTextSecondary)
                                
                                Text("Ready to Rise?")
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundColor(.vitalText)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                    currentQuote = MotivationalQuote.random()
                                }
                            }) {
                                Image(systemName: "arrow.clockwise")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.vitalAccent)
                                    .frame(width: 40, height: 40)
                                    .background(Color.vitalSecondary)
                                    .cornerRadius(20)
                            }
                        }
                        
                        // Motivational quote card
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "quote.bubble.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(.vitalAccent)
                                
                                Text("Daily Motivation")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.vitalAccent)
                                
                                Spacer()
                            }
                            
                            Text(currentQuote.text)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.vitalText)
                                .lineLimit(nil)
                                .multilineTextAlignment(.leading)
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.vitalSecondary)
                                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                        )
                        .scaleEffect(animateCards ? 1.0 : 0.9)
                        .opacity(animateCards ? 1.0 : 0.0)
                        .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.1), value: animateCards)
                    }
                    .padding(.horizontal, 20)
                    
                    // Progress cards
                    VStack(spacing: 16) {
                        // Workout progress
                        ProgressCard(
                            title: "Today's Workout",
                            value: "\(Int(userProgress.workoutProgress * 100))%",
                            subtitle: "Progress",
                            progress: userProgress.workoutProgress,
                            color: .vitalPrimary,
                            iconName: "figure.strengthtraining.traditional",
                            animateProgress: $animateProgress
                        )
                        .scaleEffect(animateCards ? 1.0 : 0.9)
                        .opacity(animateCards ? 1.0 : 0.0)
                        .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.2), value: animateCards)
                        
                        HStack(spacing: 16) {
                            // Calories card
                            StatCard(
                                title: "Calories",
                                value: "\(userProgress.totalCalories)",
                                subtitle: "of \(userProgress.dailyCalorieGoal)",
                                progress: Double(userProgress.totalCalories) / Double(userProgress.dailyCalorieGoal),
                                color: .vitalAccent,
                                iconName: "flame.fill"
                            )
                            .scaleEffect(animateCards ? 1.0 : 0.9)
                            .opacity(animateCards ? 1.0 : 0.0)
                            .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.3), value: animateCards)
                            
                            // Water intake card
                            StatCard(
                                title: "Water",
                                value: "\(userProgress.waterIntake)",
                                subtitle: "of \(userProgress.dailyWaterGoal) glasses",
                                progress: Double(userProgress.waterIntake) / Double(userProgress.dailyWaterGoal),
                                color: .blue,
                                iconName: "drop.fill"
                            )
                            .scaleEffect(animateCards ? 1.0 : 0.9)
                            .opacity(animateCards ? 1.0 : 0.0)
                            .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.4), value: animateCards)
                            .onTapGesture {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    userProgress.addWater()
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Navigation buttons
                    VStack(spacing: 16) {
                        NavigationButton(
                            title: "Workouts",
                            subtitle: "Build strength and endurance",
                            iconName: "dumbbell.fill",
                            color: .vitalPrimary,
                            action: { showWorkouts = true }
                        )
                        .scaleEffect(animateCards ? 1.0 : 0.9)
                        .opacity(animateCards ? 1.0 : 0.0)
                        .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.5), value: animateCards)
                        
                        NavigationButton(
                            title: "Meal Plans",
                            subtitle: "Fuel your fitness journey",
                            iconName: "leaf.fill",
                            color: .vitalAccent,
                            action: { showMeals = true }
                        )
                        .scaleEffect(animateCards ? 1.0 : 0.9)
                        .opacity(animateCards ? 1.0 : 0.0)
                        .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.6), value: animateCards)
                        
                        NavigationButton(
                            title: "Statistics",
                            subtitle: "Track your progress and achievements",
                            iconName: "chart.bar.fill",
                            color: .purple,
                            action: { showStats = true }
                        )
                        .scaleEffect(animateCards ? 1.0 : 0.9)
                        .opacity(animateCards ? 1.0 : 0.0)
                        .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.7), value: animateCards)
                    }
                    .padding(.horizontal, 20)
                    
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
                withAnimation(.easeInOut(duration: 1.2).delay(0.5)) {
                    animateProgress = true
                }
            }
        }
        .sheet(isPresented: $showWorkouts) {
            WorkoutView(userProgress: userProgress)
        }
        .sheet(isPresented: $showMeals) {
            MealPlanView(userProgress: userProgress)
        }
        .sheet(isPresented: $showStats) {
            StatisticsView(userProgress: userProgress)
        }
    }
    
    private func greetingTime() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Morning"
        case 12..<17: return "Afternoon"
        case 17..<22: return "Evening"
        default: return "Night"
        }
    }
}

struct ProgressCard: View {
    let title: String
    let value: String
    let subtitle: String
    let progress: Double
    let color: Color
    let iconName: String
    @Binding var animateProgress: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.vitalText)
                    
                    HStack(alignment: .bottom, spacing: 4) {
                        Text(value)
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(color)
                        
                        Text(subtitle)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.vitalTextSecondary)
                            .padding(.bottom, 4)
                    }
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .stroke(color.opacity(0.2), lineWidth: 6)
                        .frame(width: 60, height: 60)
                    
                    Circle()
                        .trim(from: 0, to: animateProgress ? progress : 0)
                        .stroke(color, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                        .frame(width: 60, height: 60)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 1.5), value: animateProgress)
                    
                    Image(systemName: iconName)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(color)
                }
            }
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color.opacity(0.2))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [color, color.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: animateProgress ? geometry.size.width * progress : 0, height: 8)
                        .animation(.easeInOut(duration: 1.2), value: animateProgress)
                }
            }
            .frame(height: 8)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.vitalSecondary)
                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
        )
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let progress: Double
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
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(color)
                
                Text(subtitle)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.vitalTextSecondary)
            }
            
            // Mini progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(color.opacity(0.2))
                        .frame(height: 4)
                    
                    RoundedRectangle(cornerRadius: 2)
                        .fill(color)
                        .frame(width: geometry.size.width * min(progress, 1.0), height: 4)
                }
            }
            .frame(height: 4)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.vitalSecondary)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
        )
    }
}

struct NavigationButton: View {
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
                    RoundedRectangle(cornerRadius: 12)
                        .fill(color)
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: iconName)
                        .font(.system(size: 22, weight: .medium))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.vitalText)
                    
                    Text(subtitle)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.vitalTextSecondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.vitalTextSecondary)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.vitalSecondary)
                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    HomeView(userProgress: UserProgress())
}
