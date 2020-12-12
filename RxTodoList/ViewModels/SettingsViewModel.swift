import Foundation
import RxSwift

class SettingsViewModel: ViewModel {
    
    let username = BehaviorSubject<String>(value: "")
    let titleString = BehaviorSubject<String>(value: "Logged in as %username")
    
    func logOut() {
        
    }
    
}
