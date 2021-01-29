import Foundation
import RxSwift
import RxCocoa

class SettingsViewModel {
    
    let title: Driver<String>
    let logoutIsEnabled: Driver<Bool>
    let loginIsEnabled: Driver<Bool>
    let signupIsEnabled: Driver<Bool>
    let isBusy: Driver<Bool>
    
    let destination: Observable<Destination>
    
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
        
        self.title = loginDetailsObservable
            .map {
                if let username = $0?.email {
                    return "Logged in as \(username)"
                } else {
                    return "Log in or sign up"
                }
            }
            .asDriver(onErrorJustReturn: "")

        let logoutTapObservable = logoutTap.asObservable()
            .flatMap { [unowned user] _ -> Observable<Account.AResult> in
                user.logout()
            }
            .map { result -> LoginDetails? in
                if case .success(let details) = result {
                    return details
                } else {
                    return nil
                }
            }
        
        self.logoutIsEnabled = Observable.of(loginDetailsObservable, logoutTapObservable)
            .merge()
            .map { $0 == nil ? false : true }
            .asDriver(onErrorJustReturn: false)
        
        self.loginIsEnabled = loginDetailsObservable
            .map { $0 == nil ? true : false }
            .asDriver(onErrorJustReturn: true)
        
        self.signupIsEnabled = loginDetailsObservable
            .map { $0 == nil ? true : false }
            .asDriver(onErrorJustReturn: true)
        
        let loginTapObservable = loginTap.asObservable()
            .do(onNext: { [weak user] _ in user?.setForLogIn() })
            .map { Destination.route }
        
        let signupTapObservable = signupTap.asObservable()
            .do(onNext: { [weak user] _ in user?.setForSignUp() })
            .map { Destination.route }
        
        self.destination = Observable.of(loginTapObservable, signupTapObservable)
            .merge()
        
        self.isBusy = user.isBusy
            .asDriver(onErrorJustReturn: false)
        
    }
    
}
