//
//  BlinkChatTests.swift
//  BlinkChatTests
//
//  Created by James Valaitis on 13/02/2024.
//

import XCTest
@testable import BlinkChat

final class ClientTests: XCTestCase {
    let baseURL = URL(string: "https://fake-endpoint.com")!
    var mockNetwork: MockNetwork!
    
    override func setUp() async throws {
        try await super.setUp()
        mockNetwork = MockNetwork()
    }
    
    override func tearDown() async throws {
        try await super.tearDown()
        mockNetwork = nil
    }
    
    func testFetchChats_success() async throws {
        let client = LiveClient(baseURL: baseURL, network: mockNetwork)
        mockNetwork.makeRequest = { [baseURL] request in
            XCTAssertEqual(request.httpMethod, "GET")
            XCTAssertEqual(request.url!.absoluteString, baseURL.absoluteString + "/v1/chats")
            return try Data(contentsOf: Bundle(for: Self.self).url(forResource: "test-data", withExtension: "json")!)
        }
        let chats = try await client.chats()
        XCTAssertEqual(chats.count, 5)
    }
    
    func testPostMessage_success() async throws {
        let client = LiveClient(baseURL: baseURL, network: mockNetwork)
        let chatID = "test-chat-id"
        let messageContent = "Test content."
        let pendingMessage = PendingMessage(id: .init(), chatID: chatID, created: .now, content: messageContent)
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let messageData = try encoder.encode(pendingMessage)
        let messageID = "test-message-id"
        
        mockNetwork.makeRequest = { [baseURL] request in
            XCTAssertEqual(request.httpMethod, "POST")
            XCTAssertEqual(request.url!.absoluteString, baseURL.absoluteString + "/v1/chats/" + chatID)
            let bodyString = try JSONSerialization.jsonObject(with: request.httpBody!) as! [String: Any]
            let dataString = try JSONSerialization.jsonObject(with: messageData) as! [String: Any]
            XCTAssertEqual(dataString["id"] as! String, bodyString["id"]  as! String)
            return """
            {
                "id": "\(messageID)",
                "text": "\(messageContent)",
                "last_updated": "2020-07-15T06:40:25"
            }
            """.data(using: .utf8)
        }
        
        let createdMessage = try await client.postMessage(pendingMessage)
        XCTAssertEqual(createdMessage.id, messageID)
        XCTAssertEqual(createdMessage.content, messageContent)
    }
}

enum MockError: Error {
    case notImplemented
}

final class MockNetwork: Network {
    var makeRequest: (URLRequest) async throws -> Data? = { _ in throw MockError.notImplemented }
    
    func request(_ request: URLRequest) async throws -> Data? {
        try await makeRequest(request)
    }
}
