import Foundation
import RxSwift
import CoreData

class PersistenceManager {
    
//    typealias PMFetchResult = Result<[LocalTodo], Self.Error>
//    typealias PMRemoveResult = Result<Void, Self.Error>
//    typealias PMInsertOneResult = Result<NSManagedObjectID, Self.Error>
//    typealias PMInsertManyResult = Result<[(UUID, NSManagedObjectID)], Self.Error>
    
    typealias PMFetchResult = Result<[LocalTodo], Error>
    typealias PMRemoveResult = Result<Void, Error>
    typealias PMInsertOneResult = Result<NSManagedObjectID, Error>
    typealias PMInsertManyResult = Result<[(UUID, NSManagedObjectID)], Error>
    
    private lazy var context: NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.context
    }()
    
    var imageData: Data?
    
    init() {
        let group = DispatchGroup()
        var data: Data?
        group.enter()
        DispatchQueue.global(qos: .userInitiated).async {
            let urlString = "https://upload.wikimedia.org/wikipedia/commons/3/39/E-burg_asv2019-05_img46_view_from_VysotSky.jpg"
            let imageURL = URL(string: urlString)!
            data = try! Data(contentsOf: imageURL)
            group.leave()
        }
        group.notify(queue: .main) { [weak self] in
            self?.imageData = data
        }
    }
    
    func fetchAllTodos() -> Observable<PMFetchResult> {
        let request = StoredTodo.fetchRequest() as NSFetchRequest<StoredTodo>
        let sorter = NSSortDescriptor(key: "date", ascending: false)
        request.sortDescriptors = [sorter]
        request.returnsObjectsAsFaults = false
        return context.rx
            .fetch(request)
            .map { storedTodos -> [LocalTodo] in
                storedTodos
                    .map { LocalTodo($0.name, id: $0.id, date: $0.date, objectID: $0.objectID) }
            }
            .map { .success($0) }
            .catchErrorJustReturn(.failure(.unknown))
    }
    
    func remove(todo: LocalTodo) -> Observable<PMRemoveResult> {
        guard let objectID = todo.objectID else { return Observable.just(.failure(.unknown)) }
        let cdTodo = context.object(with: objectID)
        return context.rx
            .deleteAndSave(cdTodo)
//            .flatMap(context.rx.save)
            .map { .success(()) }
            .catchErrorJustReturn(.failure(.unknown))
    }
    
    func removeAllTodos() -> Observable<PMRemoveResult> {
        return context.rx
            .deleteAll(StoredTodo.self)
            .map { .success(()) }
            .catchErrorJustReturn(.failure(.unknown))
    }
    
    func insert(todo: LocalTodo) -> Observable<PMInsertOneResult> {
        let storedTodo = StoredTodo(context: context)
        storedTodo.name = todo.name
        storedTodo.id = todo.id
        storedTodo.date = todo.date
        storedTodo.imageData = self.imageData
        
        return context.rx
            .save()
            .map { _ in .success(storedTodo.objectID) }
            .catchErrorJustReturn(.failure(.unknown))
    }
    
    func insert(todos: [LocalTodo]) -> Observable<PMInsertManyResult> {
        let storedTodos = todos
            .map { todo -> StoredTodo in
                let storedTodo = StoredTodo(context: context)
                storedTodo.name = todo.name
                storedTodo.id = todo.id
                storedTodo.date = todo.date
                
                storedTodo.imageData = self.imageData
                
                return storedTodo
            }
        
        return context.rx
            .save()
            .map { 
                let ids = todos.map { $0.id }
                let objectIDs = storedTodos.map { $0.objectID }
                let idsTuple = zip(ids, objectIDs)
                    .compactMap { $0 }
                return .success(idsTuple)
            }
            .catchErrorJustReturn(.failure(.unknown))
    }
    
    enum Error: Swift.Error {
        
        case unknown
    
    }
    
}
