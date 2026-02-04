//
//  InsightsView.swift
//  Money Permission Journal
//
//  Created on 2025.
//

import SwiftUI
import Charts

struct InsightsView: View {
    @State private var viewModel = PermissionViewModel(context: PersistenceController.shared.container.viewContext)
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    emotionalImpactByCategory
                    insightsStats
                    
                    Text("This is a private personal permission journal. Not financial advice or psychological therapy.")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .padding(.top, 20)
                }
                .padding(24)
            }
            .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Freedom Insights")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                viewModel = PermissionViewModel(context: PersistenceController.shared.container.viewContext)
            }
            .refreshable {
                viewModel = PermissionViewModel(context: PersistenceController.shared.container.viewContext)
            }
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name("PermissionDataChanged"))) { _ in
                viewModel = PermissionViewModel(context: PersistenceController.shared.container.viewContext)
            }
        }
    }
    
    private var emotionalImpactByCategory: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Average Emotional Impact by Category")
                .font(.custom("Georgia", size: 24))
                .foregroundColor(.primary)
            
            let categoryAverages = Dictionary(grouping: viewModel.allPermissions) { $0.category ?? "Uncategorized" }
                .mapValues { permissions in
                    let impacts = permissions.compactMap { $0.emotionalImpact > 0 ? Double($0.emotionalImpact) : nil }
                    return impacts.isEmpty ? 0.0 : impacts.reduce(0, +) / Double(impacts.count)
                }
            
            Chart {
                    ForEach(Array(categoryAverages.keys.sorted()), id: \.self) { category in
                        BarMark(
                            x: .value("Category", category),
                            y: .value("Impact", categoryAverages[category] ?? 0)
                        )
                        .foregroundStyle(Color.appSoftGold.gradient)
                    }
                }
                .frame(height: 200)
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 28)
                        .fill(Color(UIColor.secondarySystemBackground))
                )
        }
    }
    
    private var insightsStats: some View {
        VStack(spacing: 16) {
            InsightStatCard(
                title: "Most Liberating Category",
                value: mostLiberatingCategory,
                icon: "sparkles"
            )
            
            InsightStatCard(
                title: "Biggest Boundary Set",
                value: biggestBoundary,
                icon: "lock.shield"
            )
        }
    }
    
    var mostLiberatingCategory: String {
        let categoryAverages = Dictionary(grouping: viewModel.allPermissions) { $0.category ?? "Uncategorized" }
            .mapValues { permissions in
                let impacts = permissions.compactMap { $0.emotionalImpact > 0 ? Double($0.emotionalImpact) : nil }
                return impacts.isEmpty ? 0.0 : impacts.reduce(0, +) / Double(impacts.count)
            }
        
        return categoryAverages.max(by: { $0.value < $1.value })?.key ?? "—"
    }
    
    var biggestBoundary: String {
        let currentYear = Calendar.current.component(.year, from: Date())
        let thisYearPermissions = viewModel.allPermissions.filter {
            Calendar.current.component(.year, from: $0.date) == currentYear
        }
        
        let categoryCounts = Dictionary(grouping: thisYearPermissions) { $0.category ?? "Uncategorized" }
            .mapValues { $0.count }
        
        return categoryCounts.max(by: { $0.value < $1.value })?.key ?? "—"
    }
}

struct InsightStatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundColor(.appSkyBlue)
                .frame(width: 60, height: 60)
                .background(
                    Circle()
                        .fill(Color.appSkyBlue.opacity(0.2))
                )
            
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.custom("Georgia", size: 24))
                    .foregroundColor(.primary)
            }
            
            Spacer()
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(Color(UIColor.secondarySystemBackground))
        )
    }
}

#Preview {
    InsightsView()
}
