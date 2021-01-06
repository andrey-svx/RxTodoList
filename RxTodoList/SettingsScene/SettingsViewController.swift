import RxCocoa
import RxSwift
import UIKit

final class SettingsViewController: UIViewController, Routable {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var logoutButton: UIButton!
    
    var viewModel: SettingsViewModel?
    
    private let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = SettingsViewModel()
        guard let viewModel = viewModel else {
            assertionFailure("Could not set View Model")
            return
        }
        viewModel.title
            .drive(titleLabel.rx.text)
            .disposed(by: bag)
        
    }
    
}
