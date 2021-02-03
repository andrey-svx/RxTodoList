import RxSwift
import RxCocoa
import Foundation

final class LogSignViewModel {
    
//    let email: Driver<String>
//    let password: Driver<String>
    
    let warning: Driver<String>
    
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
            .flatMap { [unowned model] login, password in model.logOrSign(login, password) }
            .share()
        
        self.warning = logsignTapObservable
            .withLatestFrom(logsignTapObservable)
            .filter {
                guard case .failure( _) = $0 else { return false }
                return true
            }
            .startWith(.success(nil))
            .map{
                guard case .failure(let error) = $0 else { return "" }
                return error.localizedDescription
            }
            .asDriver(onErrorJustReturn: "Unknown Warning")
        
        self.isBusy = model.isBusy
            .asDriver(onErrorJustReturn: false)
        
        self.destination = Observable.of(
            logsignTapObservable
                .filter {
                    guard case .success( _) = $0 else { return false }
                    return true
                }
                .map { _ in () },
            dismissTap.asObservable()
        )
            .merge()
            .map { Destination.back }
        
    }
    
}
