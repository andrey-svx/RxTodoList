import UIKit

protocol ViewModeled where Self: UIViewController {
    
    associatedtype VM: ViewModel
    
    var viewModel: VM? { get set }
    
}
