import RxSwift
import RxCocoa
import Foundation

final class LogSignViewModel {
    
    enum Destination {
        
        case dummy
    
    }
    
    let email: Driver<String>
    let password: Driver<String>
    
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
        
        self.email = usernameInput.asObservable()
            .skip(2)
            .do { [weak model] text in model?.updateEmail(text) }
            .asDriver(onErrorJustReturn: "")
        
        self.password = passwordInput.asObservable()
            .skip(2)
            .do { [weak model] text in model?.updatePassword(text) }
            .asDriver(onErrorJustReturn: "")
        
        let logsignTapObservable = logsignTap.asObservable()
            .flatMap { [unowned model] _ in model.logOrSign() }
            .share()
        
        self.warning = logsignTapObservable
            .filter {
                if case .failure( _) = $0 {
                    return true
                } else {
                    return false
                }
            }
            .startWith(.success(nil))
            .map{
                if case .failure(let error) = $0 {
                    return error.localizedDescription
                } else {
                    return ""
                }
            }
            .asDriver(onErrorJustReturn: "Unknown Warning")
        
        self.isBusy = model.isBusy
            .asDriver(onErrorJustReturn: false)
        
        self.destination = Observable.of(
            logsignTapObservable
                .filter {
                    if case .success( _) = $0 {
                        return true
                    } else {
                        return false
                    }
                }
                .map { _ in () },
            dismissTap.asObservable()
        )
            .merge()
            .map { Destination.dummy }
        
    }
    
}
