//
//  ContentView.swift
//  CakeApp
//
//  Created by Adam Ellis on 23/09/2026.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
        .task {
            do {
                print("Start")
                let (data, response) = try await URLSession.shared.data(for: URLRequest(url: URL(string: "https://raw.githubusercontent.com/Waracle/mobile-coding-test-api/refs/heads/main/cakes")!))
                print(try JSONDecoder().decode([Cake].self, from: data))
            } catch {
                print(error)
            }
            
        }
    }
}

#Preview {
    ContentView()
}

struct Cake: Decodable {
    let title: String
    let desc: String
    let image: String
}
