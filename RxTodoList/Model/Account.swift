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

    var logOrSign: ((String, String) -> Observable<AResult>)?
    
    weak var delegate: AccountDelegate?
    
    private let auth = Auth.auth()
    
    init() {
        
    }
    
    func checkUpLogin() {
        
        loginDetails = LoginDetails(email: "current-user", password: "1234")
    
    }
    
}

extension Account {
    
    func logout() -> Observable<AResult> {
        Observable<Void>.of(())
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .do(onNext: { [weak self] _ in
                self?.isBusy = true
                sleep(3)
                self?.loginDetails = nil
            })
        .map { [weak self] _ in
            self?.isBusy = false
            return .success(self?.loginDetails)
        }
    }
    
    func loginAs(_ email: String, _ password: String) -> Observable<AResult> {
        Observable<(String, String)>.of((email, password))
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .do(onNext: { [weak self] (email, password) in
                self?.isBusy = true
                sleep(3)
                self?.loginDetails = LoginDetails(email: email, password: password)
            })
        .map { [weak self] _ -> AResult in
            self?.isBusy = false
            return .success(self?.loginDetails)
        }
    }
    
    func signupAs(_ email: String, _ password: String) -> Observable<AResult> {
        Observable<(String, String)>.of((email, password))
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .do(onNext: { [weak self] (email, password) in
                self?.isBusy = true
                sleep(3)
                self?.loginDetails = LoginDetails(email: email, password: password)
            })
            .map { [weak self] _ -> AResult in
                self?.isBusy = false
                return .success(self?.loginDetails)
            }
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
