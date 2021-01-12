import Foundation
import CoreData
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
    
    private lazy var context: NSManagedObjectContext = {
        let container = NSPersistentContainer(name: "CDTodoList")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        let context = container.newBackgroundContext()
        return context
    }()
    
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
    
    var appendOrEdit: (() -> Void)?
    var logOrSign: ((String, String) -> Observable<LoginDetails?>)?
    
    func editTodo() {
        guard let editedTodo = _editedTodo,
              let index = _todos.firstIndex(where: { $0.id == editedTodo.id }) else { return }
        
        if !editedTodo.name.isEmpty {
            _todos[index] = editedTodo
        } else {
            _todos.remove(at: index)
        }
    }
    
    func appendTodo() {
        guard let editedTodo = _editedTodo,
              !editedTodo.name.isEmpty else { return }
        let appendedTodo = editedTodo
        _todos.append(appendedTodo)
    }
    
    
    #if DEBUG
    deinit {
        print("Model deinited!")
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
