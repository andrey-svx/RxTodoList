import CoreData
import RxSwift
import Foundation

class TodoList {
    
    weak var delegate: TodoListDelegate?
    
    private var _todos: [LocalTodo] {
        didSet { delegate?.update(todos: _todos) }
    }
    
    private var _editedTodo: LocalTodo? {
        didSet { delegate?.update(editedTodo: _editedTodo) }
    }
    
    var appendOrEdit: (() -> Void)?
    var logOrSign: ((String, String) -> Observable<LoginDetails?>)?
    
    private let persistenceClt = PersistenceClient()
    
    init() {
        
        self._todos = []
        self._editedTodo = nil
        
    }
    
    func configure() {
        persistenceClt
            .fetchTodos()
            .bind { [weak self] todos in
                guard !todos.isEmpty else { self?._todos = todos; return }
                self?._todos =
                    ["Clean the apt",
                     "Learn to code",
                     "Call mom",
                     "Do the workout",
                     "Call customers"]
                    .map { LocalTodo($0) }
            }
            .disposed(by: DisposeBag())
    }
    
    #if DEBUG
    deinit {
        print("Deinit: " + String(describing: Self.self))
    }
    #endif

}

extension TodoList {
    
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
