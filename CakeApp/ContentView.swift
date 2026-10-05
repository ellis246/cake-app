//
//  ContentView.swift
//  CakeApp
//
//  Created by Adam Ellis on 23/09/2026.
//

import SwiftUI

struct ContentView: View {
    
    @State private var viewModel = CakeViewModel()
    @State private var selectedItem: Cake? = nil
    
    var body: some View {
        NavigationStack {
            ScrollView {
                switch viewModel.loadState {
                case .loading:
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                case .loaded(let cakes):
                    // Dedupe on title produces stable title id
                    CakeRowsView(cakes: cakes) {
                        selectedItem = $0
                    }
                case .error:
                    VStack {
                        // TODO: Surface specific error, improving UX but not oversharing sensitive data
                        Text("Couldn't load cakes, please try again later.")
                        Button("Try again") {
                            Task {
                                await viewModel.load()
                            }
                        }
                    }
                }
            }
            .padding()
            .task {
                await viewModel.load()
            }
            .sheet(item: $selectedItem) { cake in
                NavigationStack {
                    Text(cake.desc)
                        .padding()
                        .presentationDetents([.medium])
                        .navigationTitle(cake.title)
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Close") {
                                    selectedItem = nil
                                }
                            }
                        }
                }
                
            }
            .refreshable {
                await viewModel.load()
            }
            .navigationTitle("Cakes")
        }
    }
}

#Preview {
    ContentView()
}
