//
//  WorkoutView.swift
//  DF719
//
//  Created by IGOR on 14/10/2025.
//

import SwiftUI

struct WorkoutView: View {
    @ObservedObject var userProgress: UserProgress
    @Environment(\.presentationMode) var presentationMode
    @State private var activeWorkoutSheet: WorkoutSheet?
    @State private var animateCards = false
    
    private let workouts = Workout.sampleWorkouts
    
    enum WorkoutSheet: Identifiable {
        case detail(Workout)
        
        var id: String {
            switch self {
            case .detail(let workout):
                return "workout-detail-\(workout.id)"
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
                                Text("Workouts")
                                    .font(.system(size: 32, weight: .bold, design: .rounded))
                                    .foregroundColor(.vitalText)
                                
                                Text("Choose your training for today")
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
                        
                        // Stats summary
                        HStack(spacing: 16) {
                            StatBadge(
                                title: "Completed",
                                value: "\(userProgress.completedWorkouts)",
                                color: .vitalPrimary
                            )
                            
                            StatBadge(
                                title: "This Week",
                                value: "\(userProgress.weeklyWorkoutCount)",
                                color: .vitalAccent
                            )
                            
                            StatBadge(
                                title: "Streak",
                                value: "\(userProgress.currentStreak)",
                                color: .purple
                            )
                        }
                        .opacity(animateCards ? 1.0 : 0.0)
                        .offset(y: animateCards ? 0 : 20)
                        .animation(.easeOut(duration: 0.6).delay(0.2), value: animateCards)
                    }
                    .padding(.horizontal, 20)
                    
                    // Workout cards
                    LazyVStack(spacing: 16) {
                        ForEach(Array(workouts.enumerated()), id: \.element.id) { index, workout in
                            WorkoutCard(
                                workout: workout,
                                onTap: {
                                    activeWorkoutSheet = .detail(workout)
                                }
                            )
                            .scaleEffect(animateCards ? 1.0 : 0.9)
                            .opacity(animateCards ? 1.0 : 0.0)
                            .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(Double(index) * 0.1 + 0.3), value: animateCards)
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
                withAnimation(.easeInOut(duration: 0.8)) {
                    animateCards = true
                }
            }
        }
        .sheet(item: $activeWorkoutSheet) { sheet in
            switch sheet {
            case .detail(let workout):
                WorkoutDetailView(workout: workout, userProgress: userProgress)
            }
        }
    }
}

struct WorkoutCard: View {
    let workout: Workout
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
            VStack(alignment: .leading, spacing: 16) {
                // Header with icon and difficulty
                HStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                LinearGradient(
                                    colors: [Color.vitalPrimary, Color.vitalPrimary.opacity(0.7)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: workout.iconName)
                            .font(.system(size: 22, weight: .medium))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(workout.difficulty.rawValue)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(workout.difficulty.color)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(workout.difficulty.color.opacity(0.2))
                            .cornerRadius(8)
                        
                        Text("\(workout.duration) min")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.vitalTextSecondary)
                    }
                }
                
                // Workout info
                VStack(alignment: .leading, spacing: 8) {
                    Text(workout.title)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.vitalText)
                    
                    Text(workout.description)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.vitalTextSecondary)
                        .lineLimit(2)
                }
                
                // Exercise count and start button
                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: "list.bullet")
                            .font(.system(size: 14))
                            .foregroundColor(.vitalAccent)
                        
                        Text("\(workout.exercises.count) exercises")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.vitalAccent)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 6) {
                        Text("Start")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Image(systemName: "play.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.vitalPrimary)
                    .cornerRadius(20)
                }
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

struct WorkoutDetailView: View {
    let workout: Workout
    @ObservedObject var userProgress: UserProgress
    @Environment(\.presentationMode) var presentationMode
    @State private var currentExercise = 0
    @State private var isWorkoutActive = false
    @State private var countdown = 3
    @State private var showCountdown = false
    @State private var showCompletion = false
    @State private var animateContent = false
    
    
    var body: some View {
        ZStack {
            Color.vitalBackground.ignoresSafeArea()
            
            if showCountdown {
                CountdownView(countdown: $countdown, onComplete: {
                    showCountdown = false
                    isWorkoutActive = true
                })
            } else if showCompletion {
                CompletionView(workout: workout, onDismiss: {
                    userProgress.completeWorkout()
                    presentationMode.wrappedValue.dismiss()
                })
            } else if isWorkoutActive {
                ActiveWorkoutView(
                    workout: workout,
                    currentExercise: $currentExercise,
                    onComplete: {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            showCompletion = true
                        }
                    },
                    onExit: {
                        presentationMode.wrappedValue.dismiss()
                    }
                )
            } else {
                WorkoutPreviewView(
                    workout: workout,
                    onStart: {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            showCountdown = true
                        }
                    },
                    onDismiss: {
                        presentationMode.wrappedValue.dismiss()
                    },
                    animateContent: $animateContent
                )
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8)) {
                animateContent = true
            }
        }
    }
}

struct WorkoutPreviewView: View {
    let workout: Workout
    let onStart: () -> Void
    let onDismiss: () -> Void
    @Binding var animateContent: Bool
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 25) {
                // Header
                VStack(spacing: 16) {
                    HStack {
                        Button(action: onDismiss) {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.vitalTextSecondary)
                                .frame(width: 32, height: 32)
                                .background(Color.vitalSecondary)
                                .cornerRadius(16)
                        }
                        
                        Spacer()
                        
                        Text(workout.difficulty.rawValue)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(workout.difficulty.color)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(workout.difficulty.color.opacity(0.2))
                            .cornerRadius(12)
                    }
                    
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.vitalPrimary, Color.vitalPrimary.opacity(0.7)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 80, height: 80)
                                .scaleEffect(animateContent ? 1.0 : 0.8)
                                .animation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.2), value: animateContent)
                            
                            Image(systemName: workout.iconName)
                                .font(.system(size: 35, weight: .medium))
                                .foregroundColor(.white)
                        }
                        
                        VStack(spacing: 8) {
                            Text(workout.title)
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(.vitalText)
                                .multilineTextAlignment(.center)
                                .opacity(animateContent ? 1.0 : 0.0)
                                .offset(y: animateContent ? 0 : 20)
                                .animation(.easeOut(duration: 0.6).delay(0.3), value: animateContent)
                            
                            Text(workout.description)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.vitalTextSecondary)
                                .multilineTextAlignment(.center)
                                .opacity(animateContent ? 1.0 : 0.0)
                                .offset(y: animateContent ? 0 : 20)
                                .animation(.easeOut(duration: 0.6).delay(0.4), value: animateContent)
                            
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                // Workout stats
                HStack(spacing: 20) {
                    WorkoutStat(title: "Duration", value: "\(workout.duration) min", iconName: "clock.fill")
                    WorkoutStat(title: "Exercises", value: "\(workout.exercises.count)", iconName: "list.bullet")
                    WorkoutStat(title: "Difficulty", value: workout.difficulty.rawValue, iconName: "target")
                }
                .opacity(animateContent ? 1.0 : 0.0)
                .offset(y: animateContent ? 0 : 20)
                .animation(.easeOut(duration: 0.6).delay(0.5), value: animateContent)
                .padding(.horizontal, 20)
                
                // Exercise list
                VStack(alignment: .leading, spacing: 16) {
                    Text("Exercises")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.vitalText)
                        .padding(.horizontal, 20)
                        .opacity(animateContent ? 1.0 : 0.0)
                        .offset(y: animateContent ? 0 : 20)
                        .animation(.easeOut(duration: 0.6).delay(0.6), value: animateContent)
                    
                    LazyVStack(spacing: 12) {
                        ForEach(Array(workout.exercises.enumerated()), id: \.element.id) { index, exercise in
                            ExerciseRow(exercise: exercise, index: index + 1)
                                .opacity(animateContent ? 1.0 : 0.0)
                                .offset(y: animateContent ? 0 : 20)
                                .animation(.easeOut(duration: 0.6).delay(0.7 + Double(index) * 0.1), value: animateContent)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                Spacer(minLength: 30)
            }
            .padding(.top, 10)
        }
        .safeAreaInset(edge: .bottom) {
            Button(action: onStart) {
                HStack(spacing: 12) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Start Workout")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    LinearGradient(
                        colors: [Color.vitalPrimary, Color.vitalPrimary.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(28)
                .shadow(color: Color.vitalPrimary.opacity(0.3), radius: 15, x: 0, y: 8)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 10)
            .scaleEffect(animateContent ? 1.0 : 0.9)
            .opacity(animateContent ? 1.0 : 0.0)
            .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.8), value: animateContent)
        }
    }
}

struct WorkoutStat: View {
    let title: String
    let value: String
    let iconName: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: iconName)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.vitalAccent)
            
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.vitalText)
            
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.vitalTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.vitalSecondary)
        )
    }
}

struct ExerciseRow: View {
    let exercise: Exercise
    let index: Int
    
    var body: some View {
        HStack(spacing: 16) {
            Text("\(index)")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 32, height: 32)
                .background(Color.vitalPrimary)
                .cornerRadius(16)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.vitalText)
                
                HStack(spacing: 16) {
                    Text("\(exercise.sets) sets")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.vitalTextSecondary)
                    
                    Text(exercise.reps)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.vitalTextSecondary)
                    
                    if exercise.restTime > 0 {
                        Text("\(exercise.restTime)s rest")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.vitalAccent)
                    }
                }
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.vitalSecondary)
        )
    }
}

struct CountdownView: View {
    @Binding var countdown: Int
    let onComplete: () -> Void
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Get Ready!")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.vitalText)
            
            ZStack {
                Circle()
                    .stroke(Color.vitalPrimary.opacity(0.3), lineWidth: 8)
                    .frame(width: 200, height: 200)
                
                Text(countdown > 0 ? "\(countdown)" : "GO!")
                    .font(.system(size: 60, weight: .bold, design: .rounded))
                    .foregroundColor(.vitalPrimary)
                    .scaleEffect(scale)
            }
        }
        .onAppear {
            startCountdown()
        }
    }
    
    private func startCountdown() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                scale = 1.3
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    scale = 1.0
                }
            }
            
            if countdown > 0 {
                countdown -= 1
            } else {
                timer.invalidate()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    onComplete()
                }
            }
        }
    }
}

struct ActiveWorkoutView: View {
    let workout: Workout
    @Binding var currentExercise: Int
    let onComplete: () -> Void
    let onExit: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            // Header
            HStack {
                Button(action: onExit) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.vitalTextSecondary)
                        .frame(width: 32, height: 32)
                        .background(Color.vitalSecondary)
                        .cornerRadius(16)
                }
                
                Spacer()
                
                Text("\(currentExercise + 1) of \(workout.exercises.count)")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.vitalTextSecondary)
            }
            .padding(.horizontal, 20)
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.vitalSecondary)
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.vitalPrimary)
                        .frame(width: geometry.size.width * (Double(currentExercise + 1) / Double(workout.exercises.count)), height: 8)
                        .animation(.easeInOut(duration: 0.5), value: currentExercise)
                }
            }
            .frame(height: 8)
            .padding(.horizontal, 20)
            
            Spacer()
            
            // Current exercise
            if currentExercise < workout.exercises.count {
                let exercise = workout.exercises[currentExercise]
                
                VStack(spacing: 30) {
                    Text(exercise.name)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.vitalText)
                        .multilineTextAlignment(.center)
                    
                    VStack(spacing: 16) {
                        HStack(spacing: 30) {
                            VStack(spacing: 8) {
                                Text("Sets")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.vitalTextSecondary)
                                
                                Text("\(exercise.sets)")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.vitalAccent)
                            }
                            
                            VStack(spacing: 8) {
                                Text("Reps")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.vitalTextSecondary)
                                
                                Text(exercise.reps)
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.vitalAccent)
                            }
                            
                            if exercise.restTime > 0 {
                                VStack(spacing: 8) {
                                    Text("Rest")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.vitalTextSecondary)
                                    
                                    Text("\(exercise.restTime)s")
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(.vitalAccent)
                                }
                            }
                        }
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.vitalSecondary)
                    )
                }
                .padding(.horizontal, 20)
            }
            
            Spacer()
            
            // Next button
            Button(action: {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    if currentExercise < workout.exercises.count - 1 {
                        currentExercise += 1
                    } else {
                        onComplete()
                    }
                }
            }) {
                Text(currentExercise < workout.exercises.count - 1 ? "Next Exercise" : "Complete Workout")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.vitalPrimary)
                    .cornerRadius(28)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
    }
}

struct CompletionView: View {
    let workout: Workout
    let onDismiss: () -> Void
    @State private var animateContent = false
    @State private var showBadge = false
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            VStack(spacing: 30) {
                // Success animation
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.vitalPrimary, Color.vitalAccent],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                        .scaleEffect(animateContent ? 1.0 : 0.5)
                        .animation(.spring(response: 0.8, dampingFraction: 0.6), value: animateContent)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 50, weight: .bold))
                        .foregroundColor(.white)
                        .scaleEffect(animateContent ? 1.0 : 0.5)
                        .animation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.2), value: animateContent)
                }
                
                VStack(spacing: 16) {
                    Text("Workout Complete!")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.vitalText)
                        .opacity(animateContent ? 1.0 : 0.0)
                        .offset(y: animateContent ? 0 : 20)
                        .animation(.easeOut(duration: 0.6).delay(0.4), value: animateContent)
                    
                    Text("Great job completing \(workout.title)!")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.vitalTextSecondary)
                        .multilineTextAlignment(.center)
                        .opacity(animateContent ? 1.0 : 0.0)
                        .offset(y: animateContent ? 0 : 20)
                        .animation(.easeOut(duration: 0.6).delay(0.5), value: animateContent)
                }
                
                // Badge notification
                if showBadge {
                    VStack(spacing: 12) {
                        Image(systemName: "figure.walk")
                            .font(.system(size: 30))
                            .foregroundColor(.vitalAccent)
                        
                        Text("Badge Unlocked!")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.vitalAccent)
                        
                        Text("First Step")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.vitalTextSecondary)
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.vitalSecondary)
                            .shadow(color: Color.vitalAccent.opacity(0.3), radius: 10, x: 0, y: 5)
                    )
                    .scaleEffect(showBadge ? 1.0 : 0.8)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showBadge)
                }
            }
            
            Spacer()
            
            Button(action: onDismiss) {
                Text("Continue")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.vitalPrimary)
                    .cornerRadius(28)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
            .scaleEffect(animateContent ? 1.0 : 0.9)
            .opacity(animateContent ? 1.0 : 0.0)
            .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.6), value: animateContent)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8)) {
                animateContent = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    showBadge = true
                }
            }
        }
    }
}

struct StatBadge: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(color)
            
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.vitalTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.vitalSecondary)
        )
    }
}

#Preview {
    WorkoutView(userProgress: UserProgress())
}
