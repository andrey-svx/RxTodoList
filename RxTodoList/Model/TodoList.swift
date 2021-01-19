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
    
    private var persistenceClt = PersistenceClient()
    
    init() {
        
        self._todos = []
        self._editedTodo = nil
        
    }
    
    func fetchAllStoredTodos() {
        guard delegate != nil else {
            assertionFailure("Delegate for \(String(describing: self)) was not set")
            return
        }
        persistenceClt
            .fetchAllTodos()
            .bind { [weak self] fetchResult in
                if case .success(let todos) = fetchResult, !todos.isEmpty {
                    self?._todos = todos
                } else {
                    self?._todos = ["Clean the apt",
                                    "Learn to code",
                                    "Call mom",
                                    "Do the workout",
                                    "Call customers"]
                        .map { LocalTodo($0) }
                }
            }
            .disposed(by: DisposeBag())
    }
    
    func deleteAllStoredTodos() {
        guard delegate != nil else {
            assertionFailure("Delegate for \(String(describing: self)) was not set")
            return
        }
        
    }
    
    #if DEBUG
    deinit {
        print("Deinit: " + String(describing: Self.self))
    }
    #endif

}

extension TodoList {
        
    func setEdited(_ todo: LocalTodo?) {
        self._editedTodo = todo
    }
    
    func updateEdited(_ name: String) {
        self._editedTodo?.update(name)
    }
    
    func editTodo() {
        guard let editedTodo = _editedTodo,
              let index = _todos.firstIndex(where: { $0 == editedTodo }) else { return }
        
        if !editedTodo.name.isEmpty {
            _todos[index] = editedTodo
        } else {
            let removedTodo = _todos[index]
            _todos.remove(at: index)
        }
    }
    
    func appendTodo() {
        guard let editedTodo = _editedTodo, !editedTodo.name.isEmpty else { return }
        _todos.insert(editedTodo, at: 0)
    }
    
}

extension TodoList {
    
    func getTodos() -> [LocalTodo] {
        _todos
    }
    
}
