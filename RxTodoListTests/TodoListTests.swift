import XCTest
import CoreData
import RxSwift

@testable
import RxTodoList

class TodoListTests: XCTestCase {
    
    let todoList = TodoList()
    
    var todos: [LocalTodo] = []
    
    lazy var context: NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.context        
    }()
    
    let bag = DisposeBag()
    
    override func setUpWithError() throws {
        
    }

    override func tearDownWithError() throws {
        
    }

    func test_insertTodo_testTodo() throws {
        
    }
     
    func test_insertTodo_emptyTodo() throws {
        
    }
    
    func test_editTodo_testTodo() throws {
//        let todoToEdit = list.getTodos()[0]
//        list.setEdited(todoToEdit)
//        list.updateEdited("Test todo")
//        list.editTodo()
        
    }
    
    func test_editTodo_emptyTodo() throws {
//        let todoToDelete = list.getTodos()[0]
//        list.setEdited(todoToDelete)
//        list.updateEdited("")
//        list.editTodo()

    }


    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
