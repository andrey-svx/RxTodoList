import UIKit

protocol Routable where Self: UIViewController {
    
    func route<D: ViewModeled>(to destinationType: D.Type, with viewModel: D.VM)
    
    func back()

}

extension Routable {
    
    func route<D: ViewModeled>(to destinationType: D.Type, with viewModel: D.VM) {
        let identifier = String(describing: destinationType)
        guard let destinationViewController = storyboard?.instantiateViewController(identifier: identifier) as? D else {
            assertionFailure("Could not set Destination VC!")
            return
        }
        destinationViewController.viewModel = viewModel
        if let navigationController = self.navigationController {
            navigationController.pushViewController(destinationViewController, animated: true)
        } else {
            self.present(destinationViewController, animated: true)
        }
    }
    
    func back() {
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        } else {
            self.dismiss(animated: true)
        }
    }
    
}
