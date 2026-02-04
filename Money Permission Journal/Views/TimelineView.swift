

import SwiftUI

struct TimelineView: View {
    @State private var viewModel = PermissionViewModel(context: PersistenceController.shared.container.viewContext)
    @State private var selectedMonth: Date = Date()
    @State private var selectedTag: String? = nil
    
    var filteredPermissions: [MoneyPermission] {
        var permissions = viewModel.allPermissions
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: selectedMonth)
        let startOfMonth = calendar.date(from: components)!
        let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth)!
        
        permissions = permissions.filter { permission in
            permission.date >= startOfMonth && permission.date <= endOfMonth
        }
        
        if let tag = selectedTag {
            permissions = permissions.filter { $0.emotionalTags.contains(tag) }
        }
        
        return permissions
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    filtersSection
                    
                    ScrollView {
                        if filteredPermissions.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "calendar")
                                    .font(.system(size: 48))
                                    .foregroundColor(.appSkyBlue.opacity(0.5))
                                Text("No permissions yet")
                                    .font(.system(size: 18, design: .rounded))
                                    .foregroundColor(.primary)
                                Text("Permissions for this period will appear here")
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 60)
                        } else {
                            LazyVStack(spacing: 24) {
                                ForEach(filteredPermissions) { permission in
                                    NavigationLink(destination: PermissionDetailView(permission: permission, viewModel: viewModel)) {
                                        TimelinePermissionCard(permission: permission)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(24)
                        }
                    }
                }
            }
            .navigationTitle("Timeline")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                viewModel = PermissionViewModel(context: PersistenceController.shared.container.viewContext)
            }
            .refreshable {
                viewModel = PermissionViewModel(context: PersistenceController.shared.container.viewContext)
            }
        }
    }
    
    private var filtersSection: some View {
        VStack(spacing: 16) {
            DatePicker("Month", selection: $selectedMonth, displayedComponents: [.date])
                .datePickerStyle(.compact)
                .labelsHidden()
            
            if !viewModel.allTags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        Button(action: {
                            selectedTag = nil
                        }) {
                            Text("All")
                                .font(.system(size: 14))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(selectedTag == nil ? Color.appSkyBlue : Color.gray.opacity(0.3))
                                )
                                .foregroundColor(selectedTag == nil ? .white : .primary)
                        }
                        
                        ForEach(viewModel.allTags) { tag in
                            Button(action: {
                                selectedTag = selectedTag == tag.name ? nil : tag.name
                            }) {
                                Text(tag.name)
                                    .font(.system(size: 14))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(selectedTag == tag.name ? Color.appGentleLavender : Color.gray.opacity(0.3))
                                    )
                                    .foregroundColor(selectedTag == tag.name ? .white : .primary)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                }
            }
        }
        .padding(.vertical, 16)
        .background(Color(UIColor.secondarySystemBackground))
    }
}

struct TimelinePermissionCard: View {
    let permission: MoneyPermission
    
    var categoryColor: Color {
        if let category = permission.category {
            return Color.appSkyBlue
        }
        return Color.gray
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(spacing: 4) {
                Circle()
                    .fill(categoryColor.opacity(0.3))
                    .frame(width: 12, height: 12)
                Rectangle()
                    .fill(categoryColor.opacity(0.3))
                    .frame(width: 2)
                    .frame(maxHeight: .infinity)
            }
            .frame(width: 12)
            
            VStack(alignment: .leading, spacing: 12) {
                Text(permission.date, style: .date)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
                
                Text(permission.statement)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                if let category = permission.category {
                    Text(category)
                        .font(.system(size: 12))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.appSkyBlue.opacity(0.2))
                        )
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(UIColor.secondarySystemBackground))
        )
    }
}

#Preview {
    TimelineView()
}
