//
//  ContentView.swift
//  CakeApp
//
//  Created by Adam Ellis on 23/09/2026.
//

import SwiftUI

enum NetworkError: Error {
    case httpError(statusCode: Int)
    case general(reason: String)
}

protocol NetworkLayer {
    func loadCakes() async throws -> [Cake]
}

struct Network: NetworkLayer {
    
    func loadCakes() async throws -> [Cake] {
        guard let url = URL(string: "https://raw.githubusercontent.com/Waracle/mobile-coding-test-api/refs/heads/main/cakes") else {
            throw NetworkError.general(reason: "Invalid URL provided")
        }
        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.general(reason: "Invalid response type")
        }
        guard (200..<299).contains(httpResponse.statusCode) else {
            throw NetworkError.httpError(statusCode: httpResponse.statusCode)
        }
        return try JSONDecoder().decode([Cake].self, from: data)
    }
}

extension ContentView {
    
    @Observable
    class CakeViewModel {
        private(set) var cakes = [Cake]()
        private let network: NetworkLayer
        
        init(network: NetworkLayer = Network()) {
            self.network = network
        }
        
        func load() async throws {
            self.cakes = try await network.loadCakes()
        }
    }
}

struct ContentView: View {
    
    @State private var viewModel = CakeViewModel()
    @State private var isError = false
    var body: some View {
        if isError {
            Text("A network error occurred. Please try again later.")
        } else {
            ScrollView {
                // Dedupe on title produces stable title id
                ForEach(viewModel.cakes, id: \.title) { cake in
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
                    try await viewModel.load()
                } catch {
                    print(error)
                    isError = true
                    
                }
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
