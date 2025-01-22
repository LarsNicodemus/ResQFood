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
    
    
    func uploadImage(_ image: UIImage) async throws -> ImgurImageData {
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            throw HTTPError.networkError
        }

        let base64Image = imageData.base64EncodedString()
        print("Base64 Imagedata: \(base64Image.prefix(50))...")

        let urlString = baseURL + "/image"
        let headers = [
            "Authorization": "Client-ID \(APIClientId)",
            "Content-Type": "application/json"
        ]
        let parameters = ["image": base64Image]
        let bodyData = try JSONSerialization.data(withJSONObject: parameters)

        let response: ImgurUploadResponse = try await webService.uploadData(
            urlString: urlString,
            method: "POST",
            headers: headers,
            body: bodyData
        )

        return response.data
    }
    


    func deleteImage(deleteHash: String) async throws -> Bool {
        let urlString = baseURL + "/image/\(deleteHash)"
        let headers = [
            "Authorization": "Client-ID \(APIClientId)"
        ]

        let response: DeleteResponse = try await webService.deleteData(
            urlString: urlString,
            method: "DELETE",
            headers: headers
        )
        
        return response.success
    }
}
