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
