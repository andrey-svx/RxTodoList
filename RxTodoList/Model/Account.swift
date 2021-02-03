import Foundation
import RxSwift
import Firebase

final class Account {
    
    typealias LoggingResult = Result<String?, Error>
    
    var state: State = .none
    
    private var loginDetails: LoginDetails? = nil {
        didSet { delegate?.update(username: loginDetails?.email) }
    }
    
    var logOrSign: ((String, String) -> Observable<LoggingResult>) = { _, _ in
        fatalError("Did not set function!")
    }
    
    weak var delegate: AccountDelegate?
    
    private let authorization = Auth.auth()
    private let dbReference = Database.database().reference()
    
    func checkUpLogin() {
    
    }
    
    enum State {
        
        case loggingIn
        case signingUp
        case none
        
    }
    
}

extension Account {
    
    func logout() -> Observable<LoggingResult> {
        Observable<Void>.create { [weak self] observer in
            do {
                try self?.authorization.signOut()
                observer.onNext(())
                observer.onCompleted()
            } catch {
                observer.onError(error)
            }
            return Disposables.create()
        }
        .do { [weak self] _ in self?.loginDetails = nil }
        .map { .success((nil)) }
        .catchErrorJustReturn(.failure(Error.unknown))
    }
    
    func logIn(_ username: String, _ password: String) -> Observable<LoggingResult> {
        return Observable<User>.create { [weak self] observer in
            self?.authorization.signIn(withEmail: username, password: password) { result, error in
                if let error = error {
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
    
    func signUp(_ username: String, password: String) -> Observable<LoggingResult> {
        return Observable<User>.create { [weak self] observer in
            self?.authorization.createUser(withEmail: username, password: password) { result, error in
                if let error = error {
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
    
    func downloadTodos() -> Observable<[FirebaseTodo]> {
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
