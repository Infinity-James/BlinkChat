//
//  BlinkChatTests.swift
//  BlinkChatTests
//
//  Created by James Valaitis on 13/02/2024.
//

import XCTest
@testable import BlinkChat

final class ClientTests: XCTestCase {
    func testFetchChats_success() async throws {
        let client = LiveClient(baseURL: baseURL, network: mockNetwork)
        mockNetwork.dataFetch = { request in
            XCTAssertEqual(request.method, "GET")
            XCTAssertEqual(request.url?.absoluteString, baseURL?.absoluteString + "/v1/chats")
            return Data(contentsOf: Bundle(for: Self.self).url(forResource: "test-data", withExtension: "json")!)!
        }
        let chats = try await client.chats()
        XCTAssertEqual(chats.count, 5)
    }
}
