import Foundation
import CoreData


extension StoredTodo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<StoredTodo> {
        return NSFetchRequest<StoredTodo>(entityName: "StoredTodo")
    }

    @NSManaged public var id: UUID
    @NSManaged public var date: Date
    @NSManaged public var name: String
    @NSManaged public var imageData: Data?

}

extension StoredTodo : Identifiable {

}
