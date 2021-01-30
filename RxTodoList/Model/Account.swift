import Foundation
import RxSwift
import Firebase

class Account {
    
    typealias AResult = Result<LoginDetails?, Error>
    
    weak var delegate: AccountDelegate?
    
    private var loginDetails: LoginDetails? = nil {
        didSet { delegate?.update(loginDetails: loginDetails) }
    }
    
    var logOrSign: ((String, String) -> Observable<AResult>)?
    
    private var isBusy = false {
        didSet { delegate?.update(isBusy: isBusy) }
    }
    
    init() {
        
    }
    
    func checkUpLogin() {
        loginDetails = LoginDetails(email: "current-user", password: "1234")
    }
    
}

extension Account {
    
    func logout() -> Observable<AResult> {
        Observable<LoginDetails?>.just(nil)
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .do(onNext: { [weak self] _ in
                self?.isBusy = true
                sleep(3)
                self?.loginDetails = nil
                self?.isBusy = false
            })
            .map { [weak self] _ -> AResult in
                .success(self?.loginDetails)
            }
    }
    
    func loginAs(_ email: String, _ password: String) -> Observable<AResult> {
        Observable<(String, String)>.of((email, password))
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .do(onNext: { [weak self] (email, password) in
                sleep(3)
                self?.loginDetails = LoginDetails(email: email, password: password)
            })
            .map { [weak self] _ -> AResult in
                .success(self?.loginDetails)
            }
    }
    
    func signupAs(_ email: String, _ password: String) -> Observable<AResult> {
        Observable<(String, String)>.of((email, password))
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .do(onNext: { [weak self] (email, password) in
                sleep(3)
                self?.loginDetails = LoginDetails(email: email, password: password)
            })
            .map { [weak self] _ -> AResult in
                .success(self?.loginDetails)
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
