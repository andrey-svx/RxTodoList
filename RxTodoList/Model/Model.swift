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
    
    func setForLogIn() {
        account.state = .loggingIn
    }
    
    func setForSignUp() {
        account.state = .signingUp
    }
    
    func logout() -> Observable<Void> {
        isBusy.onNext(true)
        let todos = (try? self.todos.value()) ?? []
        return upload(todos)
            .flatMap(account.logout)
            .do(onNext: { [weak self] _ in
                    self?.todoList.deleteAllTodos()
            })
            .do(
                onNext: { [weak self] _ in self?.isBusy.onNext(false) },
                onError: { [weak self] _ in self?.isBusy.onNext(false) }
            )
    }
    
    func logOrSign(_ username: String, _ password: String) -> Observable<String?> {
        isBusy.onNext(true)
        return account
            .logOrSign(username, password)
            .flatMap { [unowned self] name in self.zipLogOrSignResultWithTodos(name) }
            .do(onNext: { [weak self] (name, todos) in
                self?.todoList.deleteAllTodos()
                self?.todoList.insertAllTodos(todos)
            })
            .map { name, _ in name }
            .do(
                onNext: { [weak self] _ in self?.isBusy.onNext(false) },
                onError: { [weak self] _ in self?.isBusy.onNext(false) }
            )
    }
    
}

extension Model {
    
    private func upload(_ todos: [LocalTodo]) -> Observable<Void> {
        isBusy.onNext(true)
        let fbTodos = todos.map(FirebaseLocalConverter.wrapToFirebase)
        return account
            .uploadTodos(fbTodos)
            .observeOn(MainScheduler.instance)
            .do(
                onNext: { [weak self] _ in self?.isBusy.onNext(false) },
                onError: { [weak self] _ in self?.isBusy.onNext(false) }
            )
    }
    
    private func download() -> Observable<[LocalTodo]> {
        isBusy.onNext(true)
        return account
            .downloadTodosForAccount()
            .map { $0.map(FirebaseLocalConverter.unwrapFromFirebase) }
            .observeOn(MainScheduler.instance)
            .do(
                onNext: { [weak self] _ in self?.isBusy.onNext(false) },
                onError: { [weak self] _ in self?.isBusy.onNext(false) }
            )
    }
    
    private func zipLogOrSignResultWithTodos(_ name: String?) -> Observable<(String?, [LocalTodo])> {
        if let name = name {
            return Observable<(String?, [LocalTodo])>.zip(Observable.of(name),self.download()) { ($0, $1) }
        } else {
            let value = (try? self.todos.value()) ?? []
            return Observable<(String?, [LocalTodo])>.zip(Observable<String?>.of(nil), Observable<[LocalTodo]>.of(value)) { ($0, $1) }
        }
    }
    
}

