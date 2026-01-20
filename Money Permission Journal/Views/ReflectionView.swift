//
//  ReflectionView.swift
//  Money Permission Journal
//
//  Created on 2025.
//

import SwiftUI

struct ReflectionView: View {
    @State private var viewModel = PermissionViewModel(context: PersistenceController.shared.container.viewContext)
    @State private var selectedPermission: MoneyPermission? = nil
    @State private var reflectionText: String = ""
    
    let reflectionPrompts = [
        "How has this permission changed your perspective?",
        "What emotions did this permission bring up?",
        "How did this permission align with your values?",
        "What would you tell your past self about this permission?",
        "How has this permission impacted your relationship with money?"
    ]
    
    @State private var randomPrompts: [String] = []
    
    var recentPermissions: [MoneyPermission] {
        Array(viewModel.allPermissions.prefix(10))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        weeklyPromptSection
                        
                        if selectedPermission != nil {
                            reflectionInputSection
                        } else {
                            permissionSelector
                        }
                        
                        Text("This is a private personal permission journal. Not financial advice or psychological therapy.")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                            .padding(.top, 20)
                    }
                    .padding(24)
                }
            }
            .navigationTitle("Reflection")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                viewModel = PermissionViewModel(context: PersistenceController.shared.container.viewContext)
                randomPrompts = Array(reflectionPrompts.shuffled().prefix(3))
            }
            .refreshable {
                viewModel = PermissionViewModel(context: PersistenceController.shared.container.viewContext)
            }
        }
    }
    
    private var weeklyPromptSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Weekly Reflection")
                .font(.custom("Georgia", size: 24))
                .foregroundColor(.primary)
            
            Text("How has this permission changed your week?")
                .font(.system(size: 18, design: .rounded))
                .foregroundColor(.secondary)
            
            if !randomPrompts.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Guided Questions:")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.secondary)
                    
                    ForEach(randomPrompts, id: \.self) { prompt in
                        HStack(alignment: .top, spacing: 12) {
                            Circle()
                                .fill(Color.appSkyBlue.opacity(0.3))
                                .frame(width: 8, height: 8)
                                .padding(.top, 6)
                            
                            Text(prompt)
                                .font(.system(size: 16))
                                .foregroundColor(.primary)
                        }
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color(UIColor.secondarySystemBackground))
                )
            }
        }
    }
    
    private var permissionSelector: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Select a Permission to Reflect On")
                .font(.custom("Georgia", size: 20))
                .foregroundColor(.primary)
            
            ForEach(recentPermissions) { permission in
                Button(action: {
                    selectedPermission = permission
                }) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(permission.statement)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.primary)
                            .lineLimit(2)
                        Text(permission.date, style: .date)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(UIColor.secondarySystemBackground))
                    )
                }
            }
        }
    }
    
    private var reflectionInputSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            if let permission = selectedPermission {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Reflecting on:")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.secondary)
                    Text(permission.statement)
                        .font(.custom("Georgia", size: 20))
                        .foregroundColor(.primary)
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color(UIColor.secondarySystemBackground))
                )
            }
            
            TextField("Your reflection...", text: $reflectionText, axis: .vertical)
                .textFieldStyle(.plain)
                .font(.system(size: 18))
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color(UIColor.secondarySystemBackground))
                )
                .lineLimit(8...15)
            
            HStack(spacing: 16) {
                Button(action: {
                    selectedPermission = nil
                    reflectionText = ""
                }) {
                    Text("Cancel")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(24)
                }
                
                Button(action: {
                    if let permission = selectedPermission {
                        if permission.actualOutcome == nil || permission.actualOutcome!.isEmpty {
                            permission.actualOutcome = reflectionText
                        } else {
                            permission.actualOutcome = (permission.actualOutcome ?? "") + "\n\nReflection: \(reflectionText)"
                        }
                        permission.updatedAt = Date()
                        viewModel.updatePermission(permission)
                    }
                    selectedPermission = nil
                    reflectionText = ""
                }) {
                    Text("Save Reflection")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            LinearGradient(
                                colors: [Color.appSkyBlue, Color.appGentleLavender],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(24)
                }
                .disabled(reflectionText.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
    }
}

#Preview {
    ReflectionView()
}
