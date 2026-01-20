//
//  SplashScreenView.swift
//  Money Permission Journal
//
//  Created on 2025.
//

import SwiftUI

struct SplashScreenView: View {
    @State private var showChain = true
    @State private var showFeathers = false
    @State private var showTitle = false
    @Binding var isComplete: Bool
    
    var body: some View {
        ZStack {
            Color(UIColor.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                if showChain {
                    ChainBreakingView()
                        .frame(height: 100)
                        .opacity(showChain ? 1 : 0)
                }
                
                if showFeathers {
                    ForEach(0..<12, id: \.self) { index in
                        FeatherView()
                            .offset(
                                x: CGFloat.random(in: -150...150),
                                y: CGFloat.random(in: -100...100)
                            )
                    }
                }
                
                if showTitle {
                    Text("Money Permission Journal")
                        .font(.custom("Georgia", size: 32))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .opacity(showTitle ? 1 : 0)
                        .transition(.opacity.combined(with: .scale))
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.easeOut(duration: 1.0)) {
                    showChain = false
                    showFeathers = true
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.easeOut(duration: 1.0)) {
                    showTitle = true
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.5) {
                withAnimation(.easeOut(duration: 0.5)) {
                    isComplete = true
                }
            }
        }
    }
}

#Preview {
    SplashScreenView(isComplete: .constant(false))
}
