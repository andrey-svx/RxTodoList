import Foundation
import RxSwift

struct User {
    
    var loginDetails = BehaviorSubject<LoginDetails?>(value: nil)
    var todoList: TodoList
    
    init(loginDetails: LoginDetails? = nil, todoList: TodoList = TodoList()) {
        self.loginDetails.onNext(loginDetails)
        self.todoList = todoList
    }
    
}
