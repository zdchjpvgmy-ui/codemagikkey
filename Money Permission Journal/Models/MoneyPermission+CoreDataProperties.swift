//
//  MoneyPermission+CoreDataProperties.swift
//  Money Permission Journal
//
//  Created on 2025.
//

import Foundation
import CoreData

extension MoneyPermission {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<MoneyPermission> {
        return NSFetchRequest<MoneyPermission>(entityName: "MoneyPermission")
    }
    
    @NSManaged public var id: UUID
    @NSManaged public var statement: String
    @NSManaged public var date: Date
    @NSManaged public var category: String?
    @NSManaged public var emotionalTags: [String]
    @NSManaged public var expectedImpact: String?
    @NSManaged public var actualOutcome: String?
    @NSManaged public var emotionalImpact: Int16
    @NSManaged public var createdAt: Date
    @NSManaged public var updatedAt: Date
}

extension MoneyPermission : Identifiable {
    
}
