import Foundation
import RxSwift
import Firebase

final class Account {
    
    var state: State = .none
    
    private var loginDetails: LoginDetails? = nil {
        didSet { delegate?.update(username: loginDetails?.email) }
    }
    
    weak var delegate: AccountDelegate?
    
    private let authorization = Auth.auth()
    private let dbReference = Database.database().reference()
    
    func checkUpLogin() {
        guard let currentUser = authorization.currentUser,
              let email = currentUser.email else { return }
        loginDetails = LoginDetails(email: email, uid: currentUser.uid)
    }
    
    enum State {
        
        case loggingIn
        case signingUp
        case none
        
    }
    
}

extension Account {
    
    typealias LoggingResult = Result<String?, Error>
    
    func logout() -> Observable<LoggingResult> {
        Observable<Void>.create { [weak self] observer in
            do {
                try self?.authorization.signOut()
                observer.onNext(())
                observer.onCompleted()
            } catch (let error as NSError) {
                observer.onError(error)
            }
            return Disposables.create()
        }
        .do { [weak self] _ in self?.loginDetails = nil }
        .map { .success((nil)) }
        .catchErrorJustReturn(.failure(Error.unknown))
    }
    
    func logOrSign(_ email: String, _ password: String) -> Observable<LoggingResult> {
        switch state {
        case .loggingIn: return login(email, password)
        case .signingUp: return signup(email, password)
        default: return Observable<LoggingResult>.error(Error.unknown)
        }
    }
    
    func login(_ username: String, _ password: String) -> Observable<LoggingResult> {
        Observable<User>.create { [weak self] observer in
            self?.authorization.signIn(withEmail: username, password: password) { result, error in
                if let error = error as NSError? {
                    observer.onError(error)
                } else if let result = result {
                    observer.onNext(result.user)
                    observer.onCompleted()
                }
            }
            return Disposables.create()
        }
        .do(onNext: { [weak self] user in
            self?.loginDetails = LoginDetails(email: user.email!, uid: user.uid)
        })
        .map { user -> LoggingResult in .success(user.email) }
        .catchErrorJustReturn(.failure(Error.unknown))
    }
    
    func signup(_ username: String, _ password: String) -> Observable<LoggingResult> {
        Observable<User>.create { [weak self] observer in
            self?.authorization.createUser(withEmail: username, password: password) { result, error in
                if let error = error as NSError? {
                    observer.onError(error)
                } else if let result = result {
                    observer.onNext(result.user)
                    observer.onCompleted()
                }
            }
            return Disposables.create()
        }
        .do(onNext: { [weak self] user in
            self?.loginDetails = LoginDetails(email: user.email!, uid: user.uid)
        })
        .map { user in .success(user.email) }
        .catchErrorJustReturn(.failure(Error.unknown))
    }
    
}

extension Account {
    
    typealias FirebaseTodo = [String: Any]
    
    func uploadTodos(_ todos: [FirebaseTodo]) -> Observable<Void> {
        Observable<Void>.create { [weak self] observable -> Disposable in
            guard let uid = self?.loginDetails?.uid else {
                observable.onError(Error.unknown)
                return Disposables.create()
            }
            self?.dbReference
                .child("users")
                .child("\(uid)")
                .setValue(todos) { error, _ in
                    if let error = error {
                        observable.onError(error)
                    } else {
                        observable.onNext(())
                        observable.onCompleted()
                    }
            }
            return Disposables.create()
        }
    }
    
    func downloadTodosForAccount() -> Observable<[FirebaseTodo]> {
        Observable<[FirebaseTodo]>.create { [weak self] observable -> Disposable in
            guard let uid = self?.loginDetails?.uid else {
                observable.onError(Error.unknown)
                return Disposables.create()
            }
            self?.dbReference
                .child("users")
                .child("\(uid)")
                .observeSingleEvent(of: .value) { snapshot in
                    observable.onNext((snapshot.value as? [FirebaseTodo]) ?? [])
                    observable.onCompleted()
            }
            return Disposables.create()
        }
    }
    
}

extension Account {
    
    enum Error: Swift.Error {
        
        case unknown
        
    }
    
}
