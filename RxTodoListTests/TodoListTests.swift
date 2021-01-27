import XCTest
import CoreData
import RxSwift

@testable
import RxTodoList

class TodoListTests: XCTestCase {
    
    lazy var todoList: TodoList = {
        let list = TodoList()
//        list.testableDelegate = self
        return list
    }()
    
    var todos: [LocalTodo] = [] {
        didSet { print("TODOS: \(todos.map { $0.name })") }
    }
    
    var editedTodo: LocalTodo? = nil

    var manager: PersistenceManager!
    
    let bag = DisposeBag()
    
    override func setUpWithError() throws {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.context
        manager = PersistenceManager(context)
        let todos = ["1st todo", "2nd todo", "3rd todo"]
            .map { LocalTodo($0) }
        manager
            .removeAllTodos()
            .map { _ in
                todos
            }
            .flatMap {
                self.manager
                    .insert(todos: $0)
            }
            .observeOn(MainScheduler.instance)
            .bind(onNext: { insertResult in
                self.todos = todos
            })
            .disposed(by: bag)
    }

    override func tearDownWithError() throws {
        manager
            .removeAllTodos()
            .bind(onNext: { _ in })
            .disposed(by: bag)
    }

    func test_insertTodo_testTodo() throws {
        print("XXX")
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
