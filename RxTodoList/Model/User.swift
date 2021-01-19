import Foundation
import CoreData
import RxSwift

class User: TodoListDelegate, AccountDelegate {
    
    let todos = BehaviorSubject<[LocalTodo]>(value: [])
    internal var editedTodo: LocalTodo? = nil
    private(set) var initialEditedTodo: LocalTodo? = nil
    
    lazy var todoList: TodoList = {
        let list = TodoList()
        list.delegate = self
        return list
    }()

    let loginDetails = BehaviorSubject<LoginDetails?>(value: nil)
    
    lazy var account: Account = {
        let account = Account()
        account.delegate = self
        return account
    }()
    
    init() {
        
    }
    
    func configure() {
        account.checkUpLogin()
        todoList.fetchAllStoredTodos()
    }
    
    #if DEBUG
    deinit {
        print("Deinit: " + String(describing: self))
    }
    #endif
    
}

extension User {
    
    func setForAppending() {
        todoList.appendOrEdit = todoList.insertTodo
        todoList.setEdited(LocalTodo())
    }
    
    func setForEdititng(_ todo: LocalTodo) {
        initialEditedTodo = todo
        todoList.appendOrEdit = todoList.editTodo
        todoList.setEdited(todo)
    }
    
    func updateEdited(_ name: String) {
        todoList.updateEdited(name)
    }
    
    func cancelAppendinOrEdinitg() {
        todoList.updateEdited(initialEditedTodo?.name ?? "")
        todoList.appendOrEdit?()
        initialEditedTodo = nil
    }
    
    func updateTodoList() {
        todoList.appendOrEdit?()
        initialEditedTodo = nil
    }
    
}

extension User {
    
    func logout() -> Observable<LoginDetails?> {
        account.logout()
    }
    
    func setForLogIn() {
        account.logOrSign = account.loginAs(_:_:)
    }
    
    func setForSignUp() {
        account.logOrSign = account.signupAs(_:_:)
    }
    
}
