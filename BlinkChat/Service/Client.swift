//
//  Client.swift
//  BlinkChat
//
//  Created by James Valaitis on 13/02/2024.
//

import Foundation

public protocol APIClient: AnyObject {
    func chats() async throws -> [Chat]
}

internal final class LiveClient: APIClient {
    let network: Network
    let baseURL: URL
    
    init(network: Network, baseURL: URL) {
        self.network = network
        self.baseURL = baseURL
    }
    
    func chats() async throws -> [Chat] {
        try await parse(network.request(Endpoint.chats.request(baseURL: baseURL)))
    }
    
    func parse<T: Decodable>(_ data: Data?) throws -> T {
        guard let data else { throw ClientError.noData }
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw ClientError.decodingFailed(error)
        }
    }
}

internal enum Endpoint {
    case chats
    
    var path: String {
        switch self {
        case .chats:
            "/v1/chats"
        }
    }
    
    var method: String {
        switch self {
        case .chats:
            return "GET"
        }
    }
    
    func applyHeadersAndBody(to request: inout URLRequest) throws {
        switch self {
        case .chats:
            break
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

public enum ClientError: Error {
    case endpointCreationFailed
    case noData
    case decodingFailed(Error)
}

internal protocol Network: AnyObject {
    func request(_ request: URLRequest) async throws -> Data?
}

internal final class LiveNetwork: Network {
    func request(_ request: URLRequest) async throws -> Data? {
        //  this is a fake implementation for now.
        //  in a live application, I would use Alamofire if I wanted good support for adapting requests
        //  otherwise, if the client can be simpler, I'd use URLSession and do the work myself
        try Data(contentsOf: Bundle.main.url(forResource: "dummy-data", withExtension: "json")!)
    }
}
