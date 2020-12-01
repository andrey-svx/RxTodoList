import RxSwift
import UIKit

class ItemViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    lazy var cancelButton: UIBarButtonItem = { [weak self] in
        self?.navigationItem.setHidesBackButton(true, animated: false)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: nil, action: nil)
        self?.navigationItem.leftBarButtonItem = cancelButton
        return cancelButton
    }()
    
    var viewModel: ItemViewModel?

    let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let viewModel = viewModel else { assertionFailure("VM has not been set!"); return }
        let item = viewModel.item
        
        setTextField(with: viewModel)
        
        saveButton.rx
            .tap.bind(onNext: { [weak self] _ in
                item.onNext(self?.textField.text ?? "")
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: bag)
        
        cancelButton.rx
            .tap.bind(onNext: { [weak self] _ in
                item.onError(TodoInputError.cancelled)
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: bag)
    }
    
    func setTextField(with viewModel: ItemViewModel) {
        if viewModel.forEditing,
           let value = try? viewModel.item.value() {
            textField.text = value
        } else {
            textField.placeholder = "Type todo item here"
        }
        textField.becomeFirstResponder()
    }
    
}

