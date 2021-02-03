import Foundation
import RxCocoa
import RxSwift

final class ItemViewModel {
    
    let text: Driver<String>
    
    let destination: Observable<Destination>
    
    init(
        textInput: Driver<String>,
        saveTap: Signal<()>,
        cancelTap: Signal<()>
    ) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let model = appDelegate.model
        
        let initialText = model.initialEditedTodo?.name ?? ""
        
        self.text = Observable.just(initialText)
            .asDriver(onErrorJustReturn: "")
        
        let saveTapObservable = saveTap.asObservable()
            .withLatestFrom(textInput)
            .do { [weak model] text in
                model?.updateEdited(text)
                model?.updateTodoList()
            }
            .map { _ in Destination.back }
        
        let cancelTapObservable = cancelTap.asObservable()
            .do { [weak model] _ in model?.cancelAppendinOrEdinitg() }
            .map { Destination.back }
        
        self.destination = Observable.of(saveTapObservable, cancelTapObservable)
            .merge()
    }

}
