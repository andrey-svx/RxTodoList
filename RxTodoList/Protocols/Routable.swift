import UIKit

protocol Routable where Self: UIViewController {
    
    func route<D: UIViewController>(to destinationType: D.Type)
    
    func back()

}

extension Routable {
    
    func route<D: UIViewController>(to destinationType: D.Type) {
        let identifier = String(describing: destinationType)
        guard let destinationViewController = storyboard?.instantiateViewController(identifier: identifier) as? D else {
            assertionFailure("Could not set Destination VC!")
            return
        }
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
