//
//  PermissionFormView.swift
//  Money Permission Journal
//
//  Created on 2025.
//

import SwiftUI

struct PermissionFormView: View {
    let permission: MoneyPermission?
    @State var viewModel: PermissionViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var statement: String = ""
    @State private var selectedDate: Date = Date()
    @State private var selectedCategory: String? = nil
    @State private var selectedTags: Set<String> = []
    @State private var expectedImpact: String = ""
    @State private var actualOutcome: String = ""
    @State private var emotionalImpact: Int16 = 0
    @State private var showingCategoryPicker = false
    @State private var showingTagPicker = false
    
    init(permission: MoneyPermission?, viewModel: PermissionViewModel) {
        self.permission = permission
        _viewModel = State(initialValue: viewModel)
        
        if let permission = permission {
            _statement = State(initialValue: permission.statement)
            _selectedDate = State(initialValue: permission.date)
            _selectedCategory = State(initialValue: permission.category)
            _selectedTags = State(initialValue: Set(permission.emotionalTags))
            _expectedImpact = State(initialValue: permission.expectedImpact ?? "")
            _actualOutcome = State(initialValue: permission.actualOutcome ?? "")
            _emotionalImpact = State(initialValue: permission.emotionalImpact)
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        permissionStatementSection
                        dateSection
                        categorySection
                        tagsSection
                        expectedImpactSection
                        outcomeSection
                        emotionalImpactSection
                        
                        Text("This is a private personal permission journal. Not financial advice or psychological therapy.")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                            .padding(.top, 20)
                    }
                    .padding(24)
                }
            }
            .navigationTitle(permission == nil ? "Grant Permission" : "Edit Permission")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        savePermission()
                        NotificationCenter.default.post(name: NSNotification.Name("PermissionDataChanged"), object: nil)
                        dismiss()
                    }
                    .disabled(statement.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .sheet(isPresented: $showingCategoryPicker) {
                CategoryPickerView(
                    selectedCategory: $selectedCategory,
                    categories: viewModel.allCategories,
                    viewModel: viewModel
                )
            }
            .onChange(of: showingCategoryPicker) { _, isShowing in
                if !isShowing {
                    // Refresh viewModel when picker closes
                    viewModel = PermissionViewModel(context: PersistenceController.shared.container.viewContext)
                }
            }
            .sheet(isPresented: $showingTagPicker) {
                TagPickerView(
                    selectedTags: $selectedTags,
                    tags: viewModel.allTags,
                    viewModel: viewModel
                )
            }
            .onChange(of: showingTagPicker) { _, isShowing in
                if !isShowing {
                    // Refresh viewModel when picker closes
                    viewModel = PermissionViewModel(context: PersistenceController.shared.container.viewContext)
                }
            }
        }
    }
    
    private var permissionStatementSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Permission Statement")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
            
            TextField("I allow myself to...", text: $statement, axis: .vertical)
                .textFieldStyle(.plain)
                .font(.custom("Georgia", size: 20))
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color(UIColor.secondarySystemBackground))
                )
                .lineLimit(3...6)
        }
    }
    
    private var dateSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Date")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
            
            DatePicker("", selection: $selectedDate, displayedComponents: .date)
                .datePickerStyle(.compact)
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color(UIColor.secondarySystemBackground))
                )
        }
    }
    
    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Category")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
            
            Button(action: {
                showingCategoryPicker = true
            }) {
                HStack(spacing: 12) {
                    if let categoryName = selectedCategory,
                       let category = viewModel.allCategories.first(where: { $0.name == categoryName }) {
                        // Show icon and color if category is selected
                        Image(systemName: category.iconName ?? "tag.fill")
                            .font(.system(size: 18))
                            .foregroundColor(categoryColor(category))
                            .frame(width: 32, height: 32)
                            .background(
                                Circle()
                                    .fill(categoryColor(category).opacity(0.2))
                            )
                        
                        Text(categoryName)
                            .foregroundColor(.primary)
                    } else {
                        Text("None")
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                        .font(.system(size: 14, weight: .semibold))
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color(UIColor.secondarySystemBackground))
                )
            }
        }
    }
    
    private func categoryColor(_ category: PermissionCategory) -> Color {
        if let colorHex = category.colorHex {
            return Color(hex: colorHex)
        }
        return Color.appSkyBlue
    }
    
    private var tagsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Emotional Tags")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
            
            Button(action: {
                showingTagPicker = true
            }) {
                HStack(spacing: 12) {
                    if selectedTags.isEmpty {
                        Text("Add tags")
                            .foregroundColor(.secondary)
                    } else {
                        // Show selected tags with colors
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(Array(selectedTags), id: \.self) { tagName in
                                    if let tag = viewModel.allTags.first(where: { $0.name == tagName }) {
                                        HStack(spacing: 6) {
                                            Circle()
                                                .fill(tagColor(tag))
                                                .frame(width: 8, height: 8)
                                            Text(tagName)
                                                .font(.system(size: 14))
                                                .foregroundColor(.primary)
                                        }
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(tagColor(tag).opacity(0.15))
                                        )
                                    }
                                }
                            }
                        }
                    }
                    
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                        .font(.system(size: 14, weight: .semibold))
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color(UIColor.secondarySystemBackground))
                )
            }
        }
    }
    
    private func tagColor(_ tag: PermissionTag) -> Color {
        if let colorHex = tag.colorHex {
            return Color(hex: colorHex)
        }
        return Color.appGentleLavender
    }
    
    private var expectedImpactSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Expected Impact")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
            
            TextField("What do you hope this permission will bring?", text: $expectedImpact, axis: .vertical)
                .textFieldStyle(.plain)
                .font(.system(size: 16))
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color(UIColor.secondarySystemBackground))
                )
                .lineLimit(3...6)
        }
    }
    
    private var outcomeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Actual Outcome")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
            
            TextField("How did this permission feel?", text: $actualOutcome, axis: .vertical)
                .textFieldStyle(.plain)
                .font(.system(size: 16))
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color(UIColor.secondarySystemBackground))
                )
                .lineLimit(3...6)
        }
    }
    
    private var emotionalImpactSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Emotional Impact (1-10)")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
            
            HStack {
                Text("1")
                    .foregroundColor(.secondary)
                Slider(value: Binding(
                    get: { Double(emotionalImpact) },
                    set: { emotionalImpact = Int16($0) }
                ), in: 0...10, step: 1)
                Text("10")
                    .foregroundColor(.secondary)
                
                Text("\(emotionalImpact)")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.appSkyBlue)
                    .frame(width: 30)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.white.opacity(0.8))
            )
        }
    }
    
    private func savePermission() {
        // Validation: statement is required
        guard !statement.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        
        if let permission = permission {
            permission.statement = statement.trimmingCharacters(in: .whitespaces)
            permission.date = selectedDate
            permission.category = selectedCategory
            permission.emotionalTags = Array(selectedTags)
            permission.expectedImpact = expectedImpact.isEmpty ? nil : expectedImpact.trimmingCharacters(in: .whitespaces)
            permission.actualOutcome = actualOutcome.isEmpty ? nil : actualOutcome.trimmingCharacters(in: .whitespaces)
            permission.emotionalImpact = emotionalImpact
            viewModel.updatePermission(permission)
        } else {
            viewModel.createPermission(
                statement: statement.trimmingCharacters(in: .whitespaces),
                date: selectedDate,
                category: selectedCategory,
                emotionalTags: Array(selectedTags),
                expectedImpact: expectedImpact.isEmpty ? nil : expectedImpact.trimmingCharacters(in: .whitespaces),
                actualOutcome: actualOutcome.isEmpty ? nil : actualOutcome.trimmingCharacters(in: .whitespaces),
                emotionalImpact: emotionalImpact
            )
        }
    }
}

struct CategoryPickerView: View {
    @Binding var selectedCategory: String?
    @State var categories: [PermissionCategory]
    var viewModel: PermissionViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            if categories.isEmpty {
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
                            .frame(width: 100, height: 100)
                        
                        Image(systemName: "tag.fill")
                            .font(.system(size: 48))
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
                            .font(.custom("Georgia", size: 24))
                            .foregroundColor(.primary)
                        
                        Text("Create your first category to organize permissions")
                            .font(.system(size: 15, design: .rounded))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    
                    NavigationLink(destination: AddCategoryView(viewModel: viewModel, onDismiss: {
                        updateCategories()
                    })) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 18))
                            Text("Create Category")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(
                                colors: [Color.appSkyBlue, Color.appGentleLavender],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(20)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .navigationTitle("Select Category")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }
            } else {
                List {
                    Button(action: {
                        selectedCategory = nil
                        dismiss()
                    }) {
                        HStack {
                            Text("None")
                            Spacer()
                            if selectedCategory == nil {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                    
                    ForEach(categories) { category in
                        HStack(spacing: 12) {
                            // Icon and color
                            Image(systemName: category.iconName ?? "tag.fill")
                                .font(.system(size: 20))
                                .foregroundColor(categoryColor(category))
                                .frame(width: 36, height: 36)
                                .background(
                                    Circle()
                                        .fill(categoryColor(category).opacity(0.2))
                                )
                            
                            Button(action: {
                                selectedCategory = category.name
                                dismiss()
                            }) {
                                HStack {
                                    Text(category.name)
                                        .foregroundColor(.primary)
                                    Spacer()
                                    if selectedCategory == category.name {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.appSkyBlue)
                                    }
                                }
                            }
                            
                            Button(action: {
                                deleteCategory(category)
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .navigationTitle("Select Category")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: AddCategoryView(viewModel: viewModel) {
                        updateCategories()
                    }) {
                        Image(systemName: "plus")
                    }
                    }
                }
            }
        }
        .onAppear {
            updateCategories()
        }
    }
    
    private func updateCategories() {
        categories = viewModel.allCategories
    }
    
    private func deleteCategory(_ category: PermissionCategory) {
        viewModel.deleteCategory(category)
        updateCategories()
        if selectedCategory == category.name {
            selectedCategory = nil
        }
    }
    
    private func categoryColor(_ category: PermissionCategory) -> Color {
        if let colorHex = category.colorHex {
            return Color(hex: colorHex)
        }
        return Color.appSkyBlue
    }
}

struct TagPickerView: View {
    @Binding var selectedTags: Set<String>
    @State var tags: [PermissionTag]
    var viewModel: PermissionViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            if tags.isEmpty {
                VStack(spacing: 24) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.appSoftGold.opacity(0.2), Color.appGentleLavender.opacity(0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 100, height: 100)
                        
                        Image(systemName: "heart.text.square.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.appSoftGold, Color.appGentleLavender],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    
                    VStack(spacing: 12) {
                        Text("No Tags Yet")
                            .font(.custom("Georgia", size: 24))
                            .foregroundColor(.primary)
                        
                        Text("Create emotional tags to describe how your permissions make you feel")
                            .font(.system(size: 15, design: .rounded))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    
                    NavigationLink(destination: AddTagView(viewModel: viewModel, onDismiss: {
                        updateTags()
                    })) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 18))
                            Text("Create Tag")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(
                                colors: [Color.appSoftGold, Color.appGentleLavender],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(20)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .navigationTitle("Select Tags")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }
            } else {
                List {
                    ForEach(tags) { tag in
                        HStack(spacing: 12) {
                            // Color indicator
                            Circle()
                                .fill(tagColor(tag))
                                .frame(width: 20, height: 20)
                                .overlay(
                                    Circle()
                                        .stroke(Color.primary.opacity(0.1), lineWidth: 1)
                                )
                            
                            Button(action: {
                                if selectedTags.contains(tag.name) {
                                    selectedTags.remove(tag.name)
                                } else {
                                    selectedTags.insert(tag.name)
                                }
                            }) {
                                HStack {
                                    Text(tag.name)
                                        .foregroundColor(.primary)
                                    Spacer()
                                    if selectedTags.contains(tag.name) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.appSkyBlue)
                                    }
                                }
                            }
                            
                            Button(action: {
                                deleteTag(tag)
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .navigationTitle("Select Tags")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: AddTagView(viewModel: viewModel, onDismiss: {
                        updateTags()
                    })) {
                        Image(systemName: "plus")
                    }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
            }
        }
        .onAppear {
            updateTags()
        }
    }
    
    private func updateTags() {
        tags = viewModel.allTags
    }
    
    private func deleteTag(_ tag: PermissionTag) {
        viewModel.deleteTag(tag)
        updateTags()
        selectedTags.remove(tag.name)
    }
    
    private func tagColor(_ tag: PermissionTag) -> Color {
        if let colorHex = tag.colorHex {
            return Color(hex: colorHex)
        }
        return Color.appGentleLavender
    }
}

struct AddTagView: View {
    var viewModel: PermissionViewModel
    var onDismiss: (() -> Void)?
    @Environment(\.dismiss) var dismiss
    
    @State private var name: String = ""
    @State private var selectedColor: Color = .appGentleLavender
    
    let availableColors: [Color] = [.appSkyBlue, .appSoftGold, .appGentleLavender, .red, .green, .orange, .purple]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                TextField("Tag name", text: $name)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(size: 18))
                
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
                    viewModel.createTag(
                        name: name.trimmingCharacters(in: .whitespaces),
                        colorHex: selectedColor.toHex(),
                        iconName: nil
                    )
                    onDismiss?()
                    dismiss()
                }) {
                    Text("Create Tag")
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
        .navigationTitle("New Tag")
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

#Preview {
    PermissionFormView(permission: nil, viewModel: PermissionViewModel(context: PersistenceController.shared.container.viewContext))
}
