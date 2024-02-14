//
//  ChatsViewModels.swift
//  BlinkChat
//
//  Created by James Valaitis on 14/02/2024.
//

import SwiftUI

final class ChatsViewModel: ObservableObject {
    private unowned let store: Store
    @Published var chats: [ChatViewModel] = []
    
    init(store: Store) {
        self.store = store
    }
    
    @MainActor
    func refresh() async {
        do {
            let newChats = try await store.chats()
            chats = newChats.map { .init(chat: $0, store: store) }
        } catch {
            print("Failed to fetch chats: \(error)")
        }
    }
}

final class ChatViewModel: Identifiable, ObservableObject {
    private unowned let store: Store
    let id: String
    @Published var name = ""
    @Published var messages: [MessageViewModel] = []
    @Published var newMessage = ""
    
    @MainActor
    init(chat: Chat, store: Store) {
        id = chat.id
        name = chat.name
        messages = chat.messages.map { MessageViewModel($0) }
        self.store = store
    }
    
    func sendMessage() {
        let message = newMessage
        newMessage = ""
        Task {
            do {
                let sent = try await store.postMessage(message, toChat: id)
                await MainActor.run { [weak self] in
                    guard let self else { return }
                    messages.append(.init(sent, isUser: true))
                }
            } catch {
                
            }
        }
    }
}

struct MessageViewModel: Identifiable {
    static let formatter: DateFormatter = {
       let f = DateFormatter()
        f.dateFormat = "MMM d, h:mm a"
        return f
    }()
    
    let id: String
    let content: String
    let date: String
    let hasSent: Bool
    let isUser: Bool
    
    init(_ message: Message, isUser: Bool = .random()) {
        id = message.id
        content = message.content
        hasSent = message.hasSent
        self.isUser = isUser
        date = Self.formatter.string(from: message.updated)
    }
}
