import Foundation
import RxRelay
import RxSwift

final class ItemViewModel: ViewModel {
    
    let item = BehaviorSubject<String>(value: "")
    private let bag = DisposeBag()
    
    private(set) var forEditing: Bool = false
    
    convenience init(itemTitle: String) {
        self.init()
        forEditing = true
        item.onNext(itemTitle)
    }
    
}

