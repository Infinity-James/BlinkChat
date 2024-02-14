//
//  ChatsView.swift
//  BlinkChat
//
//  Created by James Valaitis on 14/02/2024.
//

import SwiftUI

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

