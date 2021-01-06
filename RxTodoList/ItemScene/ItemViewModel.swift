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
        
        let initialText = user.getEdited()?.name ?? ""
            
        self.text = Observable
            .of(textInput.asObservable().skip(1), Observable<String>.just(initialText))
            .merge()
            .do(onNext: { [weak user] text in user?.updateEdited(text) })
            .asDriver(onErrorJustReturn: "")
        
        self.destination = Observable
            .of(
                saveTap,
                cancelTap
                    .do(onNext: { [weak user] _ in
                            user?.updateEdited(initialText)
                    })
            )
            .merge()
            .do(onNext: { [weak user] _ in user?.updateTodos() })
            .map { Destination.dummy }
    }

}

enum TextInputError: Error {
    
    case cancelled

}
