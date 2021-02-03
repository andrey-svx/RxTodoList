import Foundation

struct FirebaseLocalConverter {
    
    static func wrapToFirebase(_ todo: LocalTodo) -> [String: Any] {
        var firebaseCompatible: [String: Any] = [:]
        firebaseCompatible["id"] = todo.id.uuidString
        let date = todo.date
        let timeInterval = date.timeIntervalSince1970
        firebaseCompatible["date"] = timeInterval
        firebaseCompatible["name"] = todo.name
        return firebaseCompatible
    }
    
    static func unwrapFromFirebase(_ todo: [String: Any]) -> LocalTodo {
        let date = Date(timeIntervalSince1970: todo["date"] as! TimeInterval)
        return LocalTodo(
            todo["name"] as! String,
            id: UUID(uuidString: todo["id"] as! String)!,
            date: date,
            objectID: nil
        )
    }
    
}
