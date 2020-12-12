import RxSwift
import Foundation

final class LogSignViewModel: ViewModel {

    var warningString = BehaviorSubject<String>(value: "")
    
    var usernameInputString: String = ""
    var passwordInputString: String = ""
    
}
