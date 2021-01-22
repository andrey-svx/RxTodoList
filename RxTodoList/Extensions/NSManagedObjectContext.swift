import Foundation
import CoreData

extension NSManagedObjectContext {
    
    func fetch<T>(_ request: NSFetchRequest<T>, completion: @escaping (([T], Error?) -> Void)) {
        
    }
    
    func save(_ completion: @escaping ((Void, Error?) -> Void)) {
        guard self.hasChanges else { completion((), nil); return }
        var token: NSObjectProtocol?
        token = NotificationCenter.default.addObserver(forName: .NSManagedObjectContextObjectsDidChange, object: self, queue: nil) { _ in
            completion((), nil)
            NotificationCenter.default.removeObserver(token!)
        }
        
        self.perform { [weak self] in
            do {
                try self?.save()
            } catch {
                completion((), NSManagedObjectContext.Error.save)
            }
        }
    }
    
    func deleteAndSave<T: NSManagedObject>(_ object: T, completion: @escaping ((Void, Error?) -> Void)) {
        save { [weak self] success, error in
            self?.perform {
                let queue = DispatchQueue(label: "DeleteOne")
                queue.sync { [weak self] in
                    self?.delete(object)
                    completion(success, error)
                }
            }
        }
    }
    
    func deleteAndSave<T: NSManagedObject>(_ objects: [T], completion: @escaping ((Void, Error?) -> Void)) {
        save { [weak self] success, error in
            self?.perform {
                let queue = DispatchQueue(label: "DeleteMany")
                queue.sync { [weak self] in
                    objects.forEach( { [weak self] in self?.delete($0) })
                    completion(success, error)
                }
            }
        }
    }
    
}

extension NSManagedObjectContext {
    
    enum Error: Swift.Error {
        
        case save
        case fetch
        
    }
    
}
