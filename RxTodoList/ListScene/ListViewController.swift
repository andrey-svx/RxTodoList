import RxSwift
import RxCocoa
import UIKit

final class ListViewController: UITableViewController, Routable {

    @IBOutlet weak var plusBarButtonItem: UIBarButtonItem!
    
    private let bag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "RxTodoList"
        tableView.dataSource = nil
        tableView.delegate = nil

        let viewModel = ListViewModel(
            addTap: plusBarButtonItem.rx
                .tap
                .asSignal(),
            selectTap: tableView.rx
                .modelSelected(LocalTodo.self)
                .asSignal()
        )
        
        viewModel.todos
            .drive(tableView.rx.items) { (tableView, row, element) in
                let cell = tableView.dequeueReusableCell(withIdentifier: "TodoCell")!
                cell.textLabel?.text = "\(row + 1). \(element.name)"
                return cell
            }
            .disposed(by: bag)
        
        viewModel.destination
            .observeOn(MainScheduler.instance)
            .bind { [weak self] destination in self?.route(to: ItemViewController.self) }
            .disposed(by: bag)
    }
    
}
