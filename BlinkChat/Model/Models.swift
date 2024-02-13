import Foundation

public struct Chat: Identifiable, Decodable {
    public let id: String
    public let name: String
    public let updated: Date
    public let messages: [Message]
}

public struct Message: Identifiable, Decodable {
    public let id: String
    public let updated: Date
    public let content: String
}

public struct PendingMessage: Identifiable, Encodable {
    public let id: UUID
    public let created: Date
    public let content: String
}

public struct User: Identifiable, Decodable {
    public let id: UUID
    public let name: String
}
