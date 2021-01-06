import RxSwift
import RxCocoa
import UIKit

final class ListViewController: UITableViewController, Routable {

    @IBOutlet weak var plusBarButtonItem: UIBarButtonItem!
    
    var viewModel: ListViewModel?
    
    private let bag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = ListViewModel(
            addTaps: plusBarButtonItem.rx
                .tap
                .map { nil }
                .asSignal(onErrorJustReturn: nil),
            selectTaps: tableView.rx
                .modelSelected(Todo.self)
                .map { Todo?($0) }
                .asSignal(onErrorJustReturn: nil)
        )
        guard let viewModel = viewModel else {
            assertionFailure("Could not set VM!")
            return
        }
        navigationItem.title = "RxTodoList"
        
        tableView.dataSource = nil
        tableView.delegate = nil
        
        viewModel.todos
            .drive(tableView.rx.items) { (tableView, row, element) in
                let cell = tableView.dequeueReusableCell(withIdentifier: "TodoCell")!
                cell.textLabel?.text = "\(row + 1). \(element.name)"
                return cell
            }
            .disposed(by: bag)
        
        viewModel.destination
            .subscribe { [weak self] destination in
                self?.route(to: ItemViewController.self)
            }
            .disposed(by: bag)
    }
    
}
