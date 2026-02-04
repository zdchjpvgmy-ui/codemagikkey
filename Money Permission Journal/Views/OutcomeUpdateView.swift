//
//  OutcomeUpdateView.swift
//  Money Permission Journal
//
//  Created on 2025.
//

import SwiftUI

struct OutcomeUpdateView: View {
    let permission: MoneyPermission
    var viewModel: PermissionViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var outcomeText: String = ""
    @State private var emotionalImpact: Int16 = 0
    @State private var showCelebration = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 32) {
                    if showCelebration {
                        CelebrationAnimationView()
                            .frame(height: 200)
                    }
                    
                    VStack(alignment: .leading, spacing: 20) {
                        Text("How did this permission feel?")
                            .font(.custom("Georgia", size: 24))
                            .foregroundColor(.primary)
                        
                        TextField("Describe the outcome...", text: $outcomeText, axis: .vertical)
                            .textFieldStyle(.plain)
                            .font(.system(size: 18))
                            .padding(20)
                            .background(
                                RoundedRectangle(cornerRadius: 24)
                                    .fill(Color(UIColor.secondarySystemBackground))
                            )
                            .lineLimit(4...8)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Emotional Impact (1-10)")
                                .font(.system(size: 16, weight: .semibold))
                            
                            HStack {
                                Text("1")
                                Slider(value: Binding(
                                    get: { Double(emotionalImpact) },
                                    set: { emotionalImpact = Int16($0) }
                                ), in: 0...10, step: 1)
                                Text("10")
                                
                                Text("\(emotionalImpact)")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.appSoftGold)
                                    .frame(width: 30)
                            }
                            .padding(20)
                            .background(
                                RoundedRectangle(cornerRadius: 24)
                                    .fill(Color(UIColor.secondarySystemBackground))
                            )
                        }
                    }
                    .padding(24)
                    
                    Button(action: {
                        permission.actualOutcome = outcomeText
                        permission.emotionalImpact = emotionalImpact
                        permission.updatedAt = Date()
                        viewModel.updatePermission(permission)
                        NotificationCenter.default.post(name: NSNotification.Name("PermissionDataChanged"), object: nil)
                        
                        if emotionalImpact >= 7 {
                            withAnimation {
                                showCelebration = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                dismiss()
                            }
                        } else {
                            dismiss()
                        }
                    }) {
                        Text("Save Outcome")
                            .font(.system(size: 18, weight: .semibold))
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
                    }
                    .padding(.horizontal, 24)
                    .disabled(outcomeText.trimmingCharacters(in: .whitespaces).isEmpty)
                    
                    Spacer()
                }
                .padding(.top, 40)
            }
            .navigationTitle("Update Outcome")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                outcomeText = permission.actualOutcome ?? ""
                emotionalImpact = permission.emotionalImpact
            }
        }
    }
}

struct CelebrationAnimationView: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            ForEach(0..<8, id: \.self) { index in
                BloomingFlowerView()
                    .offset(
                        x: isAnimating ? cos(Double(index) * .pi / 4) * 80 : 0,
                        y: isAnimating ? sin(Double(index) * .pi / 4) * 80 : 0
                    )
                    .opacity(isAnimating ? 0 : 1)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 1.0, dampingFraction: 0.6)) {
                isAnimating = true
            }
        }
    }
}

#Preview {
    OutcomeUpdateView(
        permission: MoneyPermission(context: PersistenceController.shared.container.viewContext),
        viewModel: PermissionViewModel(context: PersistenceController.shared.container.viewContext)
    )
}
