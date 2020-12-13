import Foundation
import RxRelay
import RxSwift

final class ItemViewModel: ViewModel {
    
    let itemInput = BehaviorSubject<String>(value: "")
    let item = BehaviorSubject<String>(value: "")
    
    private let bag = DisposeBag()
    
    private(set) var forEditing: Bool = false
    
    convenience init(itemTitle: String) {
        self.init()
        forEditing = true
        item.onNext(itemTitle)
    }
    
    func updateItem() {
        print(try! itemInput.value())
        item.onNext(try! itemInput.value())
    }
    
    func cancelItem() {
        item.onError(TextInputError.cancelled)
    }
    
}
