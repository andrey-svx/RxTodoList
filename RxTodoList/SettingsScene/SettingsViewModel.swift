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
        let model = appDelegate.model
        
        let usernameObservable = model.username
            .asObservable()
            .share(replay: 1, scope: .whileConnected)
        
        self.title = usernameObservable
            .map {
                guard let username = $0 else { return "Log in or sign up" }
                return "\(username)"
            }
            .asDriver(onErrorJustReturn: "Username error")
        
        let logoutTapObservable = logoutTap.asObservable()
            .flatMap { [unowned model] _ in model.logout().materialize() }
            .filter {
                switch $0 {
                case .next(_): return true
                case .error(_): return false
                default: return false
                }
            }
            .map { _ -> String? in nil }
        
        self.logoutIsEnabled = Observable.of(logoutTapObservable, usernameObservable)
            .merge()
            .map { $0 == nil ? false : true }
            .asDriver(onErrorJustReturn: false)
        
        self.loginIsEnabled = usernameObservable
            .map { $0 == nil ? true : false }
            .asDriver(onErrorJustReturn: true)
        
        self.signupIsEnabled = usernameObservable
            .map { $0 == nil ? true : false }
            .asDriver(onErrorJustReturn: true)
        
        let loginTapObservable = loginTap.asObservable()
            .do(onNext: { [weak model] _ in model?.setForLogIn() })
        
        let signupTapObservable = signupTap.asObservable()
            .do(onNext: { [weak model] _ in model?.setForSignUp() })

        self.isBusy = model.isBusy
            .asDriver(onErrorJustReturn: false)
        
        self.destination = Observable.of(loginTapObservable, signupTapObservable)
            .merge()
            .map { Destination.route }

    }
    
}
