import XCTest
import CoreData
import RxSwift
import RxCocoa
import RxRelay
import RxBlocking

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
    
    let queue = DispatchQueue(label: "SerialQueue")
    
    let bag = DisposeBag()

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
        
        let fetchedEntities = try! context.rx
            .fetch(request)
            .toBlocking()
            .first()!
        
        XCTAssertEqual(fetchedEntities, testEntities.reversed())
    }
    
    func test_save() throws {
        context.rx
            .save(on: queue)
            .bind(onNext: {
                self.context.performAndWait {
                    let fetchedEntities = try! self.context.fetch(self.request)
                    XCTAssertEqual(fetchedEntities, self.testEntities.reversed())
                }
            })
            .disposed(by: bag)
    }
    
    func test_delete() throws {
        context.performAndWait {
            try! self.context.save()
        }
        
        let deletedEntity = testEntities.last!
        
        context.rx
            .deleteAndSave(deletedEntity, on: queue)
            .bind(onNext: { _ in
                self.context.performAndWait {
                    let fetchedEntities = try! self.context.fetch(self.request)
                    XCTAssertEqual(
                        fetchedEntities,
                        [self.testEntities[0], self.testEntities[1]].reversed()
                    )
                }
            })
            .disposed(by: bag)
    }
    
    func test_deleteAll() throws {
        context.performAndWait {
            try! self.context.save()
        }
        
        context.rx
            .deleteAll(TestStoredClass.self, on: queue)
            .bind(onNext: { _ in
                let request = TestStoredClass.fetchRequest() as NSFetchRequest<TestStoredClass>
                self.context.performAndWait {
                    let fetchedEntities = try! self.context.fetch(request)
                    XCTAssertEqual(fetchedEntities, [])
                }
            })
            .disposed(by: bag)
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
