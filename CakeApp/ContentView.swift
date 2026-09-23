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
                guard let url = URL(string: "https://raw.githubusercontent.com/Waracle/mobile-coding-test-api/refs/heads/main/cakes") else {
                    fatalError("Unable to fetch cake data - invalid URL provided")
                }
                let (data, response) = try await URLSession.shared.data(for: URLRequest(url: url))
                guard let httpResponse = response as? HTTPURLResponse else {
                    fatalError("Unable to fetch cake data - invalid response type")
                }
                guard (200..<299).contains(httpResponse.statusCode) else {
                    fatalError("Non 200 error code")
                }
                let result = try JSONDecoder().decode([Cake].self, from: data)
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
