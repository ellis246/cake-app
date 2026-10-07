//
//  CakeViewModel.swift
//  CakeApp
//
//  Created by Adam Ellis on 29/09/2026.
//

import Foundation

@Observable
class CakeViewModel {
    private let network: NetworkService

    private(set) var loadState: LoadState = .loading
    
    enum LoadState: Equatable {
        case loading
        case loaded([Cake])
        case error(NetworkError)
        
        var isLoaded: Bool {
            if case .loaded = self {
                return true
            } else {
                return false
            }
        }
    }
    
    init(network: NetworkService = Network()) {
        self.network = network
    }
    
    //TODO: maintain optional task as state, check task to ensure coalescing in-flight
    func load() async {
        let previousState = loadState
        do {
            if !loadState.isLoaded {
                self.loadState = .loading
            }
            var cakeTitles = Set<String>()
            let cakes = try await network.loadCakes()
                .filter {
                    // Cakes are assumed to be duplicates on title only, any changes to description and imageURL are ignored, the first entry for a duplicate's values are used.
                    cakeTitles.insert($0.title).inserted
                }
                .sorted(by: {$0.title.caseInsensitiveCompare($1.title) == .orderedAscending })
            self.loadState = .loaded(cakes)
        // May have set .loading, cancellation isn't result, restore previous state
        } catch is CancellationError {
            self.loadState = previousState
        } catch let error as NetworkError {
            setError(error)
        } catch {
            setError(.general(reason: "Unknown"))
        }
    }
    
    private func setError(_ error: NetworkError) {
        if !loadState.isLoaded {
            self.loadState = .error(error)
        }
        //TODO: else surface an error message that the re-fetch failed
    }
}
