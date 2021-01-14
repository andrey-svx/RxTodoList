import Foundation
import CoreData


struct Todo {
    
    var name: String
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

extension Todo: Equatable {
    
    static func == (lhs: Todo, rhs: Todo) -> Bool {
            lhs.id == rhs.id
        }

}
