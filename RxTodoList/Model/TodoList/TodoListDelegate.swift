import Foundation
import RxSwift

protocol TodoListDelegate: AnyObject {
    
    var todos: BehaviorSubject<[LocalTodo]> { get }
    var editedTodo: LocalTodo? { get set }
    
    var todoList: TodoList { get }
    
    func update(todos: [LocalTodo])
    func update(editedTodo: LocalTodo?)
    
}

extension TodoListDelegate {
    
    func update(todos: [LocalTodo]) {
        
        self.todos.onNext(todos)
    
    }
    
    func update(editedTodo: LocalTodo?) {
    
        self.editedTodo = editedTodo
    
    }
    
}
