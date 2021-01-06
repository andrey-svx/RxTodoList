import RxSwift
import UIKit

final class ItemViewController: UIViewController, Routable {

    @IBOutlet weak var textField: ItemTextField!
    @IBOutlet weak var saveButton: UIButton!
    private lazy var cancelButton: UIBarButtonItem = { [weak self] in
        self?.navigationItem.setHidesBackButton(true, animated: false)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: nil, action: nil)
        self?.navigationItem.leftBarButtonItem = cancelButton
        return cancelButton
    }()
    
    var viewModel: ItemViewModel?

    private let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = ItemViewModel(
            textInput: textField.rx.textInput.text.asDriver()
        )
        guard let viewModel = viewModel else {
            assertionFailure("Could not set Item VM!"); return
        }
    }
    
    
}
