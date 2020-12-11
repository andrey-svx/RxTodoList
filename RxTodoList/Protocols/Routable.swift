import UIKit

protocol Routable where Self: ViewModeled {
    
    func route<D: ViewModeled>(to destinationType: D.Type, with viewModel: D.T)
    
    func routeBack()

}
