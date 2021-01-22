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
    
    var testEntities: [TestStoredClass] = []
    
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
        print("FETCHED ENTITIES: \(fetchedEntities)")
        XCTAssertEqual(fetchedEntities, testEntities.reversed())
    }
    
    func test_save() throws {
        context.rx
            .save()
            .bind(onNext: {
                self.context.performAndWait {
                    let fetchedEntities = try! self.context.fetch(self.request)
                    XCTAssertEqual(fetchedEntities, self.testEntities.reversed())
                }
            })
            .disposed(by: bag)
    }
    
    func test_completion() throws {
        context.performAndWait {
            try! self.context.save()
        }
        
        context.rx
            .save { (_, _) in
                self.context.performAndWait {
                    let fetchedEntities = try! self.context.fetch(self.request)
                    XCTAssertEqual(fetchedEntities, self.testEntities.reversed())
                }
            }
    }
    
    func test_delete() throws {
        context.performAndWait {
            try! self.context.save()
        }
        
        let deletedEntity = testEntities.last!
        
        context.rx
            .delete(deletedEntity)
            .bind(onNext: { _ in
                self.context.performAndWait {
                    try! self.context.save()
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
            .deleteAll(TestStoredClass.self)
            .bind(onNext: { _ in
                let request = TestStoredClass.fetchRequest() as NSFetchRequest<TestStoredClass>
                self.context.performAndWait {
                    let fetchedEntities = try! self.context.fetch(request)
                    XCTAssertEqual(fetchedEntities, [])
                }
            })
            .disposed(by: DisposeBag())
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
