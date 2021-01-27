import XCTest
import CoreData
import RxSwift
import RxCocoa
import RxRelay
import RxBlocking

@testable
import RxTodoList

class PersistenceManagerTests: XCTestCase {
    
    var manager: PersistenceManager!
    
    lazy var context: NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.context
    }()
    
    let bag = DisposeBag()

    override func setUpWithError() throws {
        
        manager = PersistenceManager(context)
//        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "StoredTodo")
//        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: request)
//        context.performAndWait {
//            do {
//                try self.context.execute(batchDeleteRequest)
//            } catch {
//                print(error)
//            }
//        }
    }
    
    override func tearDownWithError() throws {
        
    }
    
    func test_removeAllTodos() throws {
        let testTodos: [LocalTodo] = ["1st Todo", "2nd Todo", "3rd Todo"]
            .map { name -> LocalTodo in
                sleep(1)
                return LocalTodo(name)
            }
        manager
            .removeAllTodos()
            .bind { result in
                print(result)
            }
            .disposed(by: bag)
    }
    
    func test_insertTodos() throws {
        let testTodos: [LocalTodo] = ["1st Todo", "2nd Todo", "3rd Todo"]
            .map { name -> LocalTodo in
                sleep(1)
                return LocalTodo(name)
            }
        
        manager
            .insert(todos: testTodos)
            .bind { _ in
                
            }
            .disposed(by: DisposeBag())
            
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}

