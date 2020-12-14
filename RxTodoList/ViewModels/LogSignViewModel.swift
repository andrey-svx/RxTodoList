import RxSwift
import Foundation

final class LogSignViewModel: ViewModel {
    
    private var user: User { (UIApplication.shared.delegate as! AppDelegate).user }
    private var userSubject = BehaviorSubject<User>(value: User())

    var warningString = BehaviorSubject<String>(value: "")
    var usernameInput = BehaviorSubject<String>(value: "")
    var passwordInput = BehaviorSubject<String>(value: "")
    
    func login(with userDetails: UserDetails) {
        
    }
    
    func signup(with userDetails: UserDetails) {
        
    }
    
}
