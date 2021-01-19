import RxSwift
import RxCocoa
import Foundation

final class LogSignViewModel {
    
    enum Destination {
        case dummy
    }
    
    let warning: Driver<String>
    let warningIsHidden: Driver<Bool>
    
    let destination: Observable<Destination>
    
    init(
        usernameInput: Driver<String?>,
        passwordInput: Driver<String?>,
        logsignTap: Signal<()>,
        dismissTap: Signal<()>
    ) {
        self.warningIsHidden = Observable.just(true)
            .asDriver(onErrorJustReturn: false)
        
        self.warning = Observable.just("No warning for now")
            .asDriver(onErrorJustReturn: "Empty")
        
        self.destination = Observable.of(logsignTap.asObservable(), dismissTap.asObservable())
            .merge()
            .map { Destination.dummy }
    }
    
}
