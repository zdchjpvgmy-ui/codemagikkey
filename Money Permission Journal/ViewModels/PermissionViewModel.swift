//
//  PermissionViewModel.swift
//  Money Permission Journal
//
//  Created on 2025.
//

import Foundation
import CoreData
import SwiftUI

@Observable
class PermissionViewModel {
    private var _refreshTrigger = UUID()
    
    var refreshTrigger: UUID {
        _refreshTrigger
    }
    
    private var context: NSManagedObjectContext {
        PersistenceController.shared.container.viewContext
    }
    
    init(context: NSManagedObjectContext) {
        // Context is always accessed via computed property
    }
    
    func refresh() {
        _refreshTrigger = UUID()
    }
    
    var allPermissions: [MoneyPermission] {
        guard PersistenceController.shared.isContextReady else {
            #if DEBUG
            print("⚠️ WARNING: Context not ready when fetching permissions")
            #endif
            return []
        }
        
        let request: NSFetchRequest<MoneyPermission> = MoneyPermission.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \MoneyPermission.date, ascending: false)]
        
        do {
            return try context.fetch(request)
        } catch {
            #if DEBUG
            let nsError = error as NSError
            print("❌ ERROR: Failed to fetch permissions: \(nsError.localizedDescription)")
            #endif
            return []
        }
    }
    
    var allCategories: [PermissionCategory] {
        guard PersistenceController.shared.isContextReady else {
            #if DEBUG
            print("⚠️ WARNING: Context not ready when fetching categories")
            #endif
            return []
        }
        
        let request: NSFetchRequest<PermissionCategory> = PermissionCategory.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \PermissionCategory.order, ascending: true)]
        
        do {
            return try context.fetch(request)
        } catch {
            #if DEBUG
            let nsError = error as NSError
            print("❌ ERROR: Failed to fetch categories: \(nsError.localizedDescription)")
            #endif
            return []
        }
    }
    
    var allTags: [PermissionTag] {
        guard PersistenceController.shared.isContextReady else {
            #if DEBUG
            print("⚠️ WARNING: Context not ready when fetching tags")
            #endif
            return []
        }
        
        let request: NSFetchRequest<PermissionTag> = PermissionTag.fetchRequest()
        
        do {
            return try context.fetch(request)
        } catch {
            #if DEBUG
            let nsError = error as NSError
            print("❌ ERROR: Failed to fetch tags: \(nsError.localizedDescription)")
            #endif
            return []
        }
    }
    
    func createPermission(
        statement: String,
        date: Date,
        category: String?,
        emotionalTags: [String],
        expectedImpact: String?,
        actualOutcome: String? = nil,
        emotionalImpact: Int16 = 0
    ) {
        let container = PersistenceController.shared.container
        let context = container.viewContext
        
        guard PersistenceController.shared.isContextReady else {
            #if DEBUG
            print("❌ ERROR: Core Data context is not ready when creating permission")
            #endif
            return
        }
        
        // Try to find entity in model
        let model = container.managedObjectModel
        guard let entityDescription = model.entitiesByName["MoneyPermission"] else {
            #if DEBUG
            print("❌ ERROR: MoneyPermission entity not found in model!")
            print("   Available entities: \(model.entitiesByName.keys.joined(separator: ", "))")
            #endif
            return
        }
        
        let permission = MoneyPermission(entity: entityDescription, insertInto: context)
        permission.id = UUID()
        permission.statement = statement
        permission.date = date
        permission.category = category
        permission.emotionalTags = emotionalTags
        permission.expectedImpact = expectedImpact
        permission.actualOutcome = actualOutcome
        permission.emotionalImpact = emotionalImpact
        permission.createdAt = Date()
        permission.updatedAt = Date()
        
        PersistenceController.shared.save()
        refresh()
    }
    
    func updatePermission(_ permission: MoneyPermission) {
        permission.updatedAt = Date()
        PersistenceController.shared.save()
        refresh()
    }
    
    func deletePermission(_ permission: MoneyPermission) {
        guard PersistenceController.shared.isContextReady else {
            #if DEBUG
            print("⚠️ WARNING: Context not ready when deleting permission")
            #endif
            return
        }
        
        context.delete(permission)
        PersistenceController.shared.save()
        refresh()
    }
    
    func createCategory(name: String, iconName: String?, colorHex: String?) {
        // Ensure context is ready
        guard PersistenceController.shared.isContextReady else {
            #if DEBUG
            print("❌ ERROR: Core Data context is not ready when creating category")
            #endif
            return
        }
        
        let container = PersistenceController.shared.container
        let context = container.viewContext
        
        // Try to find entity in model
        let model = container.managedObjectModel
        guard let entityDescription = model.entitiesByName["PermissionCategory"] else {
            #if DEBUG
            print("❌ ERROR: PermissionCategory entity not found in model!")
            print("   Available entities: \(model.entitiesByName.keys.joined(separator: ", "))")
            #endif
            return
        }
        
        // Create object using the entity description directly
        let category = PermissionCategory(entity: entityDescription, insertInto: context)
        category.id = UUID()
        category.name = name
        category.iconName = iconName
        category.colorHex = colorHex
        category.order = Int16(allCategories.count)
        
        PersistenceController.shared.save()
        refresh()
    }
    
    func createTag(name: String, colorHex: String?, iconName: String?) {
        // Ensure context is ready
        guard PersistenceController.shared.isContextReady else {
            #if DEBUG
            print("❌ ERROR: Core Data context is not ready when creating tag")
            #endif
            return
        }
        
        let container = PersistenceController.shared.container
        let context = container.viewContext
        
        // Try to find entity in model
        let model = container.managedObjectModel
        guard let entityDescription = model.entitiesByName["PermissionTag"] else {
            #if DEBUG
            print("❌ ERROR: PermissionTag entity not found in model!")
            print("   Available entities: \(model.entitiesByName.keys.joined(separator: ", "))")
            #endif
            return
        }
        
        // Create object using the entity description directly
        let tag = PermissionTag(entity: entityDescription, insertInto: context)
        tag.id = UUID()
        tag.name = name
        tag.colorHex = colorHex
        tag.iconName = iconName
        
        PersistenceController.shared.save()
        refresh()
    }
    
    func deleteCategory(_ category: PermissionCategory) {
        guard PersistenceController.shared.isContextReady else {
            #if DEBUG
            print("⚠️ WARNING: Context not ready when deleting category")
            #endif
            return
        }
        
        let context = PersistenceController.shared.container.viewContext
        context.delete(category)
        PersistenceController.shared.save()
        refresh()
    }
    
    func deleteTag(_ tag: PermissionTag) {
        guard PersistenceController.shared.isContextReady else {
            #if DEBUG
            print("⚠️ WARNING: Context not ready when deleting tag")
            #endif
            return
        }
        
        let context = PersistenceController.shared.container.viewContext
        context.delete(tag)
        PersistenceController.shared.save()
        refresh()
    }
    
    func permissions(for category: String?) -> [MoneyPermission] {
        guard let category = category else { return allPermissions }
        return allPermissions.filter { $0.category == category }
    }
    
    func permissionsWithOutcome() -> [MoneyPermission] {
        return allPermissions.filter { $0.actualOutcome != nil && !$0.actualOutcome!.isEmpty }
    }
    
    func highImpactPermissions() -> [MoneyPermission] {
        return allPermissions.filter { $0.emotionalImpact >= 8 }
    }
    
    func permissionCount() -> Int {
        return allPermissions.count
    }
    
    func longestStreak() -> Int {
        let sorted = allPermissions.sorted { $0.date > $1.date }
        guard !sorted.isEmpty else { return 0 }
        
        var streak = 1
        var currentDate = Calendar.current.startOfDay(for: sorted[0].date)
        
        for permission in sorted.dropFirst() {
            let permissionDate = Calendar.current.startOfDay(for: permission.date)
            let daysDifference = Calendar.current.dateComponents([.day], from: permissionDate, to: currentDate).day ?? 0
            
            if daysDifference == 1 {
                streak += 1
                currentDate = permissionDate
            } else if daysDifference > 1 {
                break
            }
        }
        
        return streak
    }
    
    func mostCommonTag() -> String? {
        let allTags = allPermissions.flatMap { $0.emotionalTags }
        let tagCounts = Dictionary(grouping: allTags, by: { $0 })
            .mapValues { $0.count }
        
        return tagCounts.max(by: { $0.value < $1.value })?.key
    }
}
