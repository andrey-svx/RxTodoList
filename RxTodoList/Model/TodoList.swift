import Foundation
import RxRelay
import RxSwift

class TodoList {
    
    let todos: BehaviorRelay<[Todo]>
    
    init() {
        
        if let todos = TodoList.downloadTodosFromLocalStorage() {
            self.todos = BehaviorRelay<[Todo]>(value: todos)
        } else {
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
        
    }
    
    static private func downloadTodosFromLocalStorage() -> [Todo]? {
        return nil
    }
    
    private func uploadTodosToLocalStorage() {
        
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
