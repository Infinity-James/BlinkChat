//
//  Client.swift
//  BlinkChat
//
//  Created by James Valaitis on 13/02/2024.
//

import Foundation

public protocol APIClient: AnyObject {
    func chats() async throws -> [Chat]
    func postMessage(_ message: PendingMessage) async throws -> Message
}

internal final class LiveClient: APIClient {
    let baseURL: URL
    let network: Network
    
    init(baseURL: URL, network: Network) {
        self.network = network
        self.baseURL = baseURL
    }
    
    func chats() async throws -> [Chat] {
        try await parse(network.request(Endpoint.chats.request(baseURL: baseURL)))
    }
    
    func postMessage(_ message: PendingMessage) async throws -> Message {
        try await parse(network.request(Endpoint.postMessage(message).request(baseURL: baseURL)))
    }
    
    private static let dateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = .withFractionalSeconds
        return formatter
    }()
    
    func parse<T: Decodable>(_ data: Data?) throws -> T {
        guard let data else { throw ClientError.noData }
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            guard let date = Self.dateFormatter.date(from: dateString) else { throw ClientError.decodingFailed(ClientError.invalidDate) }
            return date
        }
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw ClientError.decodingFailed(error)
        }
    }
}

internal enum Endpoint {
    case chats
    case postMessage(PendingMessage)
    
    var path: String {
        switch self {
        case .chats:
            "/v1/chats"
        case .postMessage(let message):
            "/v1/chats/\(message.chatID)"
        }
    }
    
    var method: String {
        switch self {
        case .chats:
            return "GET"
        case .postMessage:
            return "POST"
        }
    }
    
    func applyHeadersAndBody(to request: inout URLRequest) throws {
        switch self {
        case .chats:
            break
        case .postMessage(let message):
            request.addJSONBody(message)
        }
    }
    
    func request(baseURL: URL) throws -> URLRequest {
        guard var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true) else { throw ClientError.endpointCreationFailed }
        components.path = path
        guard let url = components.url  else { throw ClientError.endpointCreationFailed }
        var request = URLRequest(url: url)
        request.httpMethod = method
        try applyHeadersAndBody(to: &request)
        return request
    }
}

extension URLRequest {
    static let encoder: JSONEncoder = {
        let e = JSONEncoder()
        e.keyEncodingStrategy = .convertToSnakeCase
        return e
    }()
    
    mutating func addJSONBody<O: Encodable>(_ object: O) {
        httpBody = try? Self.encoder.encode(object)
    }
}

public enum ClientError: Error {
    case endpointCreationFailed
    case noData
    case decodingFailed(Error)
    case invalidDate
}

internal protocol Network: AnyObject {
    func request(_ request: URLRequest) async throws -> Data?
}

internal final class LiveNetwork: Network {
    func request(_ request: URLRequest) async throws -> Data? {
        //  this is a fake implementation for now.
        //  in a live application, I would use Alamofire if I wanted good support for adapting requests
        //  otherwise, if the client can be simpler, I'd use URLSession and do the work myself
        if request.httpMethod == "POST" {
            return """
            {
                "id": "5f58bcd7c34da3af332cc123",
                "text": "Message content",
                "last_updated": "2020-07-15T06:40:25"
            }
            """.data(using: .utf8)
        } else {
            return try Data(contentsOf: Bundle.main.url(forResource: "dummy-data", withExtension: "json")!)
        }
    }
}
