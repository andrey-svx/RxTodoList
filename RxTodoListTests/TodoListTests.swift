import XCTest
import CoreData
import RxSwift
import RxCocoa
import RxRelay
import RxBlocking

@testable
import RxTodoList

class TodoListTests: XCTestCase {
    
    let user = User()
    
    lazy var list: TodoList = {
        let list = TodoList()
        list.delegate = user
        return list
    }()
    
    lazy var context: NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.context
        return context
    }()

    override func setUpWithError() throws {
        
    }

    override func tearDownWithError() throws {

    }

    func test_insertTodo_testTodo() throws {
        list.setEdited(LocalTodo("Test todo"))
        list.insertTodo()
        
    }
     
    func test_insertTodo_emptyTodo() throws {
        list.setEdited(LocalTodo())
        list.insertTodo()
        
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
