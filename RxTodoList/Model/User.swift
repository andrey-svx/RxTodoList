import Foundation
import CoreData
import RxSwift

class User {
    
    let loginDetails = BehaviorSubject<LoginDetails?>(value: nil)
    
    let todos = BehaviorSubject<[LocalTodo]>(value: [])
    
    private var _loginDetails: LoginDetails? {
        didSet { loginDetails.onNext(_loginDetails) }
    }
    
    private var _todos: [LocalTodo] {
        didSet { todos.onNext(_todos) }
    }
    
    private var _editedTodo: LocalTodo?
    
    private let persistenceClt = PersistenceClient()
    
    init() {
        self._loginDetails = nil
        self._todos = []
        self._editedTodo = nil
    }
    
    func configure() {
        _loginDetails = LoginDetails(username: "initial_user", password: "1234")
        persistenceClt
            .fetchTodos()
            .bind { [weak self] todos in
                if todos.isEmpty {
                    self?._todos =
                        ["Clean the apt",
                         "Learn to code",
                         "Call mom",
                         "Do the workout",
                         "Call customers"]
                        .map { LocalTodo($0) }
                } else {
                    self?._todos = todos
                }
            }
            .disposed(by: DisposeBag())
    }
    
    var appendOrEdit: (() -> Void)?
    var logOrSign: ((String, String) -> Observable<LoginDetails?>)?
    
    #if DEBUG
    deinit {
        print("Deinit: " + String(describing: Self.self))
    }
    #endif
    
}

extension User {
    
    func getEdited() -> LocalTodo? {
        self._editedTodo
    }
    
    func setEdited(_ todo: LocalTodo?) {
        self._editedTodo = todo
    }
    
    func updateEdited(_ name: String) {
        self._editedTodo?.update(name)
    }
    
    func getTodos() -> [LocalTodo] {
        _todos
    }
    
    func editTodo() {
        guard let editedTodo = _editedTodo,
              let index = _todos.firstIndex(where: { $0.id == editedTodo.id }) else { return }
        
        if !editedTodo.name.isEmpty {
            _todos[index] = editedTodo
        } else {
            let removedTodo = _todos[index]
            _todos.remove(at: index)
        }
    }
    
    func appendTodo() {
        guard let editedTodo = _editedTodo, !editedTodo.name.isEmpty else { return }
        _todos.append(editedTodo)
    }
    
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
