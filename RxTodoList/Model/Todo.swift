import Foundation

struct Todo: Identifiable {
    
    var name: String
    let id = UUID()

    init(_ name: String) {
        self.name = name
    }
    
    mutating func update(name: String) {
        self.name = name
    }
    
}
