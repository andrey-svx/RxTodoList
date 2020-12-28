import Foundation
import RxSwift

class SettingsViewModel: ViewModel {
    
    private var user: User { (UIApplication.shared.delegate as! AppDelegate).user }
    
    let username = BehaviorSubject<String>(value: "")
    let titleString = BehaviorSubject<String>(value: "Logged in as %username")
    
    func logOut() {
        
    }
    
}
