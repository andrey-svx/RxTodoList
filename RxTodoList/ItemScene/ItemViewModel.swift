import Foundation
import RxRelay
import RxCocoa
import RxSwift

final class ItemViewModel: ViewModel {
    
    enum Destination {
        
        case dummy
    
    }
    
    let text: Driver<String>
    let destination: Observable<Destination>
    
    init(
        textInput: Driver<String>,
        saveTap: Signal<()>,
        cancelTap: Signal<()>
    ) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let user = appDelegate.user
        
        let textInit = Observable.just(user.getEdited()?.name ?? "")
            
        self.text = Observable
            .of(textInput.asObservable().skip(1), textInit)
            .merge()
            .do(onNext: { [weak user] text in user?.updateEdited(text) })
            .asDriver(onErrorJustReturn: "")
        
        self.destination = saveTap.asObservable()
            .do(onNext: { [weak user] _ in user?.updateTodos() })
            .map { Destination.dummy }
    }

}

enum TextInputError: Error {
    
    case cancelled

}
