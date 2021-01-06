import RxCocoa
import RxSwift
import UIKit

final class LogSignViewController: UIViewController, Routable {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var logsignButton: UIButton!
    @IBOutlet weak var dismissButton: UIButton!
    
    var viewModel: LogSignViewModel?
    
    private let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let viewModel = viewModel else {
            assertionFailure("Could not set View Model")
            return
        }
    }
    
}
