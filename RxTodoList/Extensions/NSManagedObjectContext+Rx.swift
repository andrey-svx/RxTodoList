import Foundation
import CoreData
import RxSwift

extension Reactive where Base: NSManagedObjectContext {
    
    func fetch<T>(_ request: NSFetchRequest<T>) -> Observable<[T]> {
        guard self.base.concurrencyType == .privateQueueConcurrencyType else {
            return Observable.error(NSManagedObjectContext.Error.queue)
        }
        return Observable.create { observer -> Disposable in
            self.base.performAndWait {
                do {
                    let nsObjects = try self.base.fetch(request) 
                    observer.onNext(nsObjects)
                    observer.onCompleted()
                } catch {
                    observer.onError(NSManagedObjectContext.Error.fetch)
                }
            }
            return Disposables.create()
        }
    }
    
    func save() -> Observable<Void> {
        guard self.base.concurrencyType == .privateQueueConcurrencyType else {
            return Observable.error(NSManagedObjectContext.Error.queue)
        }
        guard base.hasChanges else { return Observable.just(()) }
        return Observable.create { observer -> Disposable in
            self.base.performAndWait {
                do {
                    try self.base.save()
                    observer.onNext(())
                    observer.onCompleted()
                } catch {
                    observer.onError(NSManagedObjectContext.Error.save)
                }
            }
            return Disposables.create()
        }
    }
    
    func insert<T: NSManagedObject>(_ object: T) -> Observable<Void> {
        guard self.base.concurrencyType == .privateQueueConcurrencyType else {
            return Observable.error(NSManagedObjectContext.Error.queue)
        }
        return Observable.create { observer -> Disposable in
            self.base.performAndWait {
                self.base.insert(object)
                observer.onNext(())
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    func delete<T: NSManagedObject>(_ object: T) -> Observable<Void> {
        guard self.base.concurrencyType == .privateQueueConcurrencyType else {
            return Observable.error(NSManagedObjectContext.Error.queue)
        }
        return Observable.create { observer -> Disposable in
            self.base.performAndWait {
                self.base.delete(object)
                observer.onNext(())
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
    
}

extension NSManagedObjectContext {
    
    enum Error: Swift.Error {
        
        case queue
        case fetch
        case save
        case unknown
    
    }
    
}
