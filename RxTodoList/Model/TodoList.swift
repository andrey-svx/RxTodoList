import CoreData
import RxSwift
import Foundation

class TodoList {
    
    weak var delegate: TodoListDelegate?

}

protocol TodoListDelegate: AnyObject {
    
    var todos: BehaviorSubject<[Todo]> { get }
    var editedItem: Todo? { get set }
    
    var todoList: TodoList { get }
    
    func update(todos: [Todo])
    func update(editedItem: Todo?)
    
}

extension TodoListDelegate {
    
    func update(todos: [Todo]) {
        self.todos.onNext(todos)
    }
    
    func update(editedItem: Todo?) {
        self.editedItem = editedItem
    }
    
}
