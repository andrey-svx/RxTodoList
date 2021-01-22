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
    
    private var persistenceMgr = PersistenceManager()
    
    init() {
        
        self._todos = []
        self._editedTodo = nil
        
    }
    
    func fetchAllStoredTodos() {
        persistenceMgr
            .fetchAllTodos()
            .bind(onNext: { [weak self] fetchResult in
                guard case .success(let todos) = fetchResult, !todos.isEmpty else { return }
                self?._todos = todos
            })
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
        guard var editedTodo = _editedTodo,
              let index = _todos.firstIndex(where: { $0 == editedTodo }) else { return }
        
        if !editedTodo.name.isEmpty {
            persistenceMgr
                .remove(todo: editedTodo)
                .flatMap { [unowned self] _ in self.persistenceMgr.insert(todo: editedTodo) }
                .bind(onNext: { [weak self] insertResult in
                    guard case .success(let objectID) = insertResult else { return }
                    editedTodo.objectID = objectID
                    self?._todos[index] = editedTodo
                })
                .disposed(by: DisposeBag())
        } else {
            let removedTodo = _todos[index]
            persistenceMgr
                .remove(todo: removedTodo)
                .bind (onNext: { [weak self] removeResult in
                    guard case .success(_) = removeResult else { return }
                    self?._todos.remove(at: index)
                })
                .disposed(by: DisposeBag())
        }
    }
    
    func insertTodo() {
        guard var editedTodo = _editedTodo, !editedTodo.name.isEmpty else { return }
        persistenceMgr
            .insert(todo: editedTodo)
            .bind(onNext: { [weak self] insertResult in
                print(insertResult)
                guard case .success(let objectID) = insertResult else { return }
                editedTodo.objectID = objectID
                self?._todos.insert(editedTodo, at: 0)
            })
            .disposed(by: DisposeBag())
    }
    
}

extension TodoList {
    
    func getTodos() -> [LocalTodo] {
        _todos
    }
    
}
