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
        
        let loginDetailsObservable = model.loginDetails
            .asObservable()
            .share(replay: 1, scope: .whileConnected)
        
        self.title = loginDetailsObservable
            .map {
                if let username = $0?.email {
                    return "\(username)"
                } else {
                    return "Log in or sign up"
                }
            }
            .asDriver(onErrorJustReturn: "")

        let logoutTapObservable = logoutTap.asObservable()
            .flatMap { [unowned model] in model.logout() }
            .map { result -> LoginDetails? in
                guard case .success(let details) = result else { return nil }
                return details
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
            .do(onNext: { [weak model] _ in model?.setForLogIn() })
            .map { Destination.route }
        
        let signupTapObservable = signupTap.asObservable()
            .do(onNext: { [weak model] _ in model?.setForSignUp() })
            .map { Destination.route }
        
        self.destination = Observable.of(loginTapObservable, signupTapObservable)
            .merge()
        
        self.isBusy = model.isBusy
            .asDriver(onErrorJustReturn: false)
        
    }
    
}
