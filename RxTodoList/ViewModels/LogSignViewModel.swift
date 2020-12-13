import RxSwift
import Foundation

final class LogSignViewModel: ViewModel {

    var warningString = BehaviorSubject<String>(value: "")
    var usernameInput = BehaviorSubject<String>(value: "")
    var passwordInput = BehaviorSubject<String>(value: "")
    
    func logIn(with loginDetails: LoginDetails) {
        
    }
    
    func signUp(with loginDetails: LoginDetails) {
        
    }
    
}
