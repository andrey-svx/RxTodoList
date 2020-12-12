import UIKit

typealias Routable = ForwardRoutable & BackwardRoutable

protocol ForwardRoutable where Self: UIViewController {
    
    func route<D: ViewModeled>(to destinationType: D.Type, with viewModel: D.VM)

}

protocol BackwardRoutable {
    
    func back()
    
}
