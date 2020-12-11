import UIKit

protocol ViewModeled where Self: UIViewController {
    
    associatedtype T: ViewModel
    
    var viewModel: T? { get set }
    
}
