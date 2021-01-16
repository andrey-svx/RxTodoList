import Foundation
import CoreData

struct LocalTodo: Todo {
    
    private(set) var name: String
    
    let id: UUID
    let date: Date
    
    var objectID: NSManagedObjectID?
    
    init(
        _ name: String = "",
        id: UUID = UUID(),
        date: Date = Date(),
        objectID: NSManagedObjectID? = nil
    ) {
        
        self.name = name
        self.id = id
        self.date = date
        self.objectID = objectID
    
    }
    
    mutating func update(_ name: String) {
        self.name = name
    }
}

extension LocalTodo: Equatable {
    
    static func == (lhs: LocalTodo, rhs: LocalTodo) -> Bool {
            lhs.id == rhs.id
        }

}
