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
        request.timeoutInterval = 5
        // Disabling cache so that error shown on reload, if network unavailable.
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
        var isError = false
        
        init(network: NetworkLayer = Network()) {
            self.network = network
        }
        
        func load() async {
            do {
                var cakeTitles = Set<String>()
                let cakes = try await network.loadCakes()
                    .filter {
                        cakeTitles.insert($0.title).inserted
                    }
                    .sorted(by: {$0.title < $1.title})
                self.isError = false
                self.cakes = cakes
            } catch {
                print(error)
                self.isError = true
            }
            
            
        }
    }
}

struct ContentView: View {
    
    @State private var viewModel = CakeViewModel()
    //TODO: refactor so that not possible to have cakes and error state together (incl loading)
    @State private var selectedItem: Cake? = nil
    var body: some View {
            content
            .refreshable {
                await viewModel.load()
            }
        
        
    }
    
    @ViewBuilder
    private var content: some View {
        ScrollView {
            if viewModel.isError {
                VStack {
                    Text("A network error occurred. Please try again later.")
                    Button("Try again") {
                        Task {
                            await viewModel.load()
                        }
                    }
                }
            } else {
                // Dedupe on title produces stable title id
                ForEach(viewModel.cakes.enumerated(), id: \.element.title) { (index, cake) in
                    VStack(alignment: .leading) {
                        Text("\(cake.title)")
                            .font(.title)
                        Button {
                            selectedItem = cake
                        } label: {
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
                        .buttonStyle(.plain)
                    }
                    if index < viewModel.cakes.count-1 {
                        Divider()
                    }
                }
            }
        }
        .padding()
        .task {
            await viewModel.load()
        }
        .sheet(item: $selectedItem) { cake in
            Text(cake.desc)
                .presentationDetents([.medium])
        }
    }
}

#Preview {
    ContentView()
}

struct Cake: Decodable, Identifiable {
    let title: String
    let desc: String
    let image: String
    
    var id: String {
        title
    }
}
