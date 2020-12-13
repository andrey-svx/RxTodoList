import RxSwift
import Foundation

final class LogSignViewModel: ViewModel {
    
    private var user: User { (UIApplication.shared.delegate as! AppDelegate).user }

    var warningString = BehaviorSubject<String>(value: "")
    var usernameInput = BehaviorSubject<String>(value: "")
    var passwordInput = BehaviorSubject<String>(value: "")
    
    func logIn(with loginDetails: LoginDetails) {
        
    }
    
    func signUp(with loginDetails: LoginDetails) {
        
    }
    
}
