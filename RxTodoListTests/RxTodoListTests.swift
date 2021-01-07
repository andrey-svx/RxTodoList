import XCTest
import RxBlocking

@testable
import RxTodoList

class RxTodoListTests: XCTestCase {
    
    let user = User()

    override func setUpWithError() throws {
        
    }

    override func tearDownWithError() throws {
        
    }

    func test_User_updateTodos_append() throws {
        user.prepare()
        user.setEdited(Todo("Test todo"))
        user.updateTodos()
        XCTAssertEqual(user.getTodos()
                        .map { $0.name },
                       ["Clean the apt",
                        "Learn to code",
                        "Call mom",
                        "Do the workout",
                        "Call customers",
                        "Test todo"])
        
        user.prepare()
        user.setEdited(Todo(""))
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
        user.prepare()
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
        
        user.prepare()
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
    
    func test_logout() {
        user.prepare()
        let testLogout = try! user.logout()
            .toBlocking().first()!
        XCTAssertEqual(testLogout, nil)
    }
    
    func test_User_loginAs() {
        user.prepare()
        let testLogin = try! user.loginAs("testUsername", "testPassword")
            .toBlocking().first()!
        XCTAssertEqual(testLogin,
                       LoginDetails(username: "testUsername", password: "testPassword"))
    }
    
    func test_User_signupAs() {
        user.prepare()
        let testSignup = try! user.loginAs("testUsername", "testPassword")
            .toBlocking().first()!
        XCTAssertEqual(testSignup,
                       LoginDetails(username: "testUsername", password: "testPassword"))
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
