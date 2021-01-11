//
//  Todo+CoreDataProperties.swift
//  RxTodoList
//
//  Created by Андрей Исаев on 11.01.2021.
//
//

import Foundation
import CoreData


extension Todo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Todo> {
        return NSFetchRequest<Todo>(entityName: "Todo")
    }

    @NSManaged public var name: String
    @NSManaged public var id: UUID
    @NSManaged public var date: Date

}

extension Todo : Identifiable { }
