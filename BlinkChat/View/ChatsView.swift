//
//  ChatsView.swift
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

struct ChatsView: View {
    @ObservedObject var viewModel: ChatsViewModel
    
    var body: some View {
        List {
            ForEach(viewModel.chats) { chat in
                NavigationLink {
                    ChatView(viewModel: chat)
                } label: {
                    Text(chat.name)
                        .foregroundStyle(.primary)
                        .font(.title2)
                        .padding(8)
                }
            }
        }
        .task {
            await viewModel.refresh()
        }
        .navigationTitle("Chats")
    }
}

struct ChatView: View {
    @ObservedObject var viewModel: ChatViewModel
    
    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack {
                        ForEach(viewModel.messages) { message in
                            MessageView(viewModel: message)
                                .id(message.id)
                        }
                    }
                }
                .onChange(of: viewModel.messages.count, initial: true) {
                    withAnimation {
                        proxy.scrollTo(viewModel.messages.last?.id, anchor: .bottom)
                    }
                }
            }
            
            HStack {
                TextField("Send a message", text: $viewModel.newMessage)
                    .textFieldStyle(.roundedBorder)
                Button {
                    viewModel.sendMessage()
                } label: {
                    Image(systemName: "paperplane")
                }
            }
            .padding()
        }
    }
}

struct MessageView : View {
    var viewModel: MessageViewModel
    
    var body: some View {
        VStack {
            Text(viewModel.date)
                .frame(maxWidth: .infinity, alignment: viewModel.isUser ? .trailing : .leading)
                
            
            HStack(alignment: .center, spacing: 10) {
                if !viewModel.isUser {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .foregroundStyle(.gray)
                        .frame(width: 32, height: 32, alignment: .center)
                        .cornerRadius(16)
                }
                
                MessageCell(content: viewModel.content, isUser: viewModel.isUser)
                    .frame(maxWidth: .infinity, alignment: viewModel.isUser ? .trailing : .leading)
            }
        }
        .frame(maxWidth: .infinity, alignment: viewModel.isUser ? .trailing : .leading)
        .padding()
    }
}

struct MessageCell: View {
    var content: String
    var isUser: Bool
    
    var body: some View {
        Text(content)
            .padding(10)
            .foregroundStyle(isUser ? .white : .black)
            .background(isUser ? .blue : Color(UIColor.systemGray6))
            .cornerRadius(10)
    }
}

private final class MockStore: Store {
    func chats() async throws -> [Chat] {
        [
            .init(id: "a", name: "Fun", updated: .now, messages: [
                .init(id: "1", updated: .now, content: "🙃", hasSent: false),
                .init(id: "2", updated: .now.addingTimeInterval(-1), content: "Nothing.", hasSent: true),
                .init(id: "3", updated: .now.addingTimeInterval(-2), content: "What's up?", hasSent: true)
            ]),
            .init(id: "b", name: "Boring", updated: .now.addingTimeInterval(-1), messages: [
                .init(id: "1", updated: .now, content: "You never do.", hasSent: true),
                .init(id: "2", updated: .now.addingTimeInterval(-1), content: "I don't want to. 🤷‍♂️", hasSent: true),
                .init(id: "3", updated: .now.addingTimeInterval(-2), content: "Let's train.", hasSent: true)
            ]),
            .init(id: "c", name: "Not bad", updated: .now.addingTimeInterval(-2), messages: [
                .init(id: "1", updated: .now, content: "I thought you were. 🤖", hasSent: true),
                .init(id: "2", updated: .now.addingTimeInterval(-1), content: "Ask ChatGPT.", hasSent: true),
                .init(id: "3", updated: .now.addingTimeInterval(-2), content: "How do I make dumplings?", hasSent: true)
            ])
        ]
    }
    
    func postMessage(_ content: String, toChat chatID: Chat.ID) async throws -> Message {
        return .init(id: "z", updated: .now, content: "Random", hasSent: false)
    }
}

private let mockStore = MockStore()

#Preview {
    NavigationStack {
        ChatsView(viewModel: ChatsViewModel(store: mockStore))
    }
}

