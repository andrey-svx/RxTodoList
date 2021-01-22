import XCTest
import CoreData

@testable
import RxTodoList

class NSManagedObjectContextTests: XCTestCase {
    
    lazy var context: NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.context
    }()
    
    lazy var request: NSFetchRequest<TestStoredClass> = {
        let request = TestStoredClass.fetchRequest() as NSFetchRequest<TestStoredClass>
        let sort = NSSortDescriptor(key: "date", ascending: false)
        request.sortDescriptors = [sort]
        request.returnsObjectsAsFaults = false
        return request
    }()
    
    lazy var imageData: Data = {
        let urlString = "https://upload.wikimedia.org/wikipedia/commons/3/39/E-burg_asv2019-05_img46_view_from_VysotSky.jpg"
        let imageURL = URL(string: urlString)!
        return try! Data(contentsOf: imageURL)
    }()
    
    var testEntities: [TestStoredClass] = []

    override func setUpWithError() throws {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "TestStoredClass")
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        context.performAndWait {
            try! self.context.execute(batchDeleteRequest)
        }
        
        testEntities = ["First entity",
                        "Second entity",
                        "Third entity"]
            .map { name -> TestStoredClass in
                sleep(1)
                let entity = TestStoredClass(context: self.context)
                entity.name = name
                entity.date = Date()
                entity.imageData = self.imageData
                return entity
            }
    }

    override func tearDownWithError() throws {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "TestStoredClass")
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        context.performAndWait {
            try! self.context.execute(batchDeleteRequest)
        }
    }
    
    func test_fetch() throws {
        context.performAndWait{
            try! context.save()
        }
    }
    
    func test_save() throws {
        let expectation = self.expectation(description: "Save")
        var fetchedEntities: [TestStoredClass] = []
        context
            .save { result, error in
                self.context.performAndWait {
                    fetchedEntities = try! self.context.fetch(self.request)
                    expectation.fulfill()
                }
            }
        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertEqual(fetchedEntities, self.testEntities.reversed())
    }
    
    func test_deleteObject() throws {
        context.performAndWait {
            try! self.context.save()
        }
        
        let deletedEntity = testEntities.last!
        
    }
    
    func test_deleteObjects() throws {
        context.performAndWait {
            try! self.context.save()
        }
        
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}

