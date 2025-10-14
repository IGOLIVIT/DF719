//
//  OnboardingView.swift
//  DF719
//
//  Created by IGOR on 14/10/2025.
//

import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    @State private var animateContent = false
    @Binding var hasCompletedOnboarding: Bool
    
    private let onboardingPages = [
        OnboardingPage(
            title: "Build Your Strength",
            subtitle: "Step by Step",
            description: "Transform your body with personalized workouts designed to build real strength and endurance.",
            iconName: "dumbbell.fill",
            gradient: [Color.vitalPrimary, Color.vitalAccent]
        ),
        OnboardingPage(
            title: "Eat Smart",
            subtitle: "Train Harder",
            description: "Fuel your body with nutrition plans that support your fitness goals and boost your performance.",
            iconName: "leaf.fill",
            gradient: [Color.vitalAccent, Color.vitalPrimary]
        ),
        OnboardingPage(
            title: "Track Progress",
            subtitle: "Feel Unstoppable",
            description: "Monitor your journey with detailed analytics and celebrate every milestone you achieve.",
            iconName: "chart.line.uptrend.xyaxis",
            gradient: [Color.vitalPrimary, Color.purple]
        ),
        OnboardingPage(
            title: "Ready to Rise?",
            subtitle: "Your Journey Starts Now",
            description: "Join thousands who've transformed their lives. Your strongest self is waiting.",
            iconName: "figure.strengthtraining.traditional",
            gradient: [Color.vitalAccent, Color.vitalPrimary]
        )
    ]
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [Color.vitalBackground, Color.vitalBackground.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Animated background particles
            ForEach(0..<15, id: \.self) { index in
                Circle()
                    .fill(Color.vitalPrimary.opacity(0.1))
                    .frame(width: CGFloat.random(in: 20...60))
                    .position(
                        x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                        y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                    )
                    .animation(
                        Animation.easeInOut(duration: Double.random(in: 3...6))
                            .repeatForever(autoreverses: true)
                            .delay(Double.random(in: 0...2)),
                        value: animateContent
                    )
            }
            
            VStack(spacing: 0) {
                // Content
                TabView(selection: $currentPage) {
                    ForEach(0..<onboardingPages.count, id: \.self) { index in
                        OnboardingPageView(
                            page: onboardingPages[index],
                            isActive: currentPage == index,
                            animateContent: $animateContent
                        )
                        .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.6), value: currentPage)
                
                // Bottom section
                VStack(spacing: 30) {
                    // Page indicators
                    HStack(spacing: 12) {
                        ForEach(0..<onboardingPages.count, id: \.self) { index in
                            Capsule()
                                .fill(currentPage == index ? Color.vitalPrimary : Color.vitalTextSecondary)
                                .frame(width: currentPage == index ? 30 : 8, height: 8)
                                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: currentPage)
                        }
                    }
                    
                    // Action button
                    Button(action: {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            if currentPage < onboardingPages.count - 1 {
                                currentPage += 1
                            } else {
                                hasCompletedOnboarding = true
                            }
                        }
                    }) {
                        HStack(spacing: 12) {
                            Text(currentPage < onboardingPages.count - 1 ? "Continue" : "Start Your Journey")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            
                            Image(systemName: currentPage < onboardingPages.count - 1 ? "arrow.right" : "flame.fill")
                                .font(.system(size: 16, weight: .bold))
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
                    .scaleEffect(animateContent ? 1.0 : 0.9)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.4), value: animateContent)
                    .padding(.horizontal, 30)
                    
                    // Skip button
                    if currentPage < onboardingPages.count - 1 {
                        Button("Skip") {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                hasCompletedOnboarding = true
                            }
                        }
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.vitalTextSecondary)
                        .opacity(animateContent ? 1.0 : 0.0)
                        .animation(.easeInOut(duration: 0.5).delay(0.6), value: animateContent)
                    }
                }
                .padding(.bottom, 50)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0)) {
                animateContent = true
            }
        }
    }
}

struct OnboardingPage {
    let title: String
    let subtitle: String
    let description: String
    let iconName: String
    let gradient: [Color]
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    let isActive: Bool
    @Binding var animateContent: Bool
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Icon with animated background
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: page.gradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .scaleEffect(isActive && animateContent ? 1.0 : 0.8)
                    .animation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.2), value: isActive && animateContent)
                
                Image(systemName: page.iconName)
                    .font(.system(size: 50, weight: .medium))
                    .foregroundColor(.white)
                    .scaleEffect(isActive && animateContent ? 1.0 : 0.7)
                    .animation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.4), value: isActive && animateContent)
            }
            .shadow(color: page.gradient[0].opacity(0.3), radius: 20, x: 0, y: 10)
            
            // Text content
            VStack(spacing: 16) {
                VStack(spacing: 8) {
                    Text(page.title)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.vitalText)
                        .multilineTextAlignment(.center)
                        .opacity(isActive && animateContent ? 1.0 : 0.0)
                        .offset(y: isActive && animateContent ? 0 : 20)
                        .animation(.easeOut(duration: 0.6).delay(0.3), value: isActive && animateContent)
                    
                    Text(page.subtitle)
                        .font(.system(size: 24, weight: .medium, design: .rounded))
                        .foregroundColor(.vitalAccent)
                        .multilineTextAlignment(.center)
                        .opacity(isActive && animateContent ? 1.0 : 0.0)
                        .offset(y: isActive && animateContent ? 0 : 20)
                        .animation(.easeOut(duration: 0.6).delay(0.4), value: isActive && animateContent)
                }
                
                Text(page.description)
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(.vitalTextSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .padding(.horizontal, 20)
                    .opacity(isActive && animateContent ? 1.0 : 0.0)
                    .offset(y: isActive && animateContent ? 0 : 20)
                    .animation(.easeOut(duration: 0.6).delay(0.5), value: isActive && animateContent)
            }
            
            Spacer()
        }
        .padding(.horizontal, 30)
    }
}

#Preview {
    OnboardingView(hasCompletedOnboarding: .constant(false))
}
