import XCTest
import CoreData

@testable
import RxTodoList

class TodoListTests: XCTestCase {
    
    var todoList: TodoList!
    
    var testTodos: [LocalTodo] = []
    var fetchedTodos: [LocalTodo] = []
    
    lazy var context: NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.context        
    }()
    
    
    override func setUpWithError() throws {
        clearAllEntities(at: context)
        testTodos = ["1st Todo", "2nd Todo", "3rd Todo"]
            .map {
                sleep(1)
                return LocalTodo($0)
            }
        let storedTodos = testTodos
            .map { StoredTodo(context: self.context, id: $0.id, date: $0.date, name: $0.name) }
        context.performAndWait { try! context.save() }
        let objectIDs = storedTodos
            .map { $0.objectID }
        for (i, _) in testTodos.enumerated() { self.testTodos[i].objectID = objectIDs[i] }
        todoList = TodoList()
    }

    override func tearDownWithError() throws {
        clearAllEntities(at: context)
        todoList = nil
    }
    
    func test_fetchAllTodos() throws {
        let expectation = self.expectation(description: "FetchAll")
        todoList.fetchAllTodos { todos in
            self.fetchedTodos = todos
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertEqual(fetchedTodos, testTodos.reversed())
    }
    
    func test_deleteAllTodos() throws {
        let expectation = self.expectation(description: "DeleteAll")
        todoList.deleteAllTodos { todos in
            self.fetchedTodos = todos
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertTrue(fetchedTodos.isEmpty)
    }

    func test_insertTodo_testTodo() throws {
        let expectation = self.expectation(description: "InsertTestTodo")
        let insertedTodo = LocalTodo("Test Todo")
        todoList.state = .inserting
        todoList.setEdited(insertedTodo)
        todoList.fetchAllTodos { _ in
            self.todoList.insertOrEdit { todos in
                self.fetchedTodos = todos
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertEqual(fetchedTodos, [insertedTodo] + self.testTodos.reversed())
    }
     
    func test_insertTodo_emptyTodo() throws {
        let expectation = self.expectation(description: "InsertEmptyTodo")
        var fetchedTodos: [LocalTodo] = []
        let insertedTodo = LocalTodo("")
        todoList.state = .inserting
        todoList.setEdited(insertedTodo)
        todoList.fetchAllTodos { _ in
            self.todoList.insertOrEdit { todos in
                fetchedTodos = todos
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertEqual(fetchedTodos, testTodos.reversed())
    }
    
    func test_editTodo_testTodo() throws {
        let expectation = self.expectation(description: "EditTestTodo")
        var editedTodo = testTodos[0]
        todoList.state = .editing
        todoList.setEdited(editedTodo)
        editedTodo.update("Edited Todo")
        todoList.fetchAllTodos { _ in
            self.todoList.insertOrEdit { todos in
                self.fetchedTodos = todos
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertEqual(fetchedTodos, testTodos.reversed())
    }
    
    func test_editTodo_emptyTodo() throws {
        let expectation = self.expectation(description: "EditEmptyTodo")
        let editedTodo = testTodos[0]
        todoList.state = .editing
        todoList.setEdited(editedTodo)
        todoList.updateEdited("")
        todoList.fetchAllTodos { _ in
            self.todoList.insertOrEdit { todos in
                self.fetchedTodos = todos
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertEqual(fetchedTodos, [testTodos[1], testTodos[2]].reversed())
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
