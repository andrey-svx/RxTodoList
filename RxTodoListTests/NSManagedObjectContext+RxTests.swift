import XCTest
import CoreData
import RxSwift

@testable
import RxTodoList

class NSManagedObjectContext_RxTests: XCTestCase {
    
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
    var fetchedEntities: [TestStoredClass] = []
    
    let queue = DispatchQueue(label: "SerialQueue")
    
    let bag = DisposeBag()

    override func setUpWithError() throws {
        clearAllEntities(at: context)
        testEntities = ["1st entity", "2nd entity", "3rd entity"]
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
        clearAllEntities(at: context)
    }
    
    func test_fetch() throws {
        context.performAndWait{
            try! context.save()
        }
        
        let expectation = self.expectation(description: "Fetch")
        
        context.rx
            .fetch(request, on: queue)
            .bind { entites in
                self.fetchedEntities = entites
                expectation.fulfill()
            }
            .disposed(by: bag)
        
        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertEqual(fetchedEntities, testEntities.reversed())
    }
    
    func test_save() throws {
        let expectation = self.expectation(description: "Save")
        
        context.rx
            .save(on: queue)
            .bind(onNext: {
                self.context.performAndWait {
                    self.fetchedEntities = try! self.context.fetch(self.request)
                    expectation.fulfill()
                }
            })
            .disposed(by: bag)
        
        waitForExpectations(timeout: 2, handler: nil)
        XCTAssertEqual(fetchedEntities, self.testEntities.reversed())
    }
    
    func test_deleteAndSave() throws {
        context.performAndWait {
            try! self.context.save()
        }
        
        let deletedEntity = testEntities.last!
        
        let expectation = self.expectation(description: "Delete")
        
        context.rx
            .deleteAndSave(deletedEntity, on: queue)
            .bind(onNext: { _ in
                self.context.performAndWait {
                    self.fetchedEntities = try! self.context.fetch(self.request)
                    expectation.fulfill()
                }
            })
            .disposed(by: bag)

        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertEqual(fetchedEntities, [self.testEntities[0], self.testEntities[1]].reversed()
        )
    }
    
    func test_deleteAll() throws {
        context.performAndWait {
            try! self.context.save()
        }
        
        let expectation = self.expectation(description: "DeleteAll")
        
        context.rx
            .deleteAll(TestStoredClass.self, on: queue)
            .bind(onNext: { _ in
                self.fetchedEntities = try! self.context.fetch(self.request)
                expectation.fulfill()
            })
            .disposed(by: bag)
        
        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertTrue(fetchedEntities.isEmpty)
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func clearAllEntities(at context: NSManagedObjectContext) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "TestStoredClass")
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        context.performAndWait {
            try! context.execute(batchDeleteRequest)
        }
    }

}
