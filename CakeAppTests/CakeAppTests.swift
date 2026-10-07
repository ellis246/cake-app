//
//  CakeAppTests.swift
//  CakeAppTests
//
//  Created by Adam Ellis on 23/09/2026.
//

import Testing
@testable import CakeApp

@MainActor
struct CakeAppTests {

    @Test
    func dedupeAndSorting() async throws {
        let networkCakes = [
            Cake(
                title: "A duplicated cake",
                desc: "Description for a cake",
                image: "invalid-url"
            ),
            Cake(
                title: "A duplicated cake",
                desc: "Description for a duplicated cake",
                image: "invalid-url"
            ),
            Cake(
                title: "A cake",
                desc: "This is a simple cake",
                image: "invalid-url"
            ),
            Cake(
                title: "A Banana",
                desc: "This is an uppercase cake",
                image: "invalid-url"
            )
        ]
        
        let expectedCakes = [
            Cake(
                title: "A Banana",
                desc: "This is an uppercase cake",
                image: "invalid-url"
            ),
            Cake(
                title: "A cake",
                desc: "This is a simple cake",
                image: "invalid-url"
            ),
            Cake(
                title: "A duplicated cake",
                desc: "Description for a cake",
                image: "invalid-url"
            ),
            
        ]
        let viewModel = CakeViewModel(
            network: StubNetworkService(
                result: .success(networkCakes)
            )
        )
        await viewModel.load()
        guard case let .loaded(actualCakes) = viewModel.loadState else {
            Issue.record("Expected load state to be .loaded")
            return
        }
        #expect(expectedCakes == actualCakes)
    }
    
    @Test
    func sortingCaseInsensitive() async {
        let networkCakes = [
            Cake(
                title: "Carrot",
                desc: "",
                image: ""
            ),
            Cake(
                title: "banana",
                desc: "",
                image: ""
            ),
        ]
        
        let viewModel = CakeViewModel(
            network: StubNetworkService(
                result: .success(networkCakes)
            )
        )
        await viewModel.load()
        #expect(CakeViewModel.LoadState.loaded([networkCakes[1], networkCakes[0]]) == viewModel.loadState)
    }
    
    @Test
    func failedToLoad() async {
        let viewModel = CakeViewModel(
            network: StubNetworkService(
                result: .failure(
                    NetworkError.general(reason: "Unexpected error")
                )
            )
        )
        await viewModel.load()
        #expect(viewModel.loadState == .error(.general(reason: "Unexpected error")))
    }
    
    @Test
    func cancellationReceivedResetsToLastState() async {
        let network = StubNetworkService(
            result: .failure(NetworkError.general(reason: "Error state"))
        )
        let viewModel = CakeViewModel(
            network: network
        )
        await viewModel.load()
        #expect(viewModel.loadState == .error(NetworkError.general(reason: "Error state")))
        network.result = .failure(CancellationError())
        await viewModel.load()
        #expect(viewModel.loadState == .error(NetworkError.general(reason: "Error state")))
    }
    
    //TODO: Failed refresh would also keep loaded data
    //TODO: Test receiving network errors from e.g. decoding

}

final class StubNetworkService: NetworkService {
    
    init(result: Result<[CakeApp.Cake], Error>) {
        self.result = result
    }
    
    var result: Result<[CakeApp.Cake], Error>
    
    func loadCakes() async throws -> [CakeApp.Cake] {
        switch result {
        case let .success(cakes):
            cakes
        case let .failure(error):
            throw error
        }
    }
}
