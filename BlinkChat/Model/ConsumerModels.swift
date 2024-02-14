import Foundation

public struct Chat: Identifiable {
    public let id: String
    public let name: String
    public let updated: Date
    public let messages: [Message]
}

public struct Message: Identifiable {
    public let id: String
    public let updated: Date
    public let content: String
    public let hasSent: Bool
}

