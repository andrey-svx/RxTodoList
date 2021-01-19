import Foundation
import RxSwift

protocol AccountDelegate: AnyObject {
    
    var loginDetails: BehaviorSubject<LoginDetails?> { get }
    
    var account: Account { get }
    
    func update(loginDetails: LoginDetails?)
    
}

extension AccountDelegate {
    
    func update(loginDetails: LoginDetails?) {
        self.loginDetails.onNext(loginDetails)
    }
    
}
