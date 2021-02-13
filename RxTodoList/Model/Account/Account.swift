import Foundation
import RxSwift
import Firebase

final class Account {
    
    var state: State = .none
    
    private var loginDetails: LoginDetails? = nil {
        didSet { delegate?.update(username: loginDetails?.email) }
    }
    
    weak var delegate: AccountDelegate?
    
    private let auth = Auth.auth()
    private let dbRef = Database.database().reference()
    
    func checkUpLogin() {
        guard let currentUser = auth.currentUser,
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

    func logout() -> Observable<Void> {
        Observable<Void>.create { [weak self] observer in
            do {
                try self?.auth.signOut()
                observer.onNext(())
                observer.onCompleted()
            } catch (let error as NSError) {
                observer.onError(error)
            }
            return Disposables.create()
        }
        .do { [weak self] _ in self?.loginDetails = nil }
    }
    
    func logOrSign(_ email: String, _ password: String) -> Observable<String?> {
        switch state {
        case .loggingIn: return login(email, password)
        case .signingUp: return signup(email, password)
        default: fatalError("Can not call logOrSign(_:,_:) with this state")
        }
    }
    
    func login(_ username: String, _ password: String) -> Observable<String?> {
        Observable<User>.create { [weak self] observer in
            self?.auth.signIn(withEmail: username, password: password) { result, error in
                if let error = error as NSError?,
                   let authError = AuthErrorCode(rawValue: error.code) {
                    observer.onError(authError)
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
        .map { $0.email }
    }
    
    func signup(_ username: String, _ password: String) -> Observable<String?> {
        Observable<User>.create { [weak self] observer in
            self?.auth.createUser(withEmail: username, password: password) { result, error in
                if let error = error as NSError?,
                   let authError = AuthErrorCode(rawValue: error.code) {
                    observer.onError(authError)
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
        .map { $0.email }
    }
    
}

extension Account {
    
    typealias FirebaseTodo = [String: Any]
    
    func uploadTodos(_ todos: [FirebaseTodo]) -> Observable<Void> {
        Observable<Void>.create { [weak self] observable -> Disposable in
            guard let uid = self?.loginDetails?.uid else {
                observable.onError(NSError())
                return Disposables.create()
            }
            self?.dbRef
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
                observable.onError(NSError())
                return Disposables.create()
            }
            self?.dbRef
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

extension AuthErrorCode: Swift.Error, LocalizedError {
    
    public var errorDescription: String? {
        switch self {
        case .networkError: return "Network error occured"
        case .userNotFound: return "User not found"
        case .tooManyRequests: return "Too many requests"
        case .invalidEmail: return "The email address is malformed"
        case .userDisabled: return "The user account is disabled"
        case .wrongPassword: return "Wrong passowrd"
        case .emailAlreadyInUse: return "The email is already in use"
        case .keychainError: return "Keychain error"
        default: return "Unknown error"
        }
    }
    
}

extension NSError: LocalizedError {
    
    public var errorDescription: String? {
        "Error with code \(self.code)"
    }
    
}
