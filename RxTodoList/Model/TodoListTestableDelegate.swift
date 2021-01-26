import Foundation

protocol TodoListTestableDelegate: AnyObject {
    
    var todoList: TodoList { get }

    var todos: [LocalTodo] { get set }
    
    func update(todos: [LocalTodo])
    
}


extension TodoListTestableDelegate {
    
    func update(todos: [LocalTodo]) {
        
        self.todos = todos
    
    }
    
}
