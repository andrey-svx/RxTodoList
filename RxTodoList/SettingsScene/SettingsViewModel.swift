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
        let loginDetailsObservable = Observable
            .of(user.loginDetails)
            .flatMap { $0 }
        
        let logoutTapObservable = logoutTap.asObservable()
            .flatMap { [unowned user] _ -> Observable<LoginDetails?> in
                user.logout()
            }
        
        let loginTapObservable = loginTap.asObservable()
            .flatMap{ _ -> Observable<LoginDetails?> in
                user.loginAs("current_user", "1234")
            }
        
        let signupTapObservable = signupTap.asObservable()
            .flatMap{ _ -> Observable<LoginDetails?> in
                user.loginAs("new_user", "1234")
            }
        
        self.title = loginDetailsObservable
            .map {
                if let username = $0?.username {
                    return "Logged in as \(username)"
                } else {
                    return "Log in or sign up"
                }
            }
            .asDriver(onErrorJustReturn: "")
        
        self.logoutIsEnabled = Observable.of(loginDetailsObservable, logoutTapObservable)
            .merge()
            .map { $0 == nil ? false : true }
            .asDriver(onErrorJustReturn: false)
        
        
        self.loginIsEnabled = Observable.of(loginDetailsObservable, loginTapObservable)
            .merge()
            .map { $0 == nil ? true : false }
            .asDriver(onErrorJustReturn: true)
        
        self.signupIsEnabled = Observable.of(loginDetailsObservable, signupTapObservable)
            .merge()
            .map { $0 == nil ? true : false }
            .asDriver(onErrorJustReturn: true)
    }
    
}
