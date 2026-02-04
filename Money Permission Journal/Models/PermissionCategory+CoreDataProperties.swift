//
//  PermissionCategory+CoreDataProperties.swift
//  Money Permission Journal
//
//  Created on 2025.
//

import Foundation
import CoreData

extension PermissionCategory {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<PermissionCategory> {
        return NSFetchRequest<PermissionCategory>(entityName: "PermissionCategory")
    }
    
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var iconName: String?
    @NSManaged public var colorHex: String?
    @NSManaged public var order: Int16
}

extension PermissionCategory : Identifiable {
    
}
