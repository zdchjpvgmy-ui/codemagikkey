//
//  LiberationAnimations.swift
//  Money Permission Journal
//
//  Created on 2025.
//

import SwiftUI

struct ChainBreakingView: View {
    @State private var isBreaking = false
    @State private var linksVisible = true
    @State private var feathersVisible = false
    
    var body: some View {
        ZStack {
            if linksVisible {
                HStack(spacing: 8) {
                    ForEach(0..<5, id: \.self) { index in
                        ChainLinkView()
                            .offset(x: isBreaking ? CGFloat(index - 2) * 60 : 0,
                                   y: isBreaking ? -100 : 0)
                            .opacity(linksVisible ? 1 : 0)
                            .animation(
                                .easeOut(duration: 1.5)
                                .delay(Double(index) * 0.1),
                                value: isBreaking
                            )
                    }
                }
            }
            
            if feathersVisible {
                ForEach(0..<8, id: \.self) { index in
                    FeatherView()
                        .offset(
                            x: CGFloat.random(in: -100...100),
                            y: CGFloat.random(in: -200...0)
                        )
                        .opacity(feathersVisible ? 1 : 0)
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isBreaking = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    linksVisible = false
                    feathersVisible = true
                }
            }
        }
    }
}

struct ChainLinkView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(Color.gray.opacity(0.6))
            .frame(width: 16, height: 20)
    }
}

struct FeatherView: View {
    @State private var rotation: Double = 0
    @State private var opacity: Double = 1
    
    var body: some View {
        Image(systemName: "leaf.fill")
            .foregroundColor(.secondary.opacity(0.8))
            .font(.system(size: 20))
            .rotationEffect(.degrees(rotation))
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeOut(duration: 3.0).repeatForever(autoreverses: false)) {
                    rotation = 360
                    opacity = 0
                }
            }
    }
}

struct BloomingFlowerView: View {
    @State private var isBlooming = false
    
    var body: some View {
        ZStack {
            ForEach(0..<6, id: \.self) { index in
                Circle()
                    .fill(Color.appSoftGold.opacity(0.6))
                    .frame(width: isBlooming ? 30 : 8, height: isBlooming ? 30 : 8)
                    .offset(
                        x: isBlooming ? cos(Double(index) * .pi / 3) * 25 : 0,
                        y: isBlooming ? sin(Double(index) * .pi / 3) * 25 : 0
                    )
            }
            Circle()
                .fill(Color.appSoftGold)
                .frame(width: isBlooming ? 20 : 8, height: isBlooming ? 20 : 8)
        }
        .onAppear {
            withAnimation(.spring(response: 1.2, dampingFraction: 0.6)) {
                isBlooming = true
            }
        }
    }
}

struct RibbonUnfurlView: View {
    @State private var isUnfurled = false
    
    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [Color.appSkyBlue, Color.appGentleLavender],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(height: 3)
            .scaleEffect(x: isUnfurled ? 1 : 0, anchor: .leading)
            .onAppear {
                withAnimation(.easeOut(duration: 1.5)) {
                    isUnfurled = true
                }
            }
    }
}
