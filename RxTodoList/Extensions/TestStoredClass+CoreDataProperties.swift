import Foundation
import CoreData


extension TestStoredClass {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TestStoredClass> {
        return NSFetchRequest<TestStoredClass>(entityName: "TestStoredClass")
    }

    @NSManaged public var date: Date
    @NSManaged public var name: String
    @NSManaged public var imageData: Data?

}

extension TestStoredClass : Identifiable {

}
