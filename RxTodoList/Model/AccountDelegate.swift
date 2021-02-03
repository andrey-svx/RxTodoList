import Foundation
import RxSwift

protocol AccountDelegate: AnyObject {
    
    var username: BehaviorSubject<String?> { get }
    var isBusy: BehaviorSubject<Bool> { get }
    var account: Account { get }
    
    func update(username: String?)
    func update(isBusy: Bool)
    
}

extension AccountDelegate {
    
    func update(username: String?) {
        self.username.onNext(username)
    }
    
    func update(isBusy: Bool) {
        self.isBusy.onNext(isBusy)
    }
    
}
