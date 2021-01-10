import Foundation
import RxRelay
import RxCocoa
import RxSwift

final class ItemViewModel: ViewModel {
    
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
  
        self.text = textInput.asObservable()
            .startWith(initialText)
            .do(onNext: { [weak user] text in user?.updateEdited(text) })
            .asDriver(onErrorJustReturn: "")
        
        let saveTapObservable = saveTap.asObservable()
            .do(onNext: { [weak user] _ in
                user?.updateTodos()
            })
            .map { Destination.back }
        
        let cancelTapObservable = cancelTap.asObservable()
            .do(onNext: { [weak user] _ in
                user?.updateEdited(initialText)
                user?.updateTodos()
            })
            .map { Destination.back }
        
        self.destination = Observable.of(saveTapObservable, cancelTapObservable)
            .merge()
    }

}
