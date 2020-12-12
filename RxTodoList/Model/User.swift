import Foundation

struct User {
    
    var loginDetails: LoginDetails?
    var todoList: TodoList
    
    init(loginDetails: LoginDetails? = nil, todoList: TodoList = TodoList()) {
        
        self.loginDetails = loginDetails
        self.todoList = todoList
    
    }
    
}
