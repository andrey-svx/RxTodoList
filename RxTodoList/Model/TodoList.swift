import CoreData
import RxSwift
import Foundation

class TodoList {
    
    weak var delegate: TodoListDelegate?
    weak var testableDelegate: TodoListTestableDelegate?
    
    private var todos: [LocalTodo] {
        didSet {
            testableDelegate?.update(todos: todos)
            delegate?.update(todos: todos)
        }
    }
    
    private var editedTodo: LocalTodo? {
        didSet {
            testableDelegate?.update(editedTodo: editedTodo)
            delegate?.update(editedTodo: editedTodo)
        }
    }
    
    private var manager: PersistenceManager

    var appendOrEdit: (() -> Void)?
        
    private let bag = DisposeBag()
    
    init() {
        
        self.todos = []
        self.editedTodo = nil
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.context
        self.manager = PersistenceManager(context)
    }
    
    func fetchAllStoredTodos() {
        manager
            .fetchAllTodos()
            .bind(onNext: { [weak self] fetchResult in
                guard case .success(let todos) = fetchResult, !todos.isEmpty else { return }
                self?.todos = todos
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
        self.editedTodo = todo
    }
    
    func updateEdited(_ name: String) {
        self.editedTodo?.update(name)
    }
    
    func editTodo() {
        guard var editedTodo = editedTodo,
              let index = todos.firstIndex(where: { $0 == editedTodo }) else { return }
        
        if !editedTodo.name.isEmpty {
            manager
                .remove(todo: editedTodo)
                .flatMap { [unowned self] _ in self.manager.insert(todo: editedTodo) }
                .bind(onNext: { [weak self] insertResult in
                    guard case .success(let objectID) = insertResult else { return }
                    editedTodo.objectID = objectID
                    self?.todos[index] = editedTodo
                })
                .disposed(by: bag)
        } else {
            let removedTodo = todos[index]
            manager
                .remove(todo: removedTodo)
                .bind (onNext: { [weak self] removeResult in
                    guard case .success(_) = removeResult else { return }
                    self?.todos.remove(at: index)
                })
                .disposed(by: bag)
        }
    }
    
    func insertTodo() {
        guard var editedTodo = editedTodo, !editedTodo.name.isEmpty else { return }
        manager
            .insert(todo: editedTodo)
            .bind(onNext: { [weak self] insertResult in
                guard case .success(let objectID) = insertResult else { return }
                editedTodo.objectID = objectID
                self?.todos.insert(editedTodo, at: 0)
            })
            .disposed(by: bag)
    }
    
}

extension TodoList {
    
    func getTodos() -> [LocalTodo] {
        todos
    }
    
}
