import Foundation
import RxSwift
import Firebase

final class Account {
    
    typealias AResult = Result<LoginDetails?, Error>
    
    private var loginDetails: LoginDetails? = nil {
        didSet { delegate?.update(loginDetails: loginDetails) }
    }
    
    private var isBusy = false {
        didSet { delegate?.update(isBusy: isBusy) }
    }

    var logOrSign: (() -> Observable<AResult>) = {
        fatalError("Did not set function!")
    }
    
    weak var delegate: AccountDelegate?
    
    private let auth = Auth.auth()
    
    init() {
        
    }
    
    func checkUpLogin() {
//        loginDetails = LoginDetails(email: "Test user", password: "123456", uid: nil)
    }
    
}

extension Account {
    
    func updateEmail(_ email: String) {
        if loginDetails == nil {
            loginDetails = LoginDetails()
        }
        loginDetails?.email = email
    }
    
    func updatePassword(_ password: String) {
        if loginDetails == nil {
            loginDetails = LoginDetails()
        }
        loginDetails?.password = password
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
        .map { [weak self] _ in .success(self?.loginDetails) }
        .catchErrorJustReturn(.failure(Error.unknown))
    }
    
    func logIn() -> Observable<AResult> {
        Observable<User>.create { [weak self] observer in
            self?.auth.signIn(
                withEmail: self?.loginDetails?.email ?? "",
                password: self?.loginDetails?.password ?? ""
            ) { result, error in
                if let error = error {
                    observer.onError(error); print(error.localizedDescription)
                } else if let result = result {
                    observer.onNext(result.user)
                    observer.onCompleted()
                }
            }
            return Disposables.create()
        }
        .do(
            onNext: { [weak self] user in self?.loginDetails?.uid = user.uid },
            onError: { [weak self] _ in self?.loginDetails = nil }
        )
        .map { [weak self] _ in .success(self?.loginDetails) }
        .catchErrorJustReturn(.failure(Error.unknown))
    }
    
    func signUp() -> Observable<AResult> {
        Observable<User>.create { [weak self] observer in
            self?.auth.createUser(
                withEmail: self?.loginDetails?.email ?? "",
                password: self?.loginDetails?.password ?? ""
            ) { result, error in
                if let error = error {
                    observer.onError(error)
                } else if let result = result {
                    observer.onNext(result.user)
                    observer.onCompleted()
                }
            }
            return Disposables.create()
        }
        .do(
            onNext: { [weak self] user in self?.loginDetails?.uid = user.uid },
            onError: { [weak self] _ in self?.loginDetails = nil }
        )
        .map { [weak self] _ in .success(self?.loginDetails) }
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
