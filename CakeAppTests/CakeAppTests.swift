//
//  CakeAppTests.swift
//  CakeAppTests
//
//  Created by Adam Ellis on 23/09/2026.
//

import Testing
@testable import CakeApp

struct CakeAppTests {

    @Test func example() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    }
    
    @MainActor
    @Test func testCakeFiltering() async throws {
        let cakes = [
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
        ]
        let viewModel = ContentView.CakeViewModel(network: HttpStub(cakes: cakes))
        
        try await viewModel.load()
        #expect([cakes[0], cakes[2]] == viewModel.cakes)
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
    
    let cakes: [CakeApp.Cake]
    
    func loadCakes() async throws -> [CakeApp.Cake] {
        cakes
    }
    
    
    
}
