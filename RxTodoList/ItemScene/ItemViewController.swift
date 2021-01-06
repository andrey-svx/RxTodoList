import RxSwift
import UIKit

final class ItemViewController: UIViewController, Routable {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    private lazy var cancelButton: UIBarButtonItem = { [weak self] in
        self?.navigationItem.setHidesBackButton(true, animated: false)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: nil, action: nil)
        self?.navigationItem.leftBarButtonItem = cancelButton
        return cancelButton
    }()

    private let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let viewModel = ItemViewModel(
            textInput: textField.rx
                .textInput
                .text
                .map { $0 ?? "" }
                .asDriver(onErrorJustReturn: ""),
            saveTap: saveButton.rx
                .tap
                .asSignal(),
            cancelTap: cancelButton.rx
                .tap
                .asSignal()
        )
        
        viewModel.text
            .drive(textField.rx.text)
            .disposed(by: bag)
        
        viewModel.destination
            .bind(onNext: { [weak self] destination in
                self?.back()
            })
            .disposed(by: bag)
        
        textField.becomeFirstResponder()
    }
    
    
}
