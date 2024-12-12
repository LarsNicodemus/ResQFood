//
//  ImageRepositoryImplementation.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 11.12.24.
//
import SwiftUI

class ImageRepositoryImplementation: ImageRepository {
    private let baseURL = "https://api.imgur.com/3"
    private let imageService = ImageService.shared
    private let webService: WebService = WebService()
    
    
    func uploadImage(_ image: UIImage) async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            throw HTTPError.networkError
        }
        
        let base64Image = imageData.base64EncodedString()
        print("Base64 Bilddaten: \(base64Image.prefix(50))...")
        
        let urlString = baseURL + "/image"
        let headers = [
            "Authorization": "Client-ID {{\(APIClientId)}}",
            "Content-Type": "application/json"
        ]
        
        let parameters = ["image": base64Image]
        let bodyData = try JSONSerialization.data(withJSONObject: parameters)
        
        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = bodyData

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw HTTPError.networkError
            }
            
            print("HTTP Response Status Code: \(httpResponse.statusCode)")
            
            if (200...299).contains(httpResponse.statusCode) {
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Rohe Antwort der API: \(responseString)")
                }
                
                let decoder = JSONDecoder()
                do {
                    let uploadResponse = try decoder.decode(ImgurUploadResponse.self, from: data)
                    print("Upload Antwort: \(uploadResponse)")
                    
                    return uploadResponse.data.link
                } catch {
                    print("Fehler beim Dekodieren der Antwort: \(error.localizedDescription)")
                    throw error
                }
            } else {
                print("Fehler beim Upload: \(httpResponse.statusCode)")
                throw HTTPError.networkError
            }
        } catch {
            print("Fehler beim Upload: \(error.localizedDescription)")
            throw error
        }
    }
    
    
    func downloadImage(from urlString: String) async throws -> Data {
        guard let url = URL(string: urlString) else {
            throw HTTPError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
            (200...299).contains(httpResponse.statusCode)
        else {
            throw HTTPError.networkError
        }

        return data
    }

}
