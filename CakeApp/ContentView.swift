//
//  ContentView.swift
//  CakeApp
//
//  Created by Adam Ellis on 23/09/2026.
//

import SwiftUI

struct ContentView: View {
    
    @State private var cakes = [Cake]()
    
    var body: some View {
        ScrollView {
            // Dedupe on title produces stable title id
            ForEach(cakes, id: \.title) { cake in
                VStack(alignment: .leading) {
                    Text("\(cake.title)")
                        .font(.title)
                    AsyncImage(url: URL(string: cake.image)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image
                                .resizable()
                        case .failure(let error):
                            let _ = print(error)
                            //TODO: Enhance the UX with a dedicated error view
                            Text("Failed to load image")
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
            }
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
                self.cakes = try JSONDecoder().decode([Cake].self, from: data)
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
