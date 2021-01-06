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
    }
    
    func prepare() {
        self._todos =
            ["Clean the apt",
             "Learn to code",
             "Call mom",
             "Do the workout",
             "Call customers"]
            .map(Todo.init)
    }
    
    func setEdited(_ todo: Todo?) {
        self._editedTodo = todo
    }
    
    #if DEBUG
    deinit {
        print("model deinited!")
    }
    #endif
    
}
