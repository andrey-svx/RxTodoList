import Foundation
import RxSwift

class User {
    
    private var userDetails: UserDetails?
    
    private var todos: [Todo]
    
    init(userDetails: UserDetails? = nil) {
        self.userDetails = userDetails
        self.todos = ["Learn to code", "Call mom", "Call clients"].map(Todo.init)
    }
    
    func getDetails() -> UserDetails? {
        guard let userDetails = self.userDetails else { return nil }
        return userDetails
    }
    
    func logout() {
        
    }
    
    func login(with userDetails: UserDetails) {
        
    }
    
    func signup(with userDetails: UserDetails) {
        
    }
    
    func getTodos() -> [Todo] {
        return todos
    }
    
    func setTodos(_ todos: [Todo]) {
        self.todos = todos
    }
    
    func editTodo(at index: Int, with name: String) {
        todos[index].update(name: name)
    }
    
    func deleteTodo(at index: Int) {
        todos.remove(at: index)
    }

    func appendTodo(text: String) {
        todos.append(Todo(text))
    }
    
}
