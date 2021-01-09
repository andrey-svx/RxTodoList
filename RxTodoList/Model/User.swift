import Foundation
import RxSwift

class User {
    
    let loginDetails = BehaviorSubject<LoginDetails?>(value: nil)
    let todos = BehaviorSubject<[Todo]>(value: [])
    
    private var _loginDetails: LoginDetails? {
        didSet { loginDetails.onNext(_loginDetails) }
    }
    
    private var _todos: [Todo] {
        didSet { todos.onNext(_todos) }
    }
    
    private var _editedTodo: Todo?
    
    init() {
        self._loginDetails = nil
        self._todos = []
        self._editedTodo = nil
    }
    
    func configure() {
        self._loginDetails = LoginDetails(username: "initial_user", password: "1234")
        self._todos =
            ["Clean the apt",
             "Learn to code",
             "Call mom",
             "Do the workout",
             "Call customers"]
            .map(Todo.init)
    }
    
    func getEdited() -> Todo? {
        self._editedTodo
    }
    
    func setEdited(_ todo: Todo?) {
        self._editedTodo = todo
    }
    
    func updateEdited(_ name: String) {
        self._editedTodo?.update(name)
    }
    
    func getTodos() -> [Todo] {
        _todos
    }
    
    func updateTodos() {
        guard let editedTodo = _editedTodo else { return }
        
        if let index = _todos.firstIndex(where: { $0.id == editedTodo.id }) {
            if !editedTodo.name.isEmpty {
                _todos[index] = editedTodo
            } else {
                _todos.remove(at: index)
            }
        } else if !editedTodo.name.isEmpty {
            _todos.append(editedTodo)
        }
    }
    
    var logSign: ((String, String) -> Observable<LoginDetails?>)?
    
    #if DEBUG
    deinit {
        print("model deinited!")
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
