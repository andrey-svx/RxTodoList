//
//  CDTodo+CoreDataProperties.swift
//  RxTodoList
//
//  Created by Андрей Исаев on 12.01.2021.
//
//

import Foundation
import CoreData


extension CDTodo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDTodo> {
        return NSFetchRequest<CDTodo>(entityName: "CDTodo")
    }

    @NSManaged public var date: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var name: String?

}

extension CDTodo : Identifiable {

}
