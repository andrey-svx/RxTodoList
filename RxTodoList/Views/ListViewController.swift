import RxCocoa
import RxRelay
import RxSwift
import UIKit

final class ListViewController: UITableViewController, ViewModeled {

    @IBOutlet weak var plusBarButtonItem: UIBarButtonItem!
    
    var viewModel: ListViewModel? = ListViewModel()
    
    private let bag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let viewModel = viewModel else {
            assertionFailure("Could not set VM!")
            return
        }
        navigationItem.title = "RxTodoList"
        
        tableView.dataSource = nil
        tableView.delegate = nil
        
    }
    
}

extension ListViewController: Routable { }
