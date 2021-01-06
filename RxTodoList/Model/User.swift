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
    
    func prepare() {
        self._loginDetails = LoginDetails(username: "andrey-svx", password: "1234")
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
    
    #if DEBUG
    deinit {
        print("model deinited!")
    }
    #endif
    
}
