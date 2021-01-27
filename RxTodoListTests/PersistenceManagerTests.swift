import XCTest
import CoreData
import RxSwift

@testable
import RxTodoList

class PersistenceManagerTests: XCTestCase {
    
    var manager: PersistenceManager!
    
    lazy var context: NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.context
    }()
    
    lazy var request: NSFetchRequest<StoredTodo> = {
        let request = StoredTodo.fetchRequest() as NSFetchRequest<StoredTodo>
        let sort = NSSortDescriptor(key: "date", ascending: true)
        request.sortDescriptors = [sort]
        request.returnsObjectsAsFaults = false
        return request
    }()
    
    var testTodos: [LocalTodo] = []
    var fetchedTodos: [LocalTodo] = []
    
    let bag = DisposeBag()

    override func setUpWithError() throws {
        manager = PersistenceManager(context)
        clearAllEntities(at: context)
    }
    
    override func tearDownWithError() throws {
        clearAllEntities(at: context)
    }
    
    func test_fetchAllTodos() throws {
        let testLocalTodos = ["1st Todo", "2nd Todo", "3rd Todo"]
            .map { name -> LocalTodo in
                sleep(1)
                return LocalTodo(name)
            }
            
        testLocalTodos
            .forEach {
                _ = StoredTodo(context: self.context, id: $0.id, date: $0.date, name: $0.name)
            }
        
        context.performAndWait { try! context.save() }
        
        let expectation = self.expectation(description: "FetchTodosExpectation")
        
        manager
            .fetchAllTodos()
            .bind(onNext: { result in
                if case .success(let todos) = result {
                    self.fetchedTodos = todos
                    expectation.fulfill()
                }
            })
            .disposed(by: bag)
        
        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertEqual(fetchedTodos, testLocalTodos.reversed())
            
    }
    
    func test_insertTodo() throws {
        let testTodo = LocalTodo("Test todo")
        var fetchedTodo: LocalTodo?
        
        let expectation = self.expectation(description: "InsertTodoExpectation")
        
        manager
            .insert(todo: testTodo)
            .bind { _ in
                fetchedTodo = try! self.context.fetch(self.request)
                    .map{ LocalTodo($0.name, id: $0.id, date: $0.date, objectID: $0.objectID) }
                    .first!
                expectation.fulfill()
            }
            .disposed(by: bag)
            
        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertEqual(fetchedTodo, testTodo)
    }
    
    func test_insertTodos() throws {
        testTodos = ["1st Todo", "2nd Todo", "3rd Todo"]
            .map { name -> LocalTodo in
                sleep(1)
                return LocalTodo(name)
            }
        
        let expectation = self.expectation(description: "InsertTodosExpectation")
        
        manager
            .insert(todos: testTodos)
            .bind { _ in
                self.fetchedTodos = try! self.context.fetch(self.request)
                    .map{ LocalTodo($0.name, id: $0.id, date: $0.date, objectID: $0.objectID) }
                expectation.fulfill()
            }
            .disposed(by: bag)
            
        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertEqual(fetchedTodos, testTodos)
    }
    
    func test_removeTodo() throws {
        
        var testLocalTodos = ["1st Todo", "2nd Todo", "3rd Todo"]
            .map { name -> LocalTodo in
                sleep(1)
                return LocalTodo(name)
            }
            
        let testStoredTodos: [StoredTodo] = testLocalTodos
            .map { StoredTodo(context: self.context, id: $0.id, date: $0.date, name: $0.name) }
        
        
        context.performAndWait { try! context.save() }
        
        testLocalTodos[0].objectID = testStoredTodos[0].objectID
        
        let expectation = self.expectation(description: "RemoveTodoExpectation")
        
        manager
            .remove(todo: testLocalTodos.first!)
            .bind(onNext: { result in
                print(result)
                self.fetchedTodos = try! self.context.fetch(self.request)
                    .map{ LocalTodo($0.name, id: $0.id, date: $0.date, objectID: $0.objectID) }
                expectation.fulfill()
            })
            .disposed(by: bag)
        
        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertEqual(fetchedTodos, [testLocalTodos[1], testLocalTodos[2]])
    }
    
    func test_removeAllTodos() throws {
        ["1st Todo", "2nd Todo", "3rd Todo"]
            .map { name -> LocalTodo in
                sleep(1); return LocalTodo(name)
            }
            .forEach {
                _ = StoredTodo(context: context, id: $0.id, date: $0.date, name: $0.name)
            }
        
        context.performAndWait { try! context.save() }
        
        var fetchedStoredTodos: [StoredTodo] = []
        
        let expectation = self.expectation(description: "RemoveAllExpectation")
        
        manager
            .removeAllTodos()
            .bind { result in
                fetchedStoredTodos = try! self.context.fetch(self.request)
                expectation.fulfill()
            }
            .disposed(by: bag)
        
        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertTrue(fetchedStoredTodos.isEmpty)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func clearAllEntities(at context: NSManagedObjectContext) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "StoredTodo")
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        context.performAndWait { try! context.execute(batchDeleteRequest) }
    }

}

