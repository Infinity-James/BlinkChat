//
//  DatabaseModels.swift
//  BlinkChat
//
//  Created by James Valaitis on 13/02/2024.
//

import Foundation
import RealmSwift

internal final class DBChat: Object {
    @Persisted(primaryKey: true) var id = ""
    @Persisted var name = ""
    @Persisted var updated: Date = .now
    @Persisted var messages: List<DBMessage>
}

internal final class DBMessage: Object {
    @Persisted(primaryKey: true) var id = ""
    @Persisted var content = ""
    @Persisted var updated: Date = .now
    @Persisted var isPending = false
}
