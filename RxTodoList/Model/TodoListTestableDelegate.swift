import Foundation

protocol TodoListTestableDelegate: AnyObject {
    
    var todoList: TodoList { get }

    var todos: [LocalTodo] { get set }
    var editedTodo: LocalTodo? { get set }
    
    func update(todos: [LocalTodo])
    func update(editedTodo: LocalTodo?)
    
}


extension TodoListTestableDelegate {
    
    func update(todos: [LocalTodo]) {
        
        self.todos = todos
    
    }
    
    func update(editedTodo: LocalTodo?) {
        
        self.editedTodo = editedTodo
        
    }
    
}
