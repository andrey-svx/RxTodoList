import CoreData
import RxSwift
import Foundation

class TodoList {
    
    var state: State = .none
    
    private var todos: [LocalTodo] {
        didSet { delegate?.update(todos: todos) }
    }
    
    private var editedTodo: LocalTodo? {
        didSet { delegate?.update(editedTodo: editedTodo) }
    }
    
    private var manager: PersistenceManager
    
    private let bag = DisposeBag()
    
    weak var delegate: TodoListDelegate?
    
    typealias TestPort = ([LocalTodo]) -> Void
    
    init() {
        
        self.todos = []
        self.editedTodo = nil
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.context
        self.manager = PersistenceManager(context)
        
    }
    
    func fetchAllStoredTodos(_ testPort: @escaping TestPort = { _ in }) {
        manager
            .fetchAllTodos()
            .observeOn(MainScheduler.instance)
            .bind(onNext: { [weak self] fetchResult in
                guard case .success(let todos) = fetchResult, !todos.isEmpty else { return }
                self?.todos = todos
                DispatchQueue.main.async { testPort(self?.todos ?? []) }
            })
            .disposed(by: bag)
    }
    
    func deleteAllStoredTodos(_ testPort: @escaping TestPort = { _ in }) {
        manager
            .removeAllTodos()
            .observeOn(MainScheduler.instance)
            .bind(onNext: { [weak self] deleteResult in
                guard case .success(_) = deleteResult else { return }
                self?.todos = []
                testPort(self?.todos ?? [])
            })
            .disposed(by: bag)

    }
    
    #if DEBUG
    deinit {
        print("Deinit: " + String(describing: Self.self))
    }
    #endif

}

extension TodoList {
    
    enum State {
        
        case inserting
        case editing
        case none
    
    }
    
    func appendOrEdit() {
        switch state {
        case .inserting: insertTodo()
        case .editing: editTodo()
        case .none: break
        }
    }
        
    func setEdited(_ todo: LocalTodo?) {
        self.editedTodo = todo
    }
    
    func updateEdited(_ name: String) {
        self.editedTodo?.update(name)
    }
    
    func editTodo(_ testPort: @escaping TestPort = { _ in }) {
        guard var editedTodo = editedTodo,
              let index = todos.firstIndex(where: { $0 == editedTodo })
        else { return }
        
        if !editedTodo.name.isEmpty {
            manager
                .remove(todo: editedTodo)
                .flatMap { [unowned self] _ in self.manager.insert(todo: editedTodo) }
                .observeOn(MainScheduler.instance)
                .bind(onNext: { [weak self] insertResult in
                    guard case .success(let objectID) = insertResult else { return }
                    editedTodo.objectID = objectID
                    self?.todos[index] = editedTodo
                    testPort(self?.todos ?? [])
                })
                .disposed(by: bag)
        } else {
            let removedTodo = todos[index]
            manager
                .remove(todo: removedTodo)
                .observeOn(MainScheduler.instance)
                .bind (onNext: { [weak self] removeResult in
                    guard case .success(_) = removeResult else { return }
                    self?.todos.remove(at: index)
                    testPort(self?.todos ?? [])
                })
                .disposed(by: bag)
        }
    }
    
    func insertTodo(_ testPort: @escaping TestPort = { _ in }) {
        guard var editedTodo = editedTodo, !editedTodo.name.isEmpty else { return }
        manager
            .insert(todo: editedTodo)
            .observeOn(MainScheduler.instance)
            .bind(onNext: { [weak self] insertResult in
                guard case .success(let objectID) = insertResult else { return }
                editedTodo.objectID = objectID
                self?.todos.insert(editedTodo, at: 0)
                testPort(self?.todos ?? [])
            })
            .disposed(by: bag)
    }
    
}
