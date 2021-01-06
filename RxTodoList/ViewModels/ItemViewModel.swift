import Foundation
import RxRelay
import RxCocoa
import RxSwift

final class ItemViewModel: ViewModel {
    
    init(
        textInput: Driver<String?>
    ) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let user = appDelegate.user
        
        
    }
    
    func saveItem() {
        
    }
    
    func cancelItem() {
        
    }
    
}

enum TextInputError: Error {
    
    case cancelled

}
