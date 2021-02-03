import Foundation
import CoreData
import RxSwift

final class Model: TodoListDelegate, AccountDelegate {
    
    let todos = BehaviorSubject<[LocalTodo]>(value: [])
    internal var editedTodo: LocalTodo? = nil
    private(set) var initialEditedTodo: LocalTodo? = nil
    
    lazy var todoList: TodoList = {
        let list = TodoList()
        list.delegate = self
        return list
    }()

    let username = BehaviorSubject<String?>(value: nil)
    let isBusy = BehaviorSubject<Bool>(value: false)
    
    lazy var account: Account = {
        let account = Account()
        account.delegate = self
        return account
    }()
    
    func configure() {
        account.checkUpLogin()
        todoList.fetchAllTodos()
    }
    
    #if DEBUG
    deinit {
        print("Deinit: " + String(describing: self))
    }
    #endif
    
}

extension Model {
    
    func setForInserting() {
        todoList.state = .inserting
        todoList.setEdited(LocalTodo())
    }
    
    func setForEdititng(_ todo: LocalTodo) {
        initialEditedTodo = todo
        todoList.state = .editing
        todoList.setEdited(todo)
    }
    
    func updateEdited(_ name: String) {
        todoList.updateEdited(name)
    }
    
    func cancelAppendinOrEdinitg() {
        todoList.updateEdited(initialEditedTodo?.name ?? "")
        todoList.insertOrEdit()
        initialEditedTodo = nil
    }
    
    func updateTodoList() {
        todoList.insertOrEdit()
        initialEditedTodo = nil
    }
    
}

extension Model {
    
    func logout() -> Observable<Account.LoggingResult> {
        let todos = (try? self.todos.value()) ?? []
        return upload(todos)
            .flatMap { [unowned self] _ in self.account.logout() }
            .do(onNext: { [weak self] result in
                if case .success(_) = result {
                    self?.todoList.deleteAllTodos()
                }
            })
    }
    
    func logOrSign(_ username: String, _ password: String) -> Observable<Account.LoggingResult> {
        account
            .logOrSign(username, password)
            .flatMap { [unowned self] result -> Observable<(String?, [LocalTodo])> in
                if case .success(let name) = result {
                    return Observable<(String?, [LocalTodo])>
                        .zip(
                            Observable.of(name),
                            self.download()
                        ) { ($0, $1) }
                } else {
                    return Observable<(String?, [LocalTodo])>
                        .zip(
                            Observable<String?>.of(nil),
                            Observable<[LocalTodo]>.of([])
                        ) { ($0, $1) }
                }
            }
            .do { [unowned self] (name, todos) in
                self.todoList.deleteAllTodos()
                self.todoList.insertAllTodos(todos)
            }
            .map { name, _ in
                if let name = name {
                    return .success(name)
                } else {
                    return .failure(Account.Error.unknown)
                }
            }
    }
    
    func setForLogIn() {
        account.logOrSign = account.logIn
    }
    
    func setForSignUp() {
        account.logOrSign = account.signUp
    }
    
}

extension Model {
    
    func upload(_ todos: [LocalTodo]) -> Observable<Void> {
        isBusy.onNext(true)
        let fbTodos = todos.map { FirebaseLocalConverter.wrapToFirebase($0) }
        return account
            .uploadTodos(fbTodos)
            .observeOn(MainScheduler.instance)
            .do(onNext: { [weak self] _ in self?.isBusy.onNext(false) })
    }
    
    func download() -> Observable<[LocalTodo]> {
        isBusy.onNext(true)
        return account
            .downloadTodos()
            .map { $0.map { FirebaseLocalConverter.unwrapFromFirebase($0) } }
            .observeOn(MainScheduler.instance)
            .do(onNext: { [weak self] _ in self?.isBusy.onNext(false) })
    }
    
}

