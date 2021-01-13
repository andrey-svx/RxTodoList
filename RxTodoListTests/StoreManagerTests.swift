import XCTest
import CoreData
import RxSwift
import RxCocoa
import RxRelay
import RxBlocking

@testable
import RxTodoList

class StoreManagerTests: XCTestCase {
    
    let manager = StoreManager()
    
    lazy var context: NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.context
    }()

    override func setUpWithError() throws {

    }
    
    override func tearDownWithError() throws {
        
    }
    
    func test_fetchTodos() throws {
        
        // Set up
        let testTodos: [Todo] = ["Clean the apt",
                                 "Learn to code",
                                 "Call mom",
                                 "Do the workout",
                                 "Call customers"]
            .map { name -> Todo in
                sleep(1)
                return Todo(name)
            }
            
        let testCDTodos: [CDTodo] = testTodos
            .map {
                let cdTodo = CDTodo(context: context)
                cdTodo.name = $0.name
                cdTodo.id = $0.id
                cdTodo.date = $0.date
                return cdTodo
            }

        context.performAndWait {
            do {
                try context.save()
            } catch {
                print(error)
            }
        }
        
        let fetchedTodos = try! manager
            .fetchTodos()
            .toBlocking()
            .first()!
        
        XCTAssertEqual(fetchedTodos, testTodos)
        
        context.performAndWait {
            do {
                self.context.registeredObjects.forEach(self.context.delete)
                try self.context.save()
            } catch {
                print(error)
            }
        }

    }
    
    func test_appendTodo() throws {
        
        // Set up
        let testTodos: [Todo] = ["Clean the apt",
                                     "Learn to code",
                                     "Call mom",
                                     "Do the workout",
                                     "Call customers"]
            .map { name -> Todo in
                sleep(1)
                return Todo(name)
            }
            
        let testCDTodos: [CDTodo] = testTodos
            .map {
                let cdTodo = CDTodo(context: context)
                cdTodo.name = $0.name
                cdTodo.id = $0.id
                cdTodo.date = $0.date
                return cdTodo
            }

        context.performAndWait {
            do {
                try context.save()
            } catch {
                print(error)
            }
        }
        
        let appendedTodo: Todo = ["AppendedTodo"]
            .map { name -> Todo in
                sleep(1)
                return Todo(name)
            }
            .first!
        
        let fetchedTodos = try! manager
            .appendTodo(appendedTodo)
            .flatMap { _ -> Observable<[Todo]> in
                self.manager.fetchTodos()
            }
            .toBlocking()
            .first()!
        
        XCTAssertEqual(fetchedTodos, testTodos + [appendedTodo])
        
        context.performAndWait {
            do {
                self.context.registeredObjects.forEach(self.context.delete)
                try self.context.save()
            } catch {
                print(error)
            }
        }
        
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}

