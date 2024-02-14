//
//  StoreTests.swift
//  BlinkChatTests
//
//  Created by James Valaitis on 14/02/2024.
//

@testable import BlinkChat
import XCTest

final class StoreTests: XCTestCase {
    private var mockClient: MockClient!
    private var mockDatabase: MockDatabase!
    
    override func setUp() async throws {
        try await super.setUp()
        
        mockClient = MockClient()
        mockDatabase = MockDatabase()
    }
    
    override func tearDown() async throws {
        try await super.tearDown()
        mockClient = nil
        mockDatabase = nil
    }
    
    func testFetchChats_success() async throws {
        let chats: [ClientChat] = [
            .init(id: "1", name: "Gym", updated: .now.addingTimeInterval(-60*60), messages: [.init(id: "2", updated: .now, content: "Let's go!")]),
            .init(id: "3", name: "Honey", updated: .now.addingTimeInterval(-60*60*2), messages: [.init(id: "4", updated: .now, content: "Happy Valentine's Day!")]),
            .init(id: "3", name: "Boss", updated: .now.addingTimeInterval(-60*60*3), messages: [.init(id: "4", updated: .now, content: "I'm on it.")])
        ]
        
        mockClient.fetchChats = {
            chats
        }
        
        mockDatabase.fetchChats = {
            chats.map(Chat.init)
        }
        
        mockDatabase.fetchPendingMessages = { chatID in
            if chatID == chats[0].id {
                return [.init(id: .init(), updated: .now, content: "I'm ready!", hasSent: false)]
            } else { return [] }
        }
        
        let store = LiveStore(client: mockClient, database: mockDatabase)
        let chatsInStore = try await store.chats()
        XCTAssertEqual(chatsInStore.count, chats.count)
        XCTAssertEqual(chatsInStore[0].messages.count, 2)
    }
}

private final class MockClient: APIClient {
    var fetchChats: () async throws -> [ClientChat] = { throw MockError.notImplemented }
    func chats() async throws -> [ClientChat] {
        try await fetchChats()
    }
    
    var postPendingMessage: (PendingMessage) async throws -> ClientMessage = { _ in throw MockError.notImplemented }
    func postMessage(_ message: PendingMessage) async throws -> ClientMessage {
        try await postPendingMessage(message)
    }
}

private final class MockDatabase: Database {
    
    var fetchChats: () -> [Chat] = { [] }
    func chats() -> [Chat] {
        fetchChats()
    }
    
    var fetchPendingMessages: (String) -> [Message] = { _ in [] }
    func pendingMessages(for chatID: String) -> [Message] {
        fetchPendingMessages(chatID)
    }
    
    var savePendingMessage: (PendingMessage) -> () = { _ in }
    func save(_ message: PendingMessage) {
        savePendingMessage(message)
    }
    
    var saveChats: ([Chat]) -> () = { _ in }
    func save(_ chats: [Chat]) {
        saveChats(chats)
    }
    
    
}
