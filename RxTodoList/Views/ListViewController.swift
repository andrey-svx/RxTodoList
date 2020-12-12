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
            assertionFailure("VM has not been set!"); return
        }
        navigationItem.title = "RxTodoList"
        setupTableView(viewModel)
        setupPlusButton(viewModel)
    }
    
    private func setupTableView(_ viewModel: ListViewModel) {
        setupCellForRowAt(viewModel)
        setupDidSelectRowAt(viewModel)
    }
    
    private func setupCellForRowAt(_ viewModel: ListViewModel) {
        tableView.dataSource = nil
        viewModel.todos
            .bind(to: tableView.rx.items) { (tableView, row, element) in
                let cell = tableView.dequeueReusableCell(withIdentifier: "TodoCell")!
                cell.textLabel?.text = "\(row + 1). \(element.name)"
                return cell
            }
            .disposed(by: bag)
    }
    
    private func setupDidSelectRowAt(_ viewModel: ListViewModel) {
        tableView.delegate = nil
        tableView.rx
            .modelSelected(Todo.self)
            .subscribe { [weak self] todo in
                guard let indexPath = self?.tableView.indexPathForSelectedRow else {
                    assertionFailure("Could not set indexPath for selected row")
                    return
                }
                self?.onDidSelectRow(at: indexPath)
            }
            .disposed(by: bag)
    }

    private func setupPlusButton(_ viewModel: ListViewModel) {
        plusBarButtonItem.rx
            .tap
            .subscribe(onNext: { [weak self] _ in
                self?.onTappedPlus()
            })
            .disposed(by: bag)
    }
    
}

extension ListViewController {
    
    private func onTappedPlus() {
        let itemViewModel = ItemViewModel()
        itemViewModel
            .item
            .subscribe(
                onNext: { [weak self] text in
                    self?.viewModel?.appendTodo(text: text)
                },
                onError: { _ in }
            )
            .disposed(by: bag)
        
        route(to: ItemViewController.self, with: itemViewModel)
    }
    
    private func onDidSelectRow(at indexPath: IndexPath) {
        let index = indexPath.row
        guard let itemViewModel = viewModel?.instantiateItemViewModel(forItemAt: index) else {
            assertionFailure("Could not instantiate ListViewModel")
            return
        }
        itemViewModel
            .item
            .subscribe(
                onNext: { [weak self] text in
                    self?.viewModel?.updateTodo(text: text, at: index)
                },
                onError: { _ in }
            )
            .disposed(by: bag)
        
        route(to: ItemViewController.self, with: itemViewModel)
        
    }
    
}

extension ListViewController: ForwardRoutable {
    
    func route<D: ViewModeled>(to destinationType: D.Type, with viewModel: D.VM) {
        let identifier = String(describing: destinationType)
        guard let destinationViewController = storyboard?.instantiateViewController(identifier: identifier) as? D else {
            assertionFailure("Destination View Controller has not been set!")
            return
        }
        destinationViewController.viewModel = viewModel
        navigationController?.pushViewController(destinationViewController, animated: true)
    }
        
}
