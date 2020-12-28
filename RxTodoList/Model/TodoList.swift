import Foundation
import RxRelay
import RxSwift

struct TodoList {
    
    let todos: BehaviorRelay<[Todo]>
    
    init() {
        
        self.todos = BehaviorRelay<[Todo]>(
            value: [
                "Clean the apt",
                "Learn to code",
                "Call mom",
                "Do the workout",
                "Call customers"
            ].map(Todo.init)
        )
        
    }
    
    func editTodo(text: String, at index: Int) {
        var todos = self.todos.value
        todos[index] = Todo(text)
        self.todos.accept(todos)
    }
    
    func deleteTodo(at index: Int) {
        var todos = self.todos.value
        todos.remove(at: index)
        self.todos.accept(todos)
    }

    func appendTodo(text: String) {
        var todos = self.todos.value
        todos.append(Todo(text))
        self.todos.accept(todos)
    }

}
