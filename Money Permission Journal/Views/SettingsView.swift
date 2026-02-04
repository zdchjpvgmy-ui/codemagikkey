//
//  SettingsView.swift
//  Money Permission Journal
//
//  Created on 2025.
//

import SwiftUI
import CoreData
import UIKit

struct SettingsView: View {
    @Environment(ThemeManager.self) private var themeManager
    @State private var reminderEnabled = UserDefaults.standard.bool(forKey: UserDefaultsKeys.permissionReminderEnabled)
    @State private var reminderFrequency = UserDefaults.standard.string(forKey: UserDefaultsKeys.reminderFrequency) ?? "daily"
    @State private var showingResetConfirmation = false
    @State private var resetConfirmations = 0
    @State private var showingBackupShare = false
    @State private var backupURL: URL?
    
    var body: some View {
        NavigationStack {
            List {
                themeSection
                reminderSection
                dataSection
                aboutSection
            }
            .scrollContentBackground(.hidden)
            .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .alert("Reset All Data", isPresented: $showingResetConfirmation) {
                Button("Cancel", role: .cancel) {
                    resetConfirmations = 0
                }
                Button("Reset", role: .destructive) {
                    resetConfirmations += 1
                    if resetConfirmations >= 3 {
                        resetAllData()
                        resetConfirmations = 0
                    } else {
                        showingResetConfirmation = true
                    }
                }
            } message: {
                Text("This will delete all your permissions. This action cannot be undone. Confirm \(resetConfirmations + 1) of 3 times.")
            }
            .sheet(isPresented: $showingBackupShare) {
                if let url = backupURL {
                    ShareSheet(items: [url])
                }
            }
        }
    }
    
    private var themeSection: some View {
        Section {
            Picker("Theme", selection: Bindable(themeManager).currentTheme) {
                ForEach(AppTheme.allCases, id: \.self) { theme in
                    Text(theme.rawValue.capitalized).tag(theme)
                }
            }
        } header: {
            Text("Appearance")
        }
    }
    
    private var reminderSection: some View {
        Section {
            Toggle("Permission Reminders", isOn: $reminderEnabled)
                .onChange(of: reminderEnabled) { _, newValue in
                    UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.permissionReminderEnabled)
                }
            
            if reminderEnabled {
                Picker("Frequency", selection: $reminderFrequency) {
                    Text("Daily").tag("daily")
                    Text("Weekly").tag("weekly")
                }
                .onChange(of: reminderFrequency) { _, newValue in
                    UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.reminderFrequency)
                }
            }
        } header: {
            Text("Notifications")
        }
    }
    
    private var dataSection: some View {
        Section {
            Button(action: {
                exportBackup()
            }) {
                HStack {
                    Text("Backup Data")
                    Spacer()
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(.secondary)
                }
            }
            
            Button(action: {
                showingResetConfirmation = true
            }) {
                HStack {
                    Text("Reset All Data")
                        .foregroundColor(.red)
                    Spacer()
                }
            }
        } header: {
            Text("Data Management")
        }
    }
    
    private var aboutSection: some View {
        Section {
            Text("This is a private personal permission journal. Not financial advice or psychological therapy.")
                .font(.system(size: 11))
                .foregroundColor(.secondary)
        } header: {
            Text("About")
        }
    }
    
    private func exportBackup() {
        let viewModel = PermissionViewModel(context: PersistenceController.shared.container.viewContext)
        let permissions = viewModel.allPermissions
        let categories = viewModel.allCategories
        let tags = viewModel.allTags
        
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        var backupData: [String: Any] = [:]
        backupData["version"] = "1.0"
        backupData["exportDate"] = dateFormatter.string(from: Date())
        
        // Export permissions
        backupData["permissions"] = permissions.map { permission in
            [
                "id": permission.id.uuidString,
                "statement": permission.statement,
                "date": dateFormatter.string(from: permission.date),
                "category": permission.category ?? "",
                "emotionalTags": permission.emotionalTags,
                "expectedImpact": permission.expectedImpact ?? "",
                "actualOutcome": permission.actualOutcome ?? "",
                "emotionalImpact": permission.emotionalImpact,
                "createdAt": dateFormatter.string(from: permission.createdAt),
                "updatedAt": dateFormatter.string(from: permission.updatedAt)
            ]
        }
        
        // Export categories
        backupData["categories"] = categories.map { category in
            [
                "id": category.id.uuidString,
                "name": category.name,
                "iconName": category.iconName ?? "",
                "colorHex": category.colorHex ?? "",
                "order": category.order
            ]
        }
        
        // Export tags
        backupData["tags"] = tags.map { tag in
            [
                "id": tag.id.uuidString,
                "name": tag.name,
                "colorHex": tag.colorHex ?? "",
                "iconName": tag.iconName ?? ""
            ]
        }
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: backupData, options: [.prettyPrinted, .sortedKeys])
            let fileName = "MoneyPermissionsBackup_\(dateFormatter.string(from: Date()).prefix(10)).json"
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
            
            try jsonData.write(to: tempURL)
            
            backupURL = tempURL
            showingBackupShare = true
        } catch {
            #if DEBUG
            print("❌ ERROR: Failed to create backup: \(error.localizedDescription)")
            #endif
        }
    }
    
    private func resetAllData() {
        let context = PersistenceController.shared.container.viewContext
        let fetchRequest1: NSFetchRequest<NSFetchRequestResult> = MoneyPermission.fetchRequest()
        let deleteRequest1 = NSBatchDeleteRequest(fetchRequest: fetchRequest1)
        
        let fetchRequest2: NSFetchRequest<NSFetchRequestResult> = PermissionCategory.fetchRequest()
        let deleteRequest2 = NSBatchDeleteRequest(fetchRequest: fetchRequest2)
        
        let fetchRequest3: NSFetchRequest<NSFetchRequestResult> = PermissionTag.fetchRequest()
        let deleteRequest3 = NSBatchDeleteRequest(fetchRequest: fetchRequest3)
        
        _ = try? context.execute(deleteRequest1)
        _ = try? context.execute(deleteRequest2)
        _ = try? context.execute(deleteRequest3)
        
        PersistenceController.shared.save()
    }
}

#Preview {
    SettingsView()
}
