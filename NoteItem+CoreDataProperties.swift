//
//  NoteItem+CoreDataProperties.swift
//  Notes
//
//  Created by Anna Shuryaeva on 12.02.2023.
//
//

import Foundation
import CoreData


extension NoteItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NoteItem> {
        return NSFetchRequest<NoteItem>(entityName: "NoteItem")
    }

    @NSManaged public var date: Date?
    @NSManaged public var title: String?
    @NSManaged public var details: String?

}

extension NoteItem : Identifiable {

}
