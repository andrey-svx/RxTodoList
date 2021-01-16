import Foundation
import CoreData


extension CDTodo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDTodo> {
        return NSFetchRequest<CDTodo>(entityName: "CDTodo")
    }

    @NSManaged public var date: Date
    @NSManaged public var id: UUID
    @NSManaged public var name: String

}

extension CDTodo : Identifiable { }
