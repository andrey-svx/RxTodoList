import XCTest
import CoreData
import RxBlocking

@testable
import RxTodoList

class RxTodoListTests: XCTestCase {
    
    let user = User()
    
    var context = (UIApplication.shared.delegate as! AppDelegate).context
    var cdTodos: [CDTodo]!

    override func setUpWithError() throws {
        user.configure()
        
        context = user.context
        cdTodos = ["Clean the apt",
                   "Learn to code",
                   "Call mom",
                   "Do the workout",
                   "Call customers"]
            .map { name -> Todo in
                sleep(1)
                return Todo(name)
            }
            .map {
                let cdTodo = CDTodo(context: context)
                cdTodo.name = $0.name
                cdTodo.id = $0.id
                cdTodo.date = $0.date
                return cdTodo
            }

        context.performAndWait {
            guard context.hasChanges else { return }
            do {
                try context.save()
            } catch {
                print(error)
            }
        }
    }

    override func tearDownWithError() throws {
        context.performAndWait {
            do {
                cdTodos.forEach(context.delete)
                try context.save()
            } catch {
                print(error)
            }
        }
    }

    func test_User_appendTodo_testTodo() throws {
        user.setEdited(Todo("Test todo"))
        user.appendTodo()
        XCTAssertEqual(user.getTodos()
                        .map { $0.name },
                       ["Clean the apt",
                        "Learn to code",
                        "Call mom",
                        "Do the workout",
                        "Call customers",
                        "Test todo"])
    }
     
    func test_User_appendTodo_emptyTodo() throws {
        user.setEdited(Todo())
        user.appendTodo()
        XCTAssertEqual(user.getTodos()
                        .map { $0.name },
                       ["Clean the apt",
                        "Learn to code",
                        "Call mom",
                        "Do the workout",
                        "Call customers"])
    }
    
    func test_User_editTodo_testTodo() throws {
        let todoToEdit = user.getTodos()[0]
        user.setEdited(todoToEdit)
        user.updateEdited("Test todo")
        user.editTodo()
        XCTAssertEqual(user.getTodos()
                        .map { $0.name },
                       ["Test todo",
                        "Learn to code",
                        "Call mom",
                        "Do the workout",
                        "Call customers"])
    }
    
    func test_User_editTodo_emptyTodo() throws {
        let todoToDelete = user.getTodos()[0]
        user.setEdited(todoToDelete)
        user.updateEdited("")
        user.editTodo()
        XCTAssertEqual(user.getTodos()
                        .map { $0.name },
                       ["Learn to code",
                        "Call mom",
                        "Do the workout",
                        "Call customers"])
    }
    
    func test_User_fetch() throws {
        let request = CDTodo.fetchRequest() as NSFetchRequest<CDTodo>
        let sort = NSSortDescriptor(key: "date", ascending: true)
        request.sortDescriptors = [sort]
        request.returnsObjectsAsFaults = false
        let testCDTodos = try! user.fetch(request: request)
            .toBlocking().first()!
        XCTAssertEqual(testCDTodos, cdTodos!)
    }
    
    
    
    func test_User_logout() throws {
        let testLogout = try! user.logout()
            .toBlocking().first()!
        XCTAssertEqual(testLogout, nil)
    }
    
    func test_User_loginAs() throws {
        let testLogin = try! user.loginAs("test_username", "test_password")
            .toBlocking().first()!
        XCTAssertEqual(testLogin,
                       LoginDetails(username: "test_username", password: "test_password"))
    }
    
    func test_User_signupAs() throws {
        let testSignup = try! user.loginAs("test_username", "test_password")
            .toBlocking().first()!
        XCTAssertEqual(testSignup,
                       LoginDetails(username: "test_username", password: "test_password"))
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
