import UIKit

extension UITabBarController {
    
    public func prepareForRestart() {
        guard let viewControllers = viewControllers else { return }
        for (i, viewController) in viewControllers.enumerated()
        where i != selectedIndex {
            guard let navigationController = viewController as? UINavigationController else { continue }
            navigationController.popToRootViewController(animated: false)
        }
    }

}
