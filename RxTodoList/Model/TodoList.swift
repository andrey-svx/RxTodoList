import CoreData
import RxSwift
import Foundation

class TodoList {
    
    weak var delegate: TodoListDelegate?

}

protocol TodoListDelegate: AnyObject {
    
    var todos: BehaviorSubject<[LocalTodo]> { get }
    var editedItem: LocalTodo? { get set }
    
    var todoList: TodoList { get }
    
    func update(todos: [LocalTodo])
    func update(editedItem: LocalTodo?)
    
}

extension TodoListDelegate {
    
    func update(todos: [LocalTodo]) {
        self.todos.onNext(todos)
    }
    
    func update(editedItem: LocalTodo?) {
        self.editedItem = editedItem
    }
    
}
