import Foundation
import CoreData
import RxSwift

extension Reactive where Base: NSManagedObjectContext {
    
    // TODO: Code DispatchQueue argument for safety
    
    func fetch<T>(_ request: NSFetchRequest<T>) -> Observable<[T]> {
        
        // TODO: Code async fetch
        
        Observable.create { observer -> Disposable in
            self.base.performAndWait {
                do {
                    let nsObjects = try self.base.fetch(request) 
                    observer.onNext(nsObjects)
                    observer.onCompleted()
                } catch {
                    observer.onError(NSManagedObjectContext.ReactiveError.fetch)
                }
            }
            return Disposables.create()
        }
    }
    
    func save() -> Observable<Void> {
        guard base.hasChanges else { return Observable.just(()) }
        return Observable.create { observer -> Disposable in
            let queue = DispatchQueue(label: "Save")
            queue.sync {
                self.base.perform {
                    do {
                        try self.base.save()
                        observer.onNext(())
                        observer.onCompleted()
                    } catch {
                        observer.onError(NSManagedObjectContext.ReactiveError.save)
                    }
                }                
            }
            return Disposables.create()
        }
    }
    
    func deleteAndSave<T: NSManagedObject>(_ object: T) -> Observable<Void> {
        Observable.create { observer -> Disposable in
            let queue = DispatchQueue(label: "Delete")
            queue.sync {
                self.base.perform {
                    do {
                        self.base.delete(object)
                        try self.base.save()
                        observer.onNext(())
                        observer.onCompleted()
                    } catch {
                        observer.onError(NSManagedObjectContext.ReactiveError.save)
                    }
                }
            }
            return Disposables.create()
        }
    }
    
    func deleteAll<T: NSManagedObject>(_ className: T.Type) -> Observable<Void> {
        let entityName = String(describing: className)
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        return Observable.create { observer -> Disposable in
            self.base.performAndWait {
                let queue = DispatchQueue(label: "DeleteAll")
                queue.sync {
                    do {
                        try self.base.execute(batchDeleteRequest)
                        observer.onNext(())
                        observer.onCompleted()
                    } catch {
                        observer.onError(NSManagedObjectContext.ReactiveError.batchDelete)
                    }
                }
            }
            return Disposables.create()
        }
    }
    
}

extension NSManagedObjectContext {
    
    enum ReactiveError: Swift.Error {
        
        case fetch
        case save
        case batchDelete
        case unknown
    
    }
    
}
