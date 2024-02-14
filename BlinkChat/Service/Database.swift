//
//  Database.swift
//  BlinkChat
//
//  Created by James Valaitis on 13/02/2024.
//

import Foundation
import RealmSwift

public protocol Database: AnyObject {
    func chats() -> [Chat]
    
    func pendingMessages(for chatID: String) -> [PendingMessage]
    
    func save(_ message: PendingMessage)
    
    func save(_ chats: [Chat])
}

internal final class LiveDatabase: Database {
    private let schemaVersion: UInt64 = 1
    
    init() {
        let config = Realm.Configuration(schemaVersion: schemaVersion)
        Realm.Configuration.defaultConfiguration = config
    }
    
    func chats() -> [Chat] {
        try! Realm().objects(DBChat.self).map(Chat.init)
    }
    
    func pendingMessages(for chatID: String) -> [PendingMessage] {
        []
    }
    
    func save(_ message: PendingMessage) {
        
    }
    
    func save(_ chats: [Chat]) {
        
    }
}

private extension Chat {
    var database: DBChat {
        let db = DBChat()
        db.id = id
        db.name = name
        db.updated = updated
        db.messages.append(objectsIn: messages.map { $0.database })
        return db
    }
    
    init(_ database: DBChat) {
        self.init(id: database.id,
                  name: database.name,
                  updated: database.updated,
                  messages: database.messages.map(Message.init))
    }
}

private extension Message {
    var database: DBMessage {
        let db = DBMessage()
        db.id = id
        db.content = content
        db.updated = updated
        db.isPending = !hasSent
        return db
    }
    
    init(_ database: DBMessage) {
        self.init(id: database.id, updated: database.updated, content: database.content, hasSent: !database.isPending)
    }
}
