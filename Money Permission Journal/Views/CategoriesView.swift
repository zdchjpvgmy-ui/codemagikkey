//
//  CategoriesView.swift
//  Money Permission Journal
//
//  Created on 2025.
//

import SwiftUI

struct CategoriesView: View {
    @State private var viewModel = PermissionViewModel(context: PersistenceController.shared.container.viewContext)
    @State private var showingAddCategory = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()
                
                if viewModel.allCategories.isEmpty {
                    VStack(spacing: 24) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.appSkyBlue.opacity(0.2), Color.appGentleLavender.opacity(0.2)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 120, height: 120)
                            
                            Image(systemName: "tag.fill")
                                .font(.system(size: 56))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color.appSkyBlue, Color.appGentleLavender],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }
                        
                        VStack(spacing: 12) {
                            Text("No Categories Yet")
                                .font(.custom("Georgia", size: 28))
                                .foregroundColor(.primary)
                            
                            Text("Create categories to organize your permissions and track your progress")
                                .font(.system(size: 16, design: .rounded))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                                .lineSpacing(4)
                        }
                        
                        Button(action: {
                            showingAddCategory = true
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 20))
                                Text("Create Your First Category")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [Color.appSkyBlue, Color.appGentleLavender],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(24)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.allCategories) { category in
                                NavigationLink(destination: CategoryPermissionsView(category: category, viewModel: viewModel)) {
                                    CategoryCard(category: category, viewModel: viewModel)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(24)
                    }
                }
            }
            .navigationTitle("Categories")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddCategory = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddCategory) {
                AddCategoryView(viewModel: viewModel) {
                    viewModel = PermissionViewModel(context: PersistenceController.shared.container.viewContext)
                }
            }
            .onAppear {
                viewModel = PermissionViewModel(context: PersistenceController.shared.container.viewContext)
            }
            .refreshable {
                viewModel = PermissionViewModel(context: PersistenceController.shared.container.viewContext)
            }
        }
    }
}

struct CategoryPermissionsView: View {
    let category: PermissionCategory
    @State var viewModel: PermissionViewModel
    
    var categoryPermissions: [MoneyPermission] {
        viewModel.permissions(for: category.name)
    }
    
    var body: some View {
        ScrollView {
            if categoryPermissions.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: category.iconName ?? "tag.fill")
                        .font(.system(size: 48))
                        .foregroundColor(categoryColor.opacity(0.5))
                    Text("No permissions in this category yet")
                        .font(.system(size: 18, design: .rounded))
                        .foregroundColor(.primary)
                    Text("Permissions assigned to \"\(category.name)\" will appear here")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 60)
            } else {
                LazyVStack(spacing: 16) {
                    ForEach(categoryPermissions) { permission in
                        NavigationLink(destination: PermissionDetailView(permission: permission, viewModel: viewModel)) {
                            CategoryPermissionCard(permission: permission)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(24)
            }
        }
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle(category.name)
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            viewModel = PermissionViewModel(context: PersistenceController.shared.container.viewContext)
        }
    }
    
    var categoryColor: Color {
        if let colorHex = category.colorHex {
            return Color(hex: colorHex)
        }
        return Color.appSkyBlue
    }
}

struct CategoryPermissionCard: View {
    let permission: MoneyPermission
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(permission.statement)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.primary)
                .lineLimit(3)
            
            HStack {
                Text(permission.date, style: .date)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                
                if permission.emotionalImpact > 0 {
                    Spacer()
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                        Text("\(permission.emotionalImpact)/10")
                            .font(.system(size: 12))
                    }
                    .foregroundColor(.appSoftGold)
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(UIColor.secondarySystemBackground))
        )
    }
}

struct CategoryCard: View {
    let category: PermissionCategory
    var viewModel: PermissionViewModel
    
    var permissionCount: Int {
        viewModel.permissions(for: category.name).count
    }
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(categoryColor.opacity(0.15))
                    .frame(width: 70, height: 70)
                
                if let iconName = category.iconName {
                    Image(systemName: iconName)
                        .font(.system(size: 32, weight: .medium))
                        .foregroundColor(categoryColor)
                } else {
                    Image(systemName: "tag.fill")
                        .font(.system(size: 32, weight: .medium))
                        .foregroundColor(categoryColor)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(category.name)
                    .font(.custom("Georgia", size: 22))
                    .foregroundColor(.primary)
                
                HStack(spacing: 8) {
                    Image(systemName: "list.bullet")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    Text("\(permissionCount) permission\(permissionCount == 1 ? "" : "s")")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Color indicator
            Circle()
                .fill(categoryColor)
                .frame(width: 24, height: 24)
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 2)
                )
                .shadow(color: categoryColor.opacity(0.3), radius: 4, x: 0, y: 2)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(Color(UIColor.secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28)
                .stroke(categoryColor.opacity(0.3), lineWidth: 1)
        )
    }
    
    var categoryColor: Color {
        if let colorHex = category.colorHex {
            return Color(hex: colorHex)
        }
        return Color.appSkyBlue
    }
}

struct AddCategoryView: View {
    var viewModel: PermissionViewModel
    var onDismiss: (() -> Void)? = nil
    @Environment(\.dismiss) var dismiss
    
    @State private var name: String = ""
    @State private var selectedIcon: String = "tag"
    @State private var selectedColor: Color = .appSkyBlue
    
    let availableIcons = ["tag", "heart", "star", "leaf", "sparkles", "gift", "cart", "creditcard", "dollarsign.circle"]
    let availableColors: [Color] = [.appSkyBlue, .appSoftGold, .appGentleLavender, .red, .green, .orange, .purple]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    TextField("Category name", text: $name)
                        .textFieldStyle(.roundedBorder)
                        .font(.system(size: 18))
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Icon")
                            .font(.system(size: 16, weight: .semibold))
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(availableIcons, id: \.self) { icon in
                                    Button(action: {
                                        selectedIcon = icon
                                    }) {
                                        Image(systemName: icon)
                                            .font(.system(size: 32))
                                            .foregroundColor(selectedIcon == icon ? .white : selectedColor)
                                            .frame(width: 60, height: 60)
                                            .background(
                                                Circle()
                                                    .fill(selectedIcon == icon ? selectedColor : selectedColor.opacity(0.2))
                                            )
                                    }
                                }
                            }
                            .padding(.horizontal, 4)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Color")
                            .font(.system(size: 16, weight: .semibold))
                        
                        HStack(spacing: 16) {
                            ForEach(availableColors, id: \.self) { color in
                                Button(action: {
                                    selectedColor = color
                                }) {
                                    Circle()
                                        .fill(color)
                                        .frame(width: 40, height: 40)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.primary, lineWidth: selectedColor == color ? 3 : 0)
                                        )
                                }
                            }
                        }
                    }
                    
                    Button(action: {
                        viewModel.createCategory(
                            name: name.trimmingCharacters(in: .whitespaces),
                            iconName: selectedIcon,
                            colorHex: selectedColor.toHex()
                        )
                        onDismiss?()
                        dismiss()
                    }) {
                        Text("Create Category")
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
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                    
                    Text("This is a private personal permission journal. Not financial advice or psychological therapy.")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                .padding(24)
            }
            .navigationTitle("New Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

extension Color {
    func toHex() -> String {
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return String(format: "%02X%02X%02X", Int(red * 255), Int(green * 255), Int(blue * 255))
    }
}

#Preview {
    CategoriesView()
}
