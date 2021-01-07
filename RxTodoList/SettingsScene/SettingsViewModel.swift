import Foundation
import RxSwift
import RxCocoa

class SettingsViewModel: ViewModel {
    
    let title: Driver<String>
    let logoutIsEnabled: Driver<Bool>
    let loginIsEnabled: Driver<Bool>
    let signupIsEnabled: Driver<Bool>
    
    init(logoutTap: Signal<()>) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let user = appDelegate.user
        
        self.title = user.loginDetails
            .map { $0 != nil ? "Logged in as \($0!.username)" : "Log in or signup" }
            .asDriver(onErrorJustReturn: "")
        
        self.logoutIsEnabled = user.loginDetails
            .map { $0 != nil ? true : false }
            .asDriver(onErrorJustReturn: false)
        
        self.loginIsEnabled = user.loginDetails
            .map { $0 != nil ? false : true }
            .asDriver(onErrorJustReturn: true)
        
        self.signupIsEnabled = user.loginDetails
            .map { $0 != nil ? false : true }
            .asDriver(onErrorJustReturn: true)
    }
    
}
