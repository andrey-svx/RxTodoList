import Foundation
import RxSwift

protocol AccountDelegate: AnyObject {
    
    var username: BehaviorSubject<String?> { get }
    var account: Account { get }
    
    func update(username: String?)
    
}

extension AccountDelegate {
    
    func update(username: String?) {
        self.username.onNext(username)
    }
    
}
