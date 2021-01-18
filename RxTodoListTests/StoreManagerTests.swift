import XCTest
import CoreData
import RxSwift
import RxCocoa
import RxRelay
import RxBlocking

@testable
import RxTodoList

//class StoreManagerTests: XCTestCase {
//    
//    var client = PersistenceClient()
//    
//    lazy var context: NSManagedObjectContext = {
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        return appDelegate.context
//    }()
//
//    override func setUpWithError() throws {
//        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CDTodo")
//        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: request)
//        context.performAndWait {
//            do {
//                try self.context.execute(batchDeleteRequest)
//            } catch {
//                print(error)
//            }
//        }
//    }
//    
//    override func tearDownWithError() throws {
//        
//    }
//    
//    func test_fetchTodos() throws {
//        
//        let testTodos: [LocalTodo] = ["1st Todo", "2nd Todo", "3rd Todo"]
//            .map { name -> LocalTodo in
//                sleep(1)
//                return LocalTodo(name)
//            }
//            
//        let testCDTodos: [StoredTodo] = testTodos
//            .map {
//                let cdTodo = StoredTodo(context: context)
//                cdTodo.name = $0.name
//                cdTodo.id = $0.id
//                cdTodo.date = $0.date
//                return cdTodo
//            }
//
//        context.performAndWait {
//            do {
//                testCDTodos.forEach(context.insert(_:))
//                try context.save()
//            } catch {
//                print(error)
//            }
//        }
//        
//        let fetchedTodos = try! client
//            .fetchTodos()
//            .toBlocking()
//            .first()!
//        
//        XCTAssertEqual(fetchedTodos, testTodos)
//
//    }
//    
//    func test_appendTodo() throws {
//        
//        let testTodos: [LocalTodo] = ["1st Todo", "2nd Todo", "3rd Todo"]
//            .map { name -> LocalTodo in
//                sleep(1)
//                return LocalTodo(name)
//            }
//            
//        let testCDTodos: [StoredTodo] = testTodos
//            .map {
//                let cdTodo = StoredTodo(context: context)
//                cdTodo.name = $0.name
//                cdTodo.id = $0.id
//                cdTodo.date = $0.date
//                return cdTodo
//            }
//
//        context.performAndWait {
//            do {
//                testCDTodos.forEach(context.insert(_:))
//                try context.save()
//            } catch {
//                print(error)
//            }
//        }
//        
//        let appendedTodo: LocalTodo = ["Appended Todo"]
//            .map { name -> LocalTodo in
//                sleep(1)
//                return LocalTodo(name)
//            }
//            .first!
//        
//        let fetchedTodos = try! client
//            .insert(appendedTodo)
//            .flatMap { _ -> Observable<[LocalTodo]> in
//                self.client
//                    .fetchTodos()
//            }
//            .toBlocking()
//            .first()!
//        
//        XCTAssertEqual(fetchedTodos, testTodos + [appendedTodo])
//        
//    }
//
//    func testPerformanceExample() throws {
//        // This is an example of a performance test case.
//        measure {
//            // Put the code you want to measure the time of here.
//        }
//    }
//
//}
//
