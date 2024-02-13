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
        mockNetwork.dataFetch = { [baseURL] request in
            XCTAssertEqual(request.httpMethod, "GET")
            XCTAssertEqual(request.url!.absoluteString, baseURL.absoluteString + "/v1/chats")
            return try Data(contentsOf: Bundle(for: Self.self).url(forResource: "test-data", withExtension: "json")!)
        }
        let chats = try await client.chats()
        XCTAssertEqual(chats.count, 5)
    }
}

enum MockError: Error {
    case notImplemented
}

final class MockNetwork: Network {
    var dataFetch: (URLRequest) async throws -> Data = { _ in throw MockError.notImplemented }
    
    func request(_ request: URLRequest) async throws -> Data? {
        try await dataFetch(request)
    }
}
