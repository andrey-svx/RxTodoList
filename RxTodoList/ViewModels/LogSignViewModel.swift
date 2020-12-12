import RxSwift
import Foundation

final class LogSignViewModel: ViewModel {

    var warningString = BehaviorSubject<String>(value: "")
    
    var usernameInput: String = ""
    var passwordInput: String = ""
    
    func logIn(with loginDetails: LoginDetails) {
        
    }
    
    func signUp(with loginDetails: LoginDetails) {
        
    }
    
}
