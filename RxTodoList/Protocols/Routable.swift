import UIKit

protocol State { }

protocol Routable where Self: UIViewController {
    
    var state: State? { get set }
    
    func route<D: Routable>(to destinationType: D.Type, with state: State?)
    
    func back()

}

extension Routable {
    
    func route<D: Routable>(to destinationType: D.Type, with state: State? = nil) {
        let identifier = String(describing: destinationType)
        guard let destinationViewController = storyboard?.instantiateViewController(identifier: identifier) as? D else {
            assertionFailure("Could not set Destination VC!")
            return
        }
        destinationViewController.state = state
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
