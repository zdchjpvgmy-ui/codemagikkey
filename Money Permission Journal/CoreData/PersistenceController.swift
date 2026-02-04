//
//  PersistenceController.swift
//  Money Permission Journal
//
//  Created on 2025.
//

import CoreData
import Foundation

class PersistenceController {
    static let shared = PersistenceController()
    
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        return controller
    }()
    
    let container: NSPersistentContainer
    private var isLoaded = false
    private var initializationError: Error?
    
    init(inMemory: Bool = false) {
        // Try to load existing model, or create programmatically
        let model: NSManagedObjectModel
        
        if let modelURL = Bundle.main.url(forResource: "MoneyPermissionJournal", withExtension: "momd"),
           let existingModel = NSManagedObjectModel(contentsOf: modelURL) {
            model = existingModel
            #if DEBUG
            print("✅ Loaded existing Core Data model from bundle")
            #endif
        } else {
            // Create model programmatically
            #if DEBUG
            print("⚠️ Model file not found, creating programmatically...")
            #endif
            model = PersistenceController.createManagedObjectModel()
        }
        
        container = NSPersistentContainer(name: "MoneyPermissionJournal", managedObjectModel: model)
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        // Configure persistent store descriptions
        let description = container.persistentStoreDescriptions.first
        description?.shouldMigrateStoreAutomatically = true
        description?.shouldInferMappingModelAutomatically = true
        
        // Load synchronously to ensure context is ready
        let semaphore = DispatchSemaphore(value: 0)
        
        container.loadPersistentStores { description, error in
            if let error = error {
                self.initializationError = error
                
                #if DEBUG
                print("❌ Core Data failed to load: \(error.localizedDescription)")
                if let underlyingError = (error as NSError).userInfo[NSUnderlyingErrorKey] as? NSError {
                    print("   Underlying error: \(underlyingError.localizedDescription)")
                }
                #endif
                
                // Try to recover by deleting and recreating the store
                self.recoverFromStoreError(error: error, description: description)
                semaphore.signal()
                return
            }
            
            // Verify entities are loaded
            let entities = self.container.managedObjectModel.entitiesByName
            #if DEBUG
            print("✅ Core Data loaded successfully. Entities: \(entities.keys.joined(separator: ", "))")
            #endif
            
            #if DEBUG
            if entities["MoneyPermission"] == nil {
                print("⚠️ WARNING: MoneyPermission entity not found in model")
            }
            if entities["PermissionCategory"] == nil {
                print("⚠️ WARNING: PermissionCategory entity not found in model")
            }
            if entities["PermissionTag"] == nil {
                print("⚠️ WARNING: PermissionTag entity not found in model")
            }
            #endif
            
            self.isLoaded = true
            semaphore.signal()
        }
        
        // Wait for stores to load (with timeout)
        let result = semaphore.wait(timeout: .now() + 10)
        if result == .timedOut {
            #if DEBUG
            print("⚠️ WARNING: Core Data store loading timed out")
            #endif
            initializationError = NSError(domain: "PersistenceController", code: -1, userInfo: [NSLocalizedDescriptionKey: "Store loading timed out"])
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        // Verify context is ready
        if container.viewContext.persistentStoreCoordinator == nil {
            #if DEBUG
            print("❌ ERROR: Context persistentStoreCoordinator is nil after loading!")
            #endif
            if initializationError == nil {
                initializationError = NSError(domain: "PersistenceController", code: -2, userInfo: [NSLocalizedDescriptionKey: "Context coordinator is nil"])
            }
        } else {
            #if DEBUG
            print("✅ Context is ready with coordinator")
            #endif
        }
    }
    
    var isContextReady: Bool {
        return isLoaded && container.viewContext.persistentStoreCoordinator != nil && initializationError == nil
    }
    
    var hasError: Bool {
        return initializationError != nil
    }
    
    func getInitializationError() -> Error? {
        return initializationError
    }
    
    func save() {
        guard isContextReady else {
            #if DEBUG
            print("⚠️ WARNING: Attempted to save when context is not ready")
            #endif
            return
        }
        
        let context = container.viewContext
        
        guard context.hasChanges else {
            return
        }
        
        do {
            try context.save()
        } catch {
            #if DEBUG
            let nsError = error as NSError
            print("❌ ERROR: Failed to save context: \(nsError.localizedDescription)")
            print("   User info: \(nsError.userInfo)")
            #endif
            
            // Try to rollback changes
            context.rollback()
        }
    }
    
    private func recoverFromStoreError(error: Error, description: NSPersistentStoreDescription?) {
        #if DEBUG
        print("🔄 Attempting to recover from Core Data store error...")
        #endif
        
        // For production, we should attempt to recover by migrating or recreating
        // For now, we'll mark as not loaded and let the app continue with in-memory if possible
        guard let storeURL = description?.url else {
            isLoaded = false
            return
        }
        
        // Try to delete corrupted store and create new one
        do {
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: storeURL.path) {
                try fileManager.removeItem(at: storeURL)
                #if DEBUG
                print("🗑️ Removed corrupted store file")
                #endif
            }
            
            // Try to reload
            let coordinator = container.persistentStoreCoordinator
            let model = coordinator.managedObjectModel
            _ = try coordinator.addPersistentStore(
                ofType: NSSQLiteStoreType,
                configurationName: nil,
                at: storeURL,
                options: nil
            )
            isLoaded = true
            initializationError = nil
            #if DEBUG
            print("✅ Successfully recovered from store error")
            #endif
        } catch {
            #if DEBUG
            print("❌ Failed to recover: \(error.localizedDescription)")
            #endif
            isLoaded = false
            initializationError = error
        }
    }
    
    private static func createManagedObjectModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()
        
        // MoneyPermission entity
        let moneyPermissionEntity = NSEntityDescription()
        moneyPermissionEntity.name = "MoneyPermission"
        moneyPermissionEntity.managedObjectClassName = "MoneyPermission"
        
        var props: [NSAttributeDescription] = []
        
        let idAttr = NSAttributeDescription()
        idAttr.name = "id"
        idAttr.attributeType = .UUIDAttributeType
        idAttr.isOptional = false
        props.append(idAttr)
        
        let statementAttr = NSAttributeDescription()
        statementAttr.name = "statement"
        statementAttr.attributeType = .stringAttributeType
        statementAttr.isOptional = false
        props.append(statementAttr)
        
        let dateAttr = NSAttributeDescription()
        dateAttr.name = "date"
        dateAttr.attributeType = .dateAttributeType
        dateAttr.isOptional = false
        props.append(dateAttr)
        
        let categoryAttr = NSAttributeDescription()
        categoryAttr.name = "category"
        categoryAttr.attributeType = .stringAttributeType
        categoryAttr.isOptional = true
        props.append(categoryAttr)
        
        let tagsAttr = NSAttributeDescription()
        tagsAttr.name = "emotionalTags"
        tagsAttr.attributeType = .transformableAttributeType
        tagsAttr.isOptional = true
        tagsAttr.valueTransformerName = "NSSecureUnarchiveFromDataTransformer"
        tagsAttr.attributeValueClassName = "[String]"
        props.append(tagsAttr)
        
        let expectedImpactAttr = NSAttributeDescription()
        expectedImpactAttr.name = "expectedImpact"
        expectedImpactAttr.attributeType = .stringAttributeType
        expectedImpactAttr.isOptional = true
        props.append(expectedImpactAttr)
        
        let actualOutcomeAttr = NSAttributeDescription()
        actualOutcomeAttr.name = "actualOutcome"
        actualOutcomeAttr.attributeType = .stringAttributeType
        actualOutcomeAttr.isOptional = true
        props.append(actualOutcomeAttr)
        
        let impactAttr = NSAttributeDescription()
        impactAttr.name = "emotionalImpact"
        impactAttr.attributeType = .integer16AttributeType
        impactAttr.isOptional = false
        impactAttr.defaultValue = 0
        props.append(impactAttr)
        
        let createdAtAttr = NSAttributeDescription()
        createdAtAttr.name = "createdAt"
        createdAtAttr.attributeType = .dateAttributeType
        createdAtAttr.isOptional = false
        props.append(createdAtAttr)
        
        let updatedAtAttr = NSAttributeDescription()
        updatedAtAttr.name = "updatedAt"
        updatedAtAttr.attributeType = .dateAttributeType
        updatedAtAttr.isOptional = false
        props.append(updatedAtAttr)
        
        moneyPermissionEntity.properties = props
        
        // PermissionCategory entity
        let categoryEntity = NSEntityDescription()
        categoryEntity.name = "PermissionCategory"
        categoryEntity.managedObjectClassName = "PermissionCategory"
        
        var categoryProps: [NSAttributeDescription] = []
        
        let catIdAttr = NSAttributeDescription()
        catIdAttr.name = "id"
        catIdAttr.attributeType = .UUIDAttributeType
        catIdAttr.isOptional = false
        categoryProps.append(catIdAttr)
        
        let nameAttr = NSAttributeDescription()
        nameAttr.name = "name"
        nameAttr.attributeType = .stringAttributeType
        nameAttr.isOptional = false
        categoryProps.append(nameAttr)
        
        let iconNameAttr = NSAttributeDescription()
        iconNameAttr.name = "iconName"
        iconNameAttr.attributeType = .stringAttributeType
        iconNameAttr.isOptional = true
        categoryProps.append(iconNameAttr)
        
        let colorHexAttr = NSAttributeDescription()
        colorHexAttr.name = "colorHex"
        colorHexAttr.attributeType = .stringAttributeType
        colorHexAttr.isOptional = true
        categoryProps.append(colorHexAttr)
        
        let orderAttr = NSAttributeDescription()
        orderAttr.name = "order"
        orderAttr.attributeType = .integer16AttributeType
        orderAttr.isOptional = false
        orderAttr.defaultValue = 0
        categoryProps.append(orderAttr)
        
        categoryEntity.properties = categoryProps
        
        // PermissionTag entity
        let tagEntity = NSEntityDescription()
        tagEntity.name = "PermissionTag"
        tagEntity.managedObjectClassName = "PermissionTag"
        
        var tagProps: [NSAttributeDescription] = []
        
        let tagIdAttr = NSAttributeDescription()
        tagIdAttr.name = "id"
        tagIdAttr.attributeType = .UUIDAttributeType
        tagIdAttr.isOptional = false
        tagProps.append(tagIdAttr)
        
        let tagNameAttr = NSAttributeDescription()
        tagNameAttr.name = "name"
        tagNameAttr.attributeType = .stringAttributeType
        tagNameAttr.isOptional = false
        tagProps.append(tagNameAttr)
        
        let tagColorHexAttr = NSAttributeDescription()
        tagColorHexAttr.name = "colorHex"
        tagColorHexAttr.attributeType = .stringAttributeType
        tagColorHexAttr.isOptional = true
        tagProps.append(tagColorHexAttr)
        
        let tagIconNameAttr = NSAttributeDescription()
        tagIconNameAttr.name = "iconName"
        tagIconNameAttr.attributeType = .stringAttributeType
        tagIconNameAttr.isOptional = true
        tagProps.append(tagIconNameAttr)
        
        tagEntity.properties = tagProps
        
        model.entities = [moneyPermissionEntity, categoryEntity, tagEntity]
        
        #if DEBUG
        print("✅ Created Core Data model programmatically with \(model.entities.count) entities")
        #endif
        return model
    }
}

