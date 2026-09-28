//
//  CakeAppTests.swift
//  CakeAppTests
//
//  Created by Adam Ellis on 23/09/2026.
//

import Testing
@testable import CakeApp

struct CakeAppTests {

    @MainActor
    @Test(
        arguments: [
            (
                [
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
                ],
                [
                    Cake(
                        title: "A cake",
                        desc: "This is a simple cake",
                        image: "invalid-url"
                    ),
                    Cake(
                        title: "A duplicated cake",
                        desc: "Description for a cake",
                        image: "invalid-url"
                    )
                ]
            )
        ]
    )
    func dedupeAndSorting(networkCakes: [Cake], expectedCakes: [Cake]) async throws {
        
        let viewModel = ContentView.CakeViewModel(
            network: HttpStub(
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
    
    @MainActor
    @Test
    func failedToLoad() async throws {
        let viewModel = ContentView.CakeViewModel(
            network: HttpStub(
                result: .failure(
                    NetworkError.general(reason: "Unexpected error")
                )
            )
        )
        await viewModel.load()
        guard case .error = viewModel.loadState else {
            Issue.record("Expected error to be thrown")
            return
        }
    }

}
extension Cake: @retroactive Equatable {
    public static func == (lhs: Cake, rhs: Cake) -> Bool {
        lhs.title == rhs.title
        && lhs.desc == rhs.desc
        && lhs.image == rhs.image
    }
}

struct HttpStub: NetworkLayer {
    
    let result: Result<[CakeApp.Cake], Error>
    
    func loadCakes() async throws -> [CakeApp.Cake] {
        switch result {
        case let .success(cakes):
            cakes
        case let .failure(error):
            throw error
        }
    }
    
    
    
}
