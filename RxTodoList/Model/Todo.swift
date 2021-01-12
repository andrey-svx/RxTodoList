import Foundation

struct Todo {
    
    var name: String
    let id = UUID()
    let date = Date()
    
    init(_ name: String = "") {
        self.name = name
    }
    
    mutating func update(_ name: String) {
        self.name = name
    }
}
