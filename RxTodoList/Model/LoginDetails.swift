import Foundation

struct LoginDetails {
    
    var email: String = ""
    var password: String = ""
    var uid: String? = ""
    
}

extension LoginDetails: Equatable {
    
    static func == (lhs: LoginDetails, rhs: LoginDetails) -> Bool {
            lhs.email == rhs.email
        }

}
