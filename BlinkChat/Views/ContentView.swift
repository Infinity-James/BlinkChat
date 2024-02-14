//
//  ContentView.swift
//  BlinkChat
//
//  Created by James Valaitis on 13/02/2024.
//

import SwiftUI

struct ContentView: View {
    let store = LiveStore(client: LiveClient(baseURL: URL(string: "https://doesnt-exist.com")!, network: LiveNetwork()),
                          database: LiveDatabase())
    
    var body: some View {
        NavigationStack {
            ChatsView(viewModel: .init(store: store))
        }
    }
}

#Preview {
    ContentView()
}
