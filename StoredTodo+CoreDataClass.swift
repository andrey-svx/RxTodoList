//
//  StoredTodo+CoreDataClass.swift
//  RxTodoList
//
//  Created by Андрей Исаев on 27.01.2021.
//
//

import Foundation
import CoreData

@objc(StoredTodo)
final public class StoredTodo: NSManagedObject, Todo {
    
    convenience init(context: NSManagedObjectContext, id: UUID, date: Date, name: String) {
        
        self.init(context: context)
        self.id = id
        self.date = date
        self.name = name
    
    }
    
    convenience init(context: NSManagedObjectContext, localTodo: LocalTodo) {
        
        self.init(
            context: context,
            id: localTodo.id,
            date: localTodo.date,
            name: localTodo.name
        )
    
    }

}
