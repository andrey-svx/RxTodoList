import Foundation
import RxSwift
import CoreData

struct PersistenceClient {
    
    typealias PersistenceClientResult = Result<[(UUID, NSManagedObjectID)], Self.Error>
    
    private lazy var context: NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.context
    }()
    
    mutating func fetchTodos() -> Observable<PersistenceClientResult> {
        let request = StoredTodo.fetchRequest() as NSFetchRequest<StoredTodo>
                let sorter = NSSortDescriptor(key: "date", ascending: false)
                request.sortDescriptors = [sorter]
                request.returnsObjectsAsFaults = false
                return context.rx
                    .fetch(request)
                    .map {
                        let fetchedIDs = $0.map { storedTodo -> (UUID, NSManagedObjectID) in
                            let localTodo = LocalTodo(
                                storedTodo.name,
                                id: storedTodo.id,
                                date: storedTodo.date,
                                objectID: storedTodo.objectID
                            )
                            guard let objectID = localTodo.objectID else {
                                fatalError("Fetched Stired Todo does not have objectID")
                            }
                            return (localTodo.id, objectID)
                        }
                        return .success(fetchedIDs)
                    }
                    .catchErrorJustReturn(.failure(.unknown))
    }
    
    mutating func remove(todo: LocalTodo) -> Observable<Void> {
        guard let objectID = todo.objectID else { return Observable<Void>.error(Error.unknown) }
        let cdTodo = context.object(with: objectID)
        return context.rx
            .delete(cdTodo)
            .flatMap(context.rx.save)
    }
    
    mutating func insert(todo: LocalTodo) -> Observable<Void> {
        let cdTodo = StoredTodo(context: context)
        cdTodo.name = todo.name
        cdTodo.id = todo.id
        cdTodo.date = todo.date
    
        return context.rx
            .insert(cdTodo)
            .flatMap(context.rx.save)
    }
    
    enum Error: Swift.Error {
        case unknown
    }
    
}
