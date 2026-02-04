//
//  GalleryView.swift
//  Money Permission Journal
//
//  Created on 2025.
//

import SwiftUI

struct GalleryView: View {
    @State private var viewModel = PermissionViewModel(context: PersistenceController.shared.container.viewContext)
    
    var highImpactPermissions: [MoneyPermission] {
        viewModel.highImpactPermissions().sorted { $0.emotionalImpact > $1.emotionalImpact }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()
                
                if highImpactPermissions.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 48))
                            .foregroundColor(.appSoftGold.opacity(0.5))
                        Text("No high-impact permissions yet")
                            .font(.system(size: 18, design: .rounded))
                            .foregroundColor(.secondary)
                        Text("Permissions with emotional impact 8+ will appear here")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 24) {
                            ForEach(highImpactPermissions) { permission in
                                NavigationLink(destination: PermissionDetailView(permission: permission, viewModel: viewModel)) {
                                    GalleryCard(permission: permission)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(24)
                    }
                }
            }
            .navigationTitle("Empowerment Gallery")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                viewModel = PermissionViewModel(context: PersistenceController.shared.container.viewContext)
            }
            .refreshable {
                viewModel = PermissionViewModel(context: PersistenceController.shared.container.viewContext)
            }
        }
    }
}

struct GalleryCard: View {
    let permission: MoneyPermission
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                ForEach(0..<Int(permission.emotionalImpact), id: \.self) { _ in
                    Image(systemName: "star.fill")
                        .foregroundColor(.appSoftGold)
                        .font(.system(size: 16))
                }
                Spacer()
                Text("\(permission.emotionalImpact)/10")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.appSoftGold)
            }
            
            Text(permission.statement)
                .font(.custom("Georgia", size: 24))
                .foregroundColor(.primary)
                .lineSpacing(6)
            
            if let outcome = permission.actualOutcome {
                Text(outcome)
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .lineLimit(3)
            }
            
            if !permission.emotionalTags.isEmpty {
                FlowLayout(spacing: 8) {
                    ForEach(permission.emotionalTags, id: \.self) { tag in
                        Text(tag)
                            .font(.system(size: 12))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.appGentleLavender.opacity(0.3))
                            )
                    }
                }
            }
            
            Text(permission.date, style: .date)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 32)
                .fill(Color(UIColor.secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 32)
                .stroke(Color.appSoftGold.opacity(0.4), lineWidth: 2)
        )
    }
}

#Preview {
    GalleryView()
}
