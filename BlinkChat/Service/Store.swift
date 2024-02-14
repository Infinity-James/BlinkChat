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
        //  fetch the chats from the database and merge in the pending messages for that chat.
        var chats = database.chats().map { chat in
            let messages = chat.messages + database.pendingMessages(for: chat.id)
            return Chat(id: chat.id, name: chat.name, updated: chat.updated, messages: messages)
        }
        
        do {
            let clientChats = try await client.chats()
            merge(&chats, with: clientChats)
            database.save(chats)
        } catch {
            //  failed to fetch from server, don't worry about it
        }
        
        return chats
    }
    
    func postMessage(_ content: String) async throws {
        
    }
    
    private func merge(_ localChats: inout [Chat], with clientChats: [ClientChat]) {
        
    }
}

internal extension Chat {
    init(_ server: ClientChat) {
        self.init(id: server.id,
                  name: server.name,
                  updated: server.updated,
                  messages: server.messages.map(Message.init))
    }
}

private extension Message {
    init(_ server: ClientMessage) {
        self.init(id: server.id,
                  updated: server.updated,
                  content: server.content,
                  hasSent: true)
    }
    
    init(_ pending: PendingMessage) {
        self.init(id: pending.id.uuidString,
                  updated: pending.created,
                  content: pending.content,
                  hasSent: false)
    }
}

