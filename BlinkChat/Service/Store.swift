import Foundation

public protocol Store: AnyObject {
    func chats() async throws -> [Chat]
    func postMessage(_ content: String, toChat chatID: Chat.ID) async throws -> Message
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
            let messages = chat.messages + database.pendingMessages(for: chat.id).sorted(by: { $0.updated > $1.updated })
            return Chat(id: chat.id, name: chat.name, updated: chat.updated, messages: messages)
        }
        
        do {
            let clientChats = try await client.chats()
            merge(&chats, with: clientChats)
            database.save(chats)
        } catch {
            print("Failed to fetch chats from the server: \(error)")
        }
        
        return chats.sorted(by: { $0.updated > $1.updated })
    }
    
    func postMessage(_ content: String, toChat chatID: Chat.ID) async throws -> Message {
        let message = PendingMessage(id: .init(), chatID: chatID, created: .now, content: content)
        database.save(message)
        //  don't bother posting to the client for now
//        client.postMessage(message)
        return Message(message)
    }
    
    private func merge(_ localChats: inout [Chat], with clientChats: [ClientChat]) {
        //  merge not implemented
        if clientChats.count > localChats.count {
            localChats = clientChats.map(Chat.init)
        }
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

