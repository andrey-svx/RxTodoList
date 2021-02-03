import Foundation
import RxSwift
import Firebase

final class Account {
    
    typealias AResult = Result<String?, Error>
    
    private var loginDetails: LoginDetails? = nil {
        didSet { delegate?.update(username: loginDetails?.email) }
    }
    
    private var isBusy = false {
        didSet { delegate?.update(isBusy: isBusy) }
    }

    var logOrSign: ((String, String) -> Observable<AResult>) = { _, _ in
        
        fatalError("Did not set function!")
    
    }
    
    weak var delegate: AccountDelegate?
    
    private let auth = Auth.auth()
    
    func checkUpLogin() {
        
//        loginDetails = LoginDetails(email: "Test user", uid: nil)
    
    }
    
}

extension Account {
    
    func logout() -> Observable<AResult> {
        Observable<Void>.create { [weak self] observer in
            do {
                try self?.auth.signOut()
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
    
    func logIn(_ username: String, _ password: String) -> Observable<AResult> {
        Observable<User>.create { [weak self] observer in
            self?.auth.signIn(withEmail: username, password: password) { result, error in
                if let error = error {
                    observer.onError(error); print(error.localizedDescription)
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
        .map { user -> AResult in .success(user.email) }
        .catchErrorJustReturn(.failure(Error.unknown))
    }
    
    func signUp(_ username: String, password: String) -> Observable<AResult> {
        Observable<User>.create { [weak self] observer in
            self?.auth.createUser(withEmail: username, password: password) { result, error in
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
    
    func uploadTodos(_ todos: Todo) -> Observable<Void> {
        Observable<Void>.just(())
    }
    
    func downloadTodos() -> Observable<[Todo]> {
        Observable.just([])
    }
    
}

extension Account {
    
    enum Error: Swift.Error {
        
        case unknown
        
    }
    
}
