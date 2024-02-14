import Foundation

public struct ClientChat: Identifiable, Decodable {
    public let id: String
    public let name: String
    public let updated: Date
    public let messages: [ClientMessage]
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case updated = "lastUpdated"
        case messages
    }
}

public struct ClientMessage: Identifiable, Decodable {
    public let id: String
    public let updated: Date
    public let content: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case updated = "lastUpdated"
        case content = "text"
    }
}

public struct PendingMessage: Identifiable, Encodable {
    public let id: UUID
    public let chatID: ClientChat.ID
    public let created: Date
    public let content: String
}
