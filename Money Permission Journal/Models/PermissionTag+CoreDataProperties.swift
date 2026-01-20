//
//  PermissionTag+CoreDataProperties.swift
//  Money Permission Journal
//
//  Created on 2025.
//

import Foundation
import CoreData

extension PermissionTag {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<PermissionTag> {
        return NSFetchRequest<PermissionTag>(entityName: "PermissionTag")
    }
    
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var colorHex: String?
    @NSManaged public var iconName: String?
}

extension PermissionTag : Identifiable {
    
}
