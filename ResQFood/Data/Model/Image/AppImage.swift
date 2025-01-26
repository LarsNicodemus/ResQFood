//
//  ImgurImage.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 11.12.24.
//
import SwiftUI

struct AppImage: Codable, Identifiable {
    var id: String = UUID().uuidString
    var deletehash: String
    var url: String

}
