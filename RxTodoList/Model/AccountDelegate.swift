import Foundation
import RxSwift

protocol AccountDelegate: AnyObject {
    
    var loginDetails: BehaviorSubject<LoginDetails?> { get }
    var isBusy: BehaviorSubject<Bool> { get }
    var account: Account { get }
    
    func update(loginDetails: LoginDetails?)
    func update(isBusy: Bool)
    
}

extension AccountDelegate {
    
    func update(loginDetails: LoginDetails?) {
        self.loginDetails.onNext(loginDetails)
    }
    
    func update(isBusy: Bool) {
        self.isBusy.onNext(isBusy)
    }
    
}
