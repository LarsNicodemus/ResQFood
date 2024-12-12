//
//  WebService.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 11.12.24.
//

import SwiftUI

class WebService {
    func downloadData<T: Codable>(urlString: String) async throws -> T {
        guard let url = URL(string: urlString) else {
            throw HTTPError.invalidURL
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        let result = try JSONDecoder().decode(T.self, from: data)

        return result
    }

    func downloadDataWithHeader<T: Codable>(
        urlString: String, headers: [String: String]
    ) async throws -> T {
        guard let url = URL(string: urlString) else {
            throw HTTPError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers

        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(T.self, from: data)

        return response
    }
    
    func uploadData<T: Codable>(
        urlString: String, method: String = "POST",
        headers: [String: String]? = nil, body: Data
    ) async throws -> T {
        guard let url = URL(string: urlString) else {
            throw HTTPError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.allHTTPHeaderFields = headers
        request.httpBody = body
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(T.self, from: data)

        return response
    }
}
