//
//  WebService.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 11.12.24.
//

import SwiftUI

class WebService {
    
    /// Lädt Daten von einer URL herunter und dekodiert sie in das angegebene Typ.
    /// - Parameters:
    ///   - urlString: Die URL als String, von der die Daten heruntergeladen werden sollen.
    /// - Throws: `HTTPError.invalidURL` wenn die URL ungültig ist.
    /// - Returns: Die dekodierten Daten des Typs `T`.
    func downloadData<T: Codable>(urlString: String) async throws -> T {
        guard let url = URL(string: urlString) else {
            throw HTTPError.invalidURL
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        let result = try JSONDecoder().decode(T.self, from: data)

        return result
    }

    /// Lädt Daten von einer URL herunter, wobei spezifische Header verwendet werden, und dekodiert sie in das angegebene Typ.
    /// - Parameters:
    ///   - urlString: Die URL als String, von der die Daten heruntergeladen werden sollen.
    ///   - headers: Ein Dictionary mit Header-Feldern und Werten.
    /// - Throws: `HTTPError.invalidURL` wenn die URL ungültig ist.
    /// - Returns: Die dekodierten Daten des Typs `T`.
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
    
    /// Lädt Daten hoch und dekodiert die Antwort in das angegebene Typ.
    /// - Parameters:
    ///   - urlString: Die URL als String, zu der die Daten hochgeladen werden sollen.
    ///   - method: Die HTTP-Methode (Standard ist "POST").
    ///   - headers: Ein optionales Dictionary mit Header-Feldern und Werten.
    ///   - body: Der zu sendende HTTP-Body als Data.
    /// - Throws: `HTTPError.invalidURL` wenn die URL ungültig ist.
    /// - Returns: Die dekodierten Daten des Typs `T`.
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
    
    /// Löscht Daten von einer URL und dekodiert die Antwort in das angegebene Typ.
    /// - Parameters:
    ///   - urlString: Die URL als String, von der die Daten gelöscht werden sollen.
    ///   - method: Die HTTP-Methode (Standard ist "GET").
    ///   - headers: Ein optionales Dictionary mit Header-Feldern und Werten.
    ///   - body: Ein optionaler HTTP-Body als Data.
    /// - Throws: `HTTPError.invalidURL` wenn die URL ungültig ist.
    /// - Throws: `HTTPError.networkError` wenn die Antwort einen Statuscode außerhalb des Bereichs 200-299 hat.
    /// - Returns: Die dekodierten Daten des Typs `T`.
    func deleteData<T: Codable>(
        urlString: String,
        method: String = "GET",
        headers: [String: String]? = nil,
        body: Data? = nil
    ) async throws -> T {
        guard let url = URL(string: urlString) else {
            throw HTTPError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.allHTTPHeaderFields = headers
        request.httpBody = body
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw HTTPError.networkError
        }

        return try JSONDecoder().decode(T.self, from: data)
    }
}
