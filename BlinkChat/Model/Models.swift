import Foundation

public struct Chat: Identifiable, Decodable {
    public let id: String
    public let name: String
    public let updated: Date
    public let messages: [Message]
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case updated = "lastUpdated"
        case messages
    }
}

public struct Message: Identifiable, Decodable {
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
    public let chatID: Chat.ID
    public let created: Date
    public let content: String
}

public struct User: Identifiable, Decodable {
    public let id: UUID
    public let name: String
}
