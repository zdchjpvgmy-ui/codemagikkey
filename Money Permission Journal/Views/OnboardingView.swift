//
//  OnboardingView.swift
//  Money Permission Journal
//
//  Created on 2025.
//

import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    @Binding var isComplete: Bool
    
    let pages: [(title: String, description: String, icon: String)] = [
        ("A gentle space", "A gentle space to give yourself permission around money", "heart.text.square"),
        ("Grant yourself freedom", "Grant yourself freedom, set boundaries, celebrate self-kindness", "sparkles"),
        ("Private and judgment-free", "Private, offline, judgment-free acts of self-love", "lock.shield")
    ]
    
    var body: some View {
        ZStack {
            Color(UIColor.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(
                            title: pages[index].title,
                            description: pages[index].description,
                            icon: pages[index].icon
                        )
                        .tag(index)
                    }
                }
                .tabViewStyle(.page)
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                
                VStack(spacing: 20) {
                    if currentPage == pages.count - 1 {
                        Button(action: {
                            UserDefaults.standard.set(true, forKey: UserDefaultsKeys.hasCompletedOnboarding)
                            isComplete = true
                        }) {
                            Text("Begin Your Journey")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(
                                    LinearGradient(
                                        colors: [Color.appSkyBlue, Color.appGentleLavender],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(28)
                                .padding(.horizontal, 32)
                        }
                    } else {
                        Button(action: {
                            withAnimation {
                                currentPage += 1
                            }
                        }) {
                            Text("Continue")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(
                                    LinearGradient(
                                        colors: [Color.appSkyBlue, Color.appGentleLavender],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(28)
                                .padding(.horizontal, 32)
                        }
                    }
                }
                .padding(.bottom, 50)
            }
        }
    }
}

struct OnboardingPageView: View {
    let title: String
    let description: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            Image(systemName: icon)
                .font(.system(size: 80))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.appSkyBlue, Color.appSoftGold],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            VStack(spacing: 16) {
                Text(title)
                    .font(.custom("Georgia", size: 36))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                
                Text(description)
                    .font(.system(size: 20, design: .rounded))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .lineSpacing(6)
            }
            
            Spacer()
            Spacer()
            
            Text("This is a private personal permission journal. Not financial advice or psychological therapy.")
                .font(.system(size: 11))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .padding(.bottom, 20)
        }
    }
}

#Preview {
    OnboardingView(isComplete: .constant(false))
}
