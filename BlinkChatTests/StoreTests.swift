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
        
    }
}

private final class MockClient: APIClient {
    var fetchChats: () async throws -> [Chat] = { throw MockError.notImplemented }
    func chats() async throws -> [Chat] {
        try await fetchChats()
    }
    
    var postPendingMessage: (PendingMessage) async throws -> Message = { _ in throw MockError.notImplemented }
    func postMessage(_ message: PendingMessage) async throws -> Message {
        try await postPendingMessage(message)
    }
}

private final class MockDatabase: Database {
    
    var fetchChats: () -> [Chat] = { [] }
    func chats() -> [Chat] {
        fetchChats()
    }
    
    var fetchPendingMessages: (String) -> [PendingMessage] = { _ in [] }
    func pendingMessages(for chatID: String) -> [PendingMessage] {
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
