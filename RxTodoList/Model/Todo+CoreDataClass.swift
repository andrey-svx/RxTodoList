//
//  Todo+CoreDataClass.swift
//  RxTodoList
//
//  Created by Андрей Исаев on 11.01.2021.
//
//

import Foundation
import CoreData

@objc(Todo)
public class Todo: NSManagedObject {
    
    func update(_ name: String) {
        self.name = name
    }
    
}
