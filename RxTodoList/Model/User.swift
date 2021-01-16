import Foundation
import CoreData
import RxSwift

class User: TodoListDelegate {
    
    let loginDetails = BehaviorSubject<LoginDetails?>(value: nil)
    
    private var _loginDetails: LoginDetails? {
        didSet { loginDetails.onNext(_loginDetails) }
    }
    
    let todos = BehaviorSubject<[LocalTodo]>(value: [])
    internal var editedTodo: LocalTodo? = nil
    private(set) var initialEditedTodo: LocalTodo? = nil
    
    lazy var todoList: TodoList = {
        let list = TodoList()
        list.delegate = self
        return list
    }()
    
    init() {
        
    }
    
    func configure() {
        _loginDetails = LoginDetails(username: "current-user", password: "1234")
        todoList.configure()
    }
    
    var logOrSign: ((String, String) -> Observable<LoginDetails?>)?
    
    func setForAppending() {
        todoList.appendOrEdit = todoList.appendTodo
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
    }
    
    func updateTodoList() {
        todoList.appendOrEdit?()
        initialEditedTodo = nil
    }
    
    #if DEBUG
    deinit {
        print("Deinit: " + String(describing: self))
    }
    #endif
    
}

extension User {
    
    @discardableResult
    func logout() -> Observable<LoginDetails?> {
        Observable<LoginDetails?>.just(nil)
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .do(onNext: { [weak self] _ in sleep(1); self?._loginDetails = nil })
            .map { [weak self] _ in self?._loginDetails }
    }
    
    func loginAs(_ username: String, _ password: String) -> Observable<LoginDetails?> {
        Observable<(String, String)>
            .of((username, password))
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .do(onNext: { [weak self] (username, password) in
                    sleep(1)
                    self?._loginDetails = LoginDetails(username: username, password: password)
            })
            .map { [weak self] _ in self?._loginDetails }
    }
    
    func signupAs(_ username: String, _ password: String) -> Observable<LoginDetails?> {
        Observable<(String, String)>
            .of((username, password))
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .do(onNext: { [weak self] (username, password) in
                    sleep(1)
                    self?._loginDetails = LoginDetails(username: username, password: password)
            })
            .map { [weak self] _ in self?._loginDetails }
    }
    
}
