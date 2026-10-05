//
//  Network.swift
//  CakeApp
//
//  Created by Adam Ellis on 29/09/2026.
//
import Foundation

enum NetworkError: Error {
    case httpError(statusCode: Int)
    case general(reason: String)
    case offline
    case timeout
    case decoding
}

protocol NetworkService {
    func loadCakes() async throws -> [Cake]
}

struct Network: NetworkService {
    
    func loadCakes() async throws -> [Cake] {
        let url = "https://raw.githubusercontent.com/Waracle/mobile-coding-test-api/refs/heads/main/cakes"
        guard let cakesUrl = URL(string: url) else {
            throw NetworkError.general(reason: "Invalid URL provided")
        }
        var request = URLRequest(url: cakesUrl)
        request.timeoutInterval = 5
        // Disabling cache so that error shown on reload, if network unavailable.
        request.cachePolicy = .reloadIgnoringLocalCacheData
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.general(reason: "Invalid response type")
            }
            guard (200..<300).contains(httpResponse.statusCode) else {
                throw NetworkError.httpError(statusCode: httpResponse.statusCode)
            }
            return try JSONDecoder().decode([Cake].self, from: data)
        } catch let error as CancellationError {
            throw error
        } catch let error as NetworkError {
            throw error
        } catch let error as URLError {
            switch error.code {
            case .notConnectedToInternet, .networkConnectionLost: throw NetworkError.offline
            case .timedOut: throw NetworkError.timeout
            case .cancelled: throw CancellationError()
            default: throw NetworkError.general(reason: error.localizedDescription)
            }
        } catch _ as DecodingError {
            throw NetworkError.decoding
        } catch {
            throw NetworkError.general(reason: error.localizedDescription)
        }
//        } catch let error as NetworkError {
//            throw error
//        } catch let error as URLError {
////            switch error.code {
////            case .notConnectedToInternet, .networkConnectionLost: .offline
////            }
    }
}
