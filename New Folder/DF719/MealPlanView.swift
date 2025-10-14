//
//  MealPlanView.swift
//  DF719
//
//  Created by IGOR on 14/10/2025.
//

import SwiftUI

struct MealPlanView: View {
    @ObservedObject var userProgress: UserProgress
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedMealType: MealType = .breakfast
    @State private var currentMeals: [Meal] = []
    @State private var animateCards = false
    @State private var activeMealSheet: MealSheet?
    
    private let allMeals = Meal.sampleMeals
    
    enum MealSheet: Identifiable {
        case detail(Meal)
        
        var id: String {
            switch self {
            case .detail(let meal):
                return "meal-detail-\(meal.id)"
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
                                Text("Meal Plans")
                                    .font(.system(size: 32, weight: .bold, design: .rounded))
                                    .foregroundColor(.vitalText)
                                
                                Text("Fuel your fitness journey")
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
                        
                        // Daily nutrition summary
                        HStack(spacing: 16) {
                            NutritionStat(
                                title: "Calories",
                                value: "\(userProgress.totalCalories)",
                                target: "\(userProgress.dailyCalorieGoal)",
                                color: .vitalPrimary,
                                iconName: "flame.fill",
                                progress: Double(userProgress.totalCalories) / Double(userProgress.dailyCalorieGoal)
                            )
                            
                            NutritionStat(
                                title: "Protein",
                                value: "\(userProgress.totalProtein)g",
                                target: "\(userProgress.dailyProteinGoal)g",
                                color: .vitalAccent,
                                iconName: "leaf.fill",
                                progress: Double(userProgress.totalProtein) / Double(userProgress.dailyProteinGoal)
                            )
                        }
                        .opacity(animateCards ? 1.0 : 0.0)
                        .offset(y: animateCards ? 0 : 20)
                        .animation(.easeOut(duration: 0.6).delay(0.2), value: animateCards)
                    }
                    .padding(.horizontal, 20)
                    
                    // Meal type selector
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(MealType.allCases, id: \.self) { mealType in
                                MealTypeButton(
                                    mealType: mealType,
                                    isSelected: selectedMealType == mealType,
                                    onTap: {
                                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                            selectedMealType = mealType
                                            loadMealsForType(mealType)
                                        }
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .opacity(animateCards ? 1.0 : 0.0)
                    .offset(y: animateCards ? 0 : 20)
                    .animation(.easeOut(duration: 0.6).delay(0.3), value: animateCards)
                    
                    // Meal cards
                    LazyVStack(spacing: 16) {
                        ForEach(Array(currentMeals.enumerated()), id: \.element.id) { index, meal in
                            MealCard(
                                meal: meal,
                                onTap: {
                                    activeMealSheet = .detail(meal)
                                },
                                onReplace: {
                                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                        replaceMeal(at: index)
                                    }
                                }
                            )
                            .scaleEffect(animateCards ? 1.0 : 0.9)
                            .opacity(animateCards ? 1.0 : 0.0)
                            .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(Double(index) * 0.1 + 0.4), value: animateCards)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer(minLength: 30)
                }
                .padding(.top, 10)
            }
            .background(Color.vitalBackground.ignoresSafeArea())
            .navigationBarHidden(true)
            .onAppear {
                loadMealsForType(selectedMealType)
                withAnimation(.easeInOut(duration: 0.8)) {
                    animateCards = true
                }
            }
        }
        .sheet(item: $activeMealSheet) { sheet in
            switch sheet {
            case .detail(let meal):
                MealDetailView(meal: meal, userProgress: userProgress)
            }
        }
    }
    
    private func loadMealsForType(_ mealType: MealType) {
        currentMeals = allMeals.filter { $0.mealType == mealType }.shuffled().prefix(3).map { $0 }
    }
    
    private func replaceMeal(at index: Int) {
        let availableMeals = allMeals.filter { meal in
            meal.mealType == selectedMealType && !currentMeals.contains { $0.id == meal.id }
        }
        
        if let newMeal = availableMeals.randomElement() {
            currentMeals[index] = newMeal
        } else {
            // If no new meals available, shuffle all meals of this type
            let allMealsOfType = allMeals.filter { $0.mealType == selectedMealType }
            if let randomMeal = allMealsOfType.randomElement() {
                currentMeals[index] = randomMeal
            }
        }
    }
}

struct MealTypeButton: View {
    let mealType: MealType
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 8) {
                Image(systemName: mealType.iconName)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isSelected ? .white : .vitalAccent)
                
                Text(mealType.rawValue)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(isSelected ? .white : .vitalText)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? Color.vitalAccent : Color.vitalSecondary)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct MealCard: View {
    let meal: Meal
    let onTap: () -> Void
    let onReplace: () -> Void
    @State private var isPressed = false
    @State private var showReplaceAnimation = false
    
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
            VStack(alignment: .leading, spacing: 16) {
                // Header with meal type and replace button
                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: meal.mealType.iconName)
                            .font(.system(size: 14))
                            .foregroundColor(.vitalAccent)
                        
                        Text(meal.mealType.rawValue)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.vitalAccent)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            showReplaceAnimation = true
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            onReplace()
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                showReplaceAnimation = false
                            }
                        }
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(showReplaceAnimation ? .vitalAccent : .vitalTextSecondary)
                            .frame(width: 28, height: 28)
                            .background(showReplaceAnimation ? Color.vitalAccent.opacity(0.2) : Color.vitalBackground)
                            .cornerRadius(14)
                            .rotationEffect(.degrees(showReplaceAnimation ? 720 : 0))
                            .scaleEffect(showReplaceAnimation ? 1.1 : 1.0)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                // Meal info
                VStack(alignment: .leading, spacing: 12) {
                    Text(meal.name)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.vitalText)
                        .lineLimit(2)
                    
                    Text(meal.description)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.vitalTextSecondary)
                        .lineLimit(3)
                }
                
                // Nutrition info
                HStack(spacing: 20) {
                    NutritionBadge(label: "Cal", value: "\(meal.calories)", color: .vitalPrimary)
                    NutritionBadge(label: "Protein", value: "\(meal.protein)g", color: .vitalAccent)
                    NutritionBadge(label: "Carbs", value: "\(meal.carbs)g", color: .blue)
                    NutritionBadge(label: "Fat", value: "\(meal.fat)g", color: .orange)
                }
                
                // Tip section
                HStack(spacing: 8) {
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.vitalAccent)
                    
                    Text(meal.tip)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.vitalAccent)
                        .lineLimit(2)
                }
                .padding(.top, 4)
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

struct NutritionBadge: View {
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(color)
            
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.vitalTextSecondary)
        }
    }
}

struct NutritionStat: View {
    let title: String
    let value: String
    let target: String
    let color: Color
    let iconName: String
    let progress: Double
    
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
                HStack(alignment: .bottom, spacing: 4) {
                    Text(value)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(color)
                    
                    Text("/ \(target)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.vitalTextSecondary)
                        .padding(.bottom, 2)
                }
                
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
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.vitalSecondary)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
        )
    }
}

struct MealDetailView: View {
    let meal: Meal
    @ObservedObject var userProgress: UserProgress
    @Environment(\.presentationMode) var presentationMode
    @State private var animateContent = false
    @State private var showAddedAnimation = false
    
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 25) {
                // Header
                VStack(spacing: 16) {
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
                        
                        HStack(spacing: 8) {
                            Image(systemName: meal.mealType.iconName)
                                .font(.system(size: 14))
                                .foregroundColor(.vitalAccent)
                            
                            Text(meal.mealType.rawValue)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.vitalAccent)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.vitalAccent.opacity(0.2))
                        .cornerRadius(12)
                    }
                    
                    VStack(spacing: 16) {
                        Text(meal.name)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.vitalText)
                            .multilineTextAlignment(.center)
                            .opacity(animateContent ? 1.0 : 0.0)
                            .offset(y: animateContent ? 0 : 20)
                            .animation(.easeOut(duration: 0.6).delay(0.2), value: animateContent)
                        
                        Text(meal.description)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.vitalTextSecondary)
                            .multilineTextAlignment(.center)
                            .opacity(animateContent ? 1.0 : 0.0)
                            .offset(y: animateContent ? 0 : 20)
                            .animation(.easeOut(duration: 0.6).delay(0.3), value: animateContent)
                        
                    }
                }
                .padding(.horizontal, 20)
                
                // Nutrition breakdown
                VStack(alignment: .leading, spacing: 16) {
                    Text("Nutrition Facts")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.vitalText)
                        .padding(.horizontal, 20)
                        .opacity(animateContent ? 1.0 : 0.0)
                        .offset(y: animateContent ? 0 : 20)
                        .animation(.easeOut(duration: 0.6).delay(0.4), value: animateContent)
                    
                    VStack(spacing: 16) {
                        // Calories
                        NutritionRow(
                            label: "Calories",
                            value: "\(meal.calories)",
                            unit: "kcal",
                            color: .vitalPrimary,
                            iconName: "flame.fill"
                        )
                        
                        // Macros
                        NutritionRow(
                            label: "Protein",
                            value: "\(meal.protein)",
                            unit: "g",
                            color: .vitalAccent,
                            iconName: "leaf.fill"
                        )
                        
                        NutritionRow(
                            label: "Carbohydrates",
                            value: "\(meal.carbs)",
                            unit: "g",
                            color: .blue,
                            iconName: "cube.fill"
                        )
                        
                        NutritionRow(
                            label: "Fat",
                            value: "\(meal.fat)",
                            unit: "g",
                            color: .orange,
                            iconName: "drop.fill"
                        )
                    }
                    .padding(.horizontal, 20)
                    .opacity(animateContent ? 1.0 : 0.0)
                    .offset(y: animateContent ? 0 : 20)
                    .animation(.easeOut(duration: 0.6).delay(0.5), value: animateContent)
                }
                
                // Tip section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "lightbulb.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.vitalAccent)
                        
                        Text("Pro Tip")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.vitalAccent)
                        
                        Spacer()
                    }
                    
                    Text(meal.tip)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.vitalText)
                        .lineLimit(nil)
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.vitalSecondary)
                )
                .padding(.horizontal, 20)
                .opacity(animateContent ? 1.0 : 0.0)
                .offset(y: animateContent ? 0 : 20)
                .animation(.easeOut(duration: 0.6).delay(0.6), value: animateContent)
                
                Spacer(minLength: 30)
            }
            .padding(.top, 10)
        }
        .background(Color.vitalBackground.ignoresSafeArea())
        .safeAreaInset(edge: .bottom) {
            Button(action: {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    showAddedAnimation = true
                    userProgress.addCalories(meal.calories)
                    userProgress.addProtein(meal.protein)
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    presentationMode.wrappedValue.dismiss()
                }
            }) {
                HStack(spacing: 12) {
                    if showAddedAnimation {
                        Image(systemName: "checkmark")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                    } else {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    Text(showAddedAnimation ? "Added to Daily Log!" : "Add to Daily Log")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    LinearGradient(
                        colors: showAddedAnimation ? [.green, .green.opacity(0.8)] : [Color.vitalPrimary, Color.vitalPrimary.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(28)
                .shadow(color: (showAddedAnimation ? Color.green : Color.vitalPrimary).opacity(0.3), radius: 15, x: 0, y: 8)
            }
            .disabled(showAddedAnimation)
            .padding(.horizontal, 20)
            .padding(.bottom, 10)
            .scaleEffect(animateContent ? 1.0 : 0.9)
            .opacity(animateContent ? 1.0 : 0.0)
            .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.7), value: animateContent)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8)) {
                animateContent = true
            }
        }
    }
}

struct NutritionRow: View {
    let label: String
    let value: String
    let unit: String
    let color: Color
    let iconName: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: iconName)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(color)
                .frame(width: 24)
            
            Text(label)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.vitalText)
            
            Spacer()
            
            HStack(alignment: .bottom, spacing: 2) {
                Text(value)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(color)
                
                Text(unit)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.vitalTextSecondary)
                    .padding(.bottom, 1)
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    MealPlanView(userProgress: UserProgress())
}
