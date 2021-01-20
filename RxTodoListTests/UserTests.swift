import XCTest
import CoreData
import RxSwift
import RxCocoa
import RxRelay
import RxBlocking

@testable
import RxTodoList

class UserTests: XCTestCase {
    
    let user = User()
    
    lazy var context: NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.context
        return context
    }()

    override func setUpWithError() throws {
        user.configure()
    }

    override func tearDownWithError() throws {

    }

    func test_User_logout() throws {
        let testLogout = try! user.logout()
            .toBlocking()
            .first()!

        XCTAssertEqual(testLogout, nil)
    }

//    func test_User_loginAs() throws {
//        let testLogin = try! user.loginAs("test_username", "test_password")
//            .toBlocking()
//            .first()!
//        XCTAssertEqual(testLogin,
//                       LoginDetails(username: "test_username", password: "test_password"))
//    }
//
//    func test_User_signupAs() throws {
//        let testSignup = try! user.signupAs("test_username", "test_password")
//            .toBlocking()
//            .first()!
//        XCTAssertEqual(testSignup,
//                       LoginDetails(username: "test_username", password: "test_password"))
//    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
