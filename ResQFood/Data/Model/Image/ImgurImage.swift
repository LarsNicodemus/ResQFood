//
//  ImgurImage.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 11.12.24.
//
import SwiftUI

struct ImgurImage {
    let id: String
    let url: String
    let thumbnailUrl: String
}


struct AppImage: Codable, Identifiable {
    var id: String = UUID().uuidString
    var deletehash: String
    var url: String

}
