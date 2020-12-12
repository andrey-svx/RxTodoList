import RxCocoa
import RxSwift
import UIKit

final class SettingsViewController: UIViewController, ViewModeled {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var logoutButton: UIButton!
    
    var viewModel: SettingsViewModel? = SettingsViewModel()
    
    private let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        logoutButton.rx
            .tap
            .subscribe { [weak self] _ in
                self?.route(to: LogSignViewController.self, with: LogSignViewModel())
            }
            .disposed(by: bag)
    }
    
}

extension SettingsViewController: ForwardRoutable {
    
    func route<D: ViewModeled>(to destinationType: D.Type, with viewModel: D.VM) {
        let identifier = String(describing: destinationType)
        guard let destinationViewController = storyboard?.instantiateViewController(withIdentifier: identifier) as? D else { return }
        destinationViewController.viewModel = viewModel
        present(destinationViewController, animated: true)
    }
    
}
