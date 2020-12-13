import Foundation
import RxRelay
import RxSwift

final class ItemViewModel: ViewModel {

    let itemInput: BehaviorSubject<String>
    let item: BehaviorSubject<String>
    
    private let bag = DisposeBag()
    
    private(set) var forEditing: Bool = false
    
    init() {
        self.itemInput = BehaviorSubject<String>(value: "")
        self.item = BehaviorSubject<String>(value: "")
    }
    
    convenience init(itemTitle: String) {
        self.init()
        self.forEditing = true
        self.itemInput.onNext(itemTitle)
        self.item.onNext(try! itemInput.value())
    }
    
    func saveItem() {
        item.onNext(try! itemInput.value())
    }
    
    func cancelItem() {
        item.onError(TextInputError.cancelled)
    }
    
}
