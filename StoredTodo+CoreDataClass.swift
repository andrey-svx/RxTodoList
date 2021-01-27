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
public class StoredTodo: NSManagedObject {
    
    convenience init(context: NSManagedObjectContext, id: UUID, date: Date, name: String) {
        
        self.init(context: context)
        self.id = id
        self.date = date
        self.name = name
    
    }

}
