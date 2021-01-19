import Foundation
import RxSwift

class Account {
    
    weak var delegate: AccountDelegate?
    
    private var loginDetails: LoginDetails? {
        didSet { delegate?.update(loginDetails: loginDetails) }
    }
    
    var logOrSign: ((String, String) -> Observable<LoginDetails?>)?
    
    init() {
        
    }
    
    func checkUpLogin() {
        loginDetails = LoginDetails(username: "current-user", password: "1234")
    }
    
    func logout() -> Observable<LoginDetails?> {
        Observable<LoginDetails?>.just(nil)
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .do(onNext: { [weak self] _ in sleep(1); self?.loginDetails = nil })
            .map { [weak self] _ in self?.loginDetails }
    }
    
    func loginAs(_ username: String, _ password: String) -> Observable<LoginDetails?> {
        Observable<(String, String)>
            .of((username, password))
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .do(onNext: { [weak self] (username, password) in
                    sleep(1)
                    self?.loginDetails = LoginDetails(username: username, password: password)
            })
            .map { [weak self] _ in self?.loginDetails }
    }
    
    func signupAs(_ username: String, _ password: String) -> Observable<LoginDetails?> {
        Observable<(String, String)>
            .of((username, password))
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .do(onNext: { [weak self] (username, password) in
                    sleep(1)
                    self?.loginDetails = LoginDetails(username: username, password: password)
            })
            .map { [weak self] _ in self?.loginDetails }
    }
    
}
