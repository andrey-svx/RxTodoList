import Foundation
import RxRelay
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
  
        self.text = textInput.asObservable()
            .skip(2)
            .startWith(initialText)
            .do { [weak model] text in model?.updateEdited(text) }
            .asDriver(onErrorJustReturn: "")
        
        let saveTapObservable = saveTap.asObservable()
            .do { [weak model] _ in model?.updateTodoList() }
            .map { Destination.back }
        
        let cancelTapObservable = cancelTap.asObservable()
            .do { [weak model] _ in model?.cancelAppendinOrEdinitg() }
            .map { Destination.back }
        
        self.destination = Observable.of(saveTapObservable, cancelTapObservable)
            .merge()
    }

}
