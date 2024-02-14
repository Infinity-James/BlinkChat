import Foundation

public protocol Store: AnyObject {
    func chats() async throws -> [Chat]
    func postMessage(_ content: String) async throws
}

internal final class LiveStore: Store {
    private let client: APIClient
    private let database: Database
    
    init(client: APIClient, database: Database) {
        self.client = client
        self.database = database
    }
    
    func chats() async throws -> [Chat] {
        []
    }
    
    func postMessage(_ content: String) async throws {
        
    }
}
