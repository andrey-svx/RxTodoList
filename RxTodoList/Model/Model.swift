import Foundation
import CoreData
import RxSwift

class Model: TodoListDelegate, AccountDelegate {
    
    let todos = BehaviorSubject<[LocalTodo]>(value: [])
    internal var editedTodo: LocalTodo? = nil
    private(set) var initialEditedTodo: LocalTodo? = nil
    
    lazy var todoList: TodoList = {
        let list = TodoList()
        list.delegate = self
        return list
    }()

    let loginDetails = BehaviorSubject<LoginDetails?>(value: nil)
    let isBusy = BehaviorSubject<Bool>(value: false)
    
    lazy var account: Account = {
        let account = Account()
        account.delegate = self
        return account
    }()

    
    init() {
        
    }
    
    func configure() {
        account.checkUpLogin()
        todoList.fetchAllTodos()
    }
    
    #if DEBUG
    deinit {
        print("Deinit: " + String(describing: self))
    }
    #endif
    
}

extension Model {
    
    func setForInserting() {
        todoList.state = .inserting
        todoList.setEdited(LocalTodo())
    }
    
    func setForEdititng(_ todo: LocalTodo) {
        initialEditedTodo = todo
        todoList.state = .editing
        todoList.setEdited(todo)
    }
    
    func updateEdited(_ name: String) {
        todoList.updateEdited(name)
    }
    
    func cancelAppendinOrEdinitg() {
        todoList.updateEdited(initialEditedTodo?.name ?? "")
        todoList.insertOrEdit()
        initialEditedTodo = nil
    }
    
    func updateTodoList() {
        todoList.insertOrEdit()
        initialEditedTodo = nil
    }
    
}

extension Model {
    
    func logout() -> Observable<Account.AResult> {
        account.logout()
    }
    
    func setForLogIn() {
        account.logOrSign = account.loginAs(_:_:)
    }
    
    func setForSignUp() {
        account.logOrSign = account.signupAs(_:_:)
    }
    
}
