import XCTest
import CoreData
import RxSwift
import RxCocoa
import RxRelay
import RxBlocking

@testable
import RxTodoList

class NSManagedObjectContext_RxTests: XCTestCase {
    
    lazy var context: NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.context
    }()

    override func setUpWithError() throws {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "StoredTodo")
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        context.performAndWait {
            try! self.context.execute(batchDeleteRequest)
        }
    }

    override func tearDownWithError() throws {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "StoredTodo")
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        context.performAndWait {
            try! self.context.execute(batchDeleteRequest)
        }
    }
    
    func test_fetch() throws {
        
        let testCDTodos: [StoredTodo] = ["Clean the apt",
                                     "Learn to code",
                                     "Call mom",
                                     "Do the workout",
                                     "Call customers"]
            .map { name -> LocalTodo in
                sleep(1)
                return LocalTodo(name)
            }
            .map {
                let cdTodo = StoredTodo(context: context)
                cdTodo.name = $0.name
                cdTodo.id = $0.id
                cdTodo.date = $0.date
                return cdTodo
            }

        context.performAndWait {
            do {
                testCDTodos.forEach(context.insert(_:))
                try context.save()
            } catch {
                print(error)
            }
        }
        
        let request = StoredTodo.fetchRequest() as NSFetchRequest<StoredTodo>
        let sort = NSSortDescriptor(key: "date", ascending: true)
        request.sortDescriptors = [sort]
        request.returnsObjectsAsFaults = false
        let fetchedCDTodos = try! context.rx
            .fetch(request)
            .toBlocking()
            .first()!
        
        XCTAssertEqual(fetchedCDTodos, testCDTodos)
        
    }
    
    func test_save() throws {
        
        let testCDTodos = ["Test todo",
                           "Another test todo"]
            .map { LocalTodo($0) }
            .map { todo -> StoredTodo in
                let cdTodo = StoredTodo(context: context)
                cdTodo.name = todo.name
                cdTodo.date = todo.date
                cdTodo.id = todo.id
                return cdTodo
            }
        
        context.rx
            .save()
            .bind(onNext: { _ in
                
                self.context.performAndWait {
                    do {
                        let request = StoredTodo.fetchRequest() as NSFetchRequest<StoredTodo>
                        let sort = NSSortDescriptor(key: "date", ascending: true)
                        request.sortDescriptors = [sort]
                        request.returnsObjectsAsFaults = false
                        let fetchedCDTodos = try self.context.fetch(request)
                        
                        XCTAssertEqual(testCDTodos, fetchedCDTodos)
                        
                    } catch {
                        print(error)
                    }
                }
                
            })
            .disposed(by: DisposeBag())
        
    }
    
    func test_insert() throws {
        
        let bag = DisposeBag()
        
        let testCDTodo = ["Test todo"]
            .map { LocalTodo($0) }
            .map { todo -> StoredTodo in
                let cdTodo = StoredTodo(context: context)
                cdTodo.name = todo.name
                cdTodo.date = todo.date
                cdTodo.id = todo.id
                return cdTodo
            }
            .first!
        
        context.performAndWait {
            do {
                context.insert(testCDTodo)
                try self.context.save()
            } catch {
                print(error)
            }
        }
        
        let insertedCDTodo = ["Inserted todo"]
            .map { LocalTodo($0) }
            .map { todo -> StoredTodo in
                let cdTodo = StoredTodo(context: context)
                cdTodo.name = todo.name
                cdTodo.date = todo.date
                cdTodo.id = todo.id
                return cdTodo
            }
            .first!
        
        context.rx
            .insert(insertedCDTodo)
            .flatMap { _ -> Observable<Void> in
                return self.context.rx
                .save()
            }
            .bind(onNext: { _ in
                let request = StoredTodo.fetchRequest() as NSFetchRequest<StoredTodo>
                let sort = NSSortDescriptor(key: "date", ascending: true)
                request.sortDescriptors = [sort]
                request.returnsObjectsAsFaults = false
                self.context.performAndWait {
                    do {
                        let fetchedCDTodos = try self.context.fetch(request)
                        
                        XCTAssertEqual(fetchedCDTodos, [testCDTodo, insertedCDTodo])
                        
                    } catch {
                        print(error)
                    }
                }
            })
            .disposed(by: bag)
        
        
        
    }
    
    func test_delete() throws {
        
        let testCDTodos = ["Test todo",
                           "Deleted todo"]
            .map { LocalTodo($0) }
            .map { todo -> StoredTodo in
                let cdTodo = StoredTodo(context: context)
                cdTodo.name = todo.name
                cdTodo.date = todo.date
                cdTodo.id = todo.id
                return cdTodo
            }
        
        let bag = DisposeBag()
        
        context.rx
            .save()
            .bind(onNext: { _ in })
            .disposed(by: bag)
            
            context.rx
                .delete(testCDTodos[1])
                .flatMap { _ -> Observable<Void> in
                    return self.context.rx
                    .save()
                }
                .bind(onNext: { _ in
                    let request = StoredTodo.fetchRequest() as NSFetchRequest<StoredTodo>
                    let sort = NSSortDescriptor(key: "date", ascending: true)
                    request.sortDescriptors = [sort]
                    request.returnsObjectsAsFaults = false
                    self.context.performAndWait {
                        do {
                            let fetchedCDTodos = try self.context.fetch(request)
                            
                            XCTAssertEqual(fetchedCDTodos, [testCDTodos[0]])
                            
                        } catch {
                            print(error)
                        }
                    }
                    
                })
                .disposed(by: bag)
        
        
    }
    
    func test_deleteAll() throws {
        let testEntities = ["First entity",
                            "Second entity",
                            "Third entity"]
            .map { name -> TestStoredClass in
                sleep(1)
                let entity = TestStoredClass(context: self.context)
                entity.name = name
                entity.date = Date()
                return entity
            }
        context.performAndWait{
            testEntities.forEach(context.insert(_:))
            try! context.save()
        }
        
        context.rx
            .deleteAll(TestStoredClass.self)
            .bind(onNext: { _ in
                let request = TestStoredClass.fetchRequest() as NSFetchRequest<TestStoredClass>
                self.context.performAndWait {
                    do {
                        let fetchedEntities = try self.context.fetch(request)

                        XCTAssertEqual(fetchedEntities, [])
                        
                    } catch {
                        print(error)
                    }
                }
            })
            .disposed(by: DisposeBag())
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
