//
//  DashboardView.swift
//  Money Permission Journal
//
//  Created on 2025.
//

import SwiftUI
import CoreData

struct DashboardView: View {
    @State private var viewModel = PermissionViewModel(context: PersistenceController.shared.container.viewContext)
    @State private var refreshID = UUID()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        headerSection
                        
                        liberationGauge
                        
                        quickStats
                        
                        recentPermissions
                        
                        Text("This is a private personal permission journal. Not financial advice or psychological therapy.")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                            .padding(.top, 20)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                }
                
                VStack {
                    Spacer()
                    NavigationLink(destination: PermissionFormView(permission: nil, viewModel: viewModel)
                        .onDisappear {
                            refreshData()
                        }
                    ) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 24))
                            Text("Grant Permission")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                        }
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
                        .shadow(color: Color.appSkyBlue.opacity(0.4), radius: 20, x: 0, y: 10)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("Money Permissions")
            .navigationBarTitleDisplayMode(.large)
        }
        .refreshable {
            refreshData()
        }
        .onAppear {
            // Refresh data when view appears
            refreshData()
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("PermissionDataChanged"))) { _ in
            // Refresh when permission data changes
            refreshData()
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\(viewModel.permissionCount()) money permissions granted")
                .font(.custom("Georgia", size: 28))
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var liberationGauge: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(Color.appGentleLavender.opacity(0.4), lineWidth: 20)
                    .frame(width: 200, height: 200)
                
                Circle()
                    .trim(from: 0, to: min(CGFloat(viewModel.permissionCount()) / 100.0, 1.0))
                    .stroke(
                        LinearGradient(
                            colors: [Color.appSkyBlue, Color.appSoftGold],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 20, lineCap: .round)
                    )
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(-90))
                
                VStack(spacing: 4) {
                    Text("Financial")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                    Text("Freedom")
                        .font(.custom("Georgia", size: 32))
                        .foregroundColor(.primary)
                    Text("\(Int(min(CGFloat(viewModel.permissionCount()) / 100.0, 1.0) * 100))%")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.appSkyBlue)
                }
            }
        }
        .padding(.vertical, 20)
    }
    
    private var quickStats: some View {
        HStack(spacing: 16) {
            StatCard(
                title: "Longest Streak",
                value: "\(viewModel.longestStreak()) days",
                color: Color.appSoftGold
            )
            
            StatCard(
                title: "Most Common Tag",
                value: viewModel.mostCommonTag() ?? "—",
                color: Color.appGentleLavender
            )
        }
    }
    
    private var recentPermissions: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Permissions")
                .font(.custom("Georgia", size: 24))
                .foregroundColor(.primary)
            
            if viewModel.allPermissions.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "heart.text.square")
                        .font(.system(size: 48))
                        .foregroundColor(.appSkyBlue.opacity(0.5))
                    Text("No permissions yet")
                        .font(.system(size: 18, design: .rounded))
                        .foregroundColor(.secondary)
                    Text("Tap 'Grant Permission' to begin your journey")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                ForEach(Array(viewModel.allPermissions.prefix(5))) { permission in
                    NavigationLink(destination: PermissionDetailView(permission: permission, viewModel: viewModel)
                        .onDisappear {
                            refreshData()
                        }
                    ) {
                        PermissionCardView(permission: permission)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .id(refreshID)
    }
    
    private func refreshData() {
        viewModel = PermissionViewModel(context: PersistenceController.shared.container.viewContext)
        refreshID = UUID()
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
            Text(value)
                .font(.custom("Georgia", size: 22))
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(UIColor.tertiarySystemBackground))
        )
    }
}

struct PermissionCardView: View {
    let permission: MoneyPermission
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(permission.statement)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                Spacer()
                
                if permission.emotionalImpact > 0 {
                    Image(systemName: "star.fill")
                        .foregroundColor(.appSoftGold)
                        .font(.system(size: 14))
                }
            }
            
            HStack(spacing: 12) {
                if let category = permission.category {
                    Text(category)
                        .font(.system(size: 12))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.appSkyBlue.opacity(0.2))
                        )
                }
                
                Text(permission.date, style: .date)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                
                Spacer()
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(Color(UIColor.secondarySystemBackground))
        )
    }
}

#Preview {
    DashboardView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
