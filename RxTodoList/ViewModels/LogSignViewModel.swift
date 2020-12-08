import RxSwift
import Foundation

protocol LogSignViewModel: ViewModel {
    
    var titleString: String { get }
    var logsignButtonString: String { get }
    var warningString: String { get set }
    
    var usernameInputString: String { get set }
    var passwordInputString: String { get set }
    
}
