import Foundation
import RxSwift
import RxCocoa

class SettingsViewModel: ViewModel {
    
    let title: Driver<String>
    let logoutIsEnabled: Driver<Bool>
    let loginIsEnabled: Driver<Bool>
    let signupIsEnabled: Driver<Bool>
    
    private let bag = DisposeBag()
    
    init(
        logoutTap: Signal<()>,
        loginTap: Signal<()>,
        signupTap: Signal<()>
    ) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let user = appDelegate.user
        
        self.title = user.loginDetails
            .map {
                if let username = $0?.username {
                    return "Logged in as \(username)"
                } else {
                    return "Log in or sign up"
                }
            }
            .asDriver(onErrorJustReturn: "")
        
        self.logoutIsEnabled = logoutTap.asObservable()
            .flatMap { [unowned user] _ -> Observable<LoginDetails?> in
                user.logout()
            }
            .map { $0 == nil ? false : true }
            .asDriver(onErrorJustReturn: false)
        
        self.loginIsEnabled = loginTap.asObservable()
            .flatMap{ _ -> Observable<LoginDetails?> in
                user.loginAs("current_user", "1234")
            }
            .map { $0 == nil ? true : false }
            .asDriver(onErrorJustReturn: true)
        
        self.signupIsEnabled = signupTap.asObservable()
            .flatMap{ _ -> Observable<LoginDetails?> in
                user.loginAs("new_user", "1234")
            }
            .map { $0 == nil ? true : false }
            .asDriver(onErrorJustReturn: true)
    }
    
}
