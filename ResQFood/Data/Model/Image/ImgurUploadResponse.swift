//
//  ImgurUploadResponse.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 11.12.24.
//

struct ImgurUploadResponse: Codable {
    let data: ImgurImageData
    let success: Bool
    let status: Int
}

