import Foundation
import RxSwift
import RxCocoa

class SettingsViewModel: ViewModel {
    
    let title: Driver<String>
    
    init() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let user = appDelegate.user
        
        self.title = user.loginDetails
            .map { $0 != nil ? "Logged in as \($0!.username)" : "Log in or signup" }
            .asDriver(onErrorJustReturn: "")
    }
    
}
