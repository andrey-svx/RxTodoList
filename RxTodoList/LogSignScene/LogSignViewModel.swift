import RxSwift
import RxCocoa
import Foundation

final class LogSignViewModel {
    
    let warning: Driver<String>
    let buttonTitle: Driver<String>
    
    let isBusy: Driver<Bool>
    
    let destination: Observable<Destination>
    
    init(
        usernameInput: Driver<String>,
        passwordInput: Driver<String>,
        logsignTap: Signal<()>,
        dismissTap: Signal<()>
    ) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let model = appDelegate.model
        
        let loginAndPassword = Driver.combineLatest(usernameInput, passwordInput)
        let logsignTapObservable = logsignTap.asObservable()
            .withLatestFrom(loginAndPassword)
            .flatMap { [unowned model] login, password in
                model
                    .logOrSign(login, password)
                    .materialize()
            }
            .share()
        
        self.warning = logsignTapObservable
            .filter {
                switch $0 {
                case .error(_): return true
                default: return false
                }
            }
            .map {
                switch $0 {
                case .error(let error): return error.localizedDescription
                default: return ""
                }
            }
            .startWith("")
            .asDriver(onErrorJustReturn: "Unknown error")
        
        let title = model.account.state == .loggingIn ? "Log in" : "Sign up"
        self.buttonTitle = Observable<String>.just(title)
            .asDriver(onErrorJustReturn: "Log or sign")
        
        self.isBusy = model.isBusy
            .asDriver(onErrorJustReturn: false)
        
        self.destination = Observable.of(
            logsignTapObservable
                .filter {
                    switch $0 {
                    case .next(_): return true
                    default: return false
                    }
                }
                .map { _ in () },
            dismissTap.asObservable()
        )
            .merge()
            .map { Destination.back }
        
    }
    
}
