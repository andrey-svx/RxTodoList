import XCTest
import CoreData
import RxBlocking

@testable
import RxTodoList

class RxTodoListTests: XCTestCase {
    
    let user = User()
    
    lazy var backgroundContext: NSManagedObjectContext = {
        let container = NSPersistentContainer(name: "TodoList")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        let context = container.newBackgroundContext()
        return context
    }()

    override func setUpWithError() throws {
        
    }

    override func tearDownWithError() throws {
        
    }

    func test_User_updateTodos_append() throws {
        user.configure(with: backgroundContext)
        user.setEdited(user.newTodo("Test todo"))
        user.updateTodos()
        XCTAssertEqual(user.getTodos()
                        .map { $0.name },
                       ["Clean the apt",
                        "Learn to code",
                        "Call mom",
                        "Do the workout",
                        "Call customers",
                        "Test todo"])
        
        user.configure(with: backgroundContext)
        user.setEdited(user.newTodo())
        user.updateTodos()
        XCTAssertEqual(user.getTodos()
                        .map { $0.name },
                       ["Clean the apt",
                        "Learn to code",
                        "Call mom",
                        "Do the workout",
                        "Call customers"])
    }
    
    func test_User_updateTodos_edit() throws {
        user.configure(with: backgroundContext)
        let todoToEdit = user.getTodos()[0]
        user.setEdited(todoToEdit)
        user.updateEdited("Test todo")
        user.updateTodos()
        XCTAssertEqual(user.getTodos()
                        .map { $0.name },
                       ["Test todo",
                        "Learn to code",
                        "Call mom",
                        "Do the workout",
                        "Call customers"])
        
        user.configure(with: backgroundContext)
        let todoToDelete = user.getTodos()[0]
        user.setEdited(todoToDelete)
        user.updateEdited("")
        user.updateTodos()
        XCTAssertEqual(user.getTodos()
                        .map { $0.name },
                       ["Learn to code",
                        "Call mom",
                        "Do the workout",
                        "Call customers"])
    }
    
    func test_User_logout() {
        user.configure(with: backgroundContext)
        let testLogout = try! user.logout()
            .toBlocking().first()!
        XCTAssertEqual(testLogout, nil)
    }
    
    func test_User_loginAs() {
        user.configure(with: backgroundContext)
        let testLogin = try! user.loginAs("test_username", "test_password")
            .toBlocking().first()!
        XCTAssertEqual(testLogin,
                       LoginDetails(username: "test_username", password: "test_password"))
    }
    
    func test_User_signupAs() {
        user.configure(with: backgroundContext)
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
