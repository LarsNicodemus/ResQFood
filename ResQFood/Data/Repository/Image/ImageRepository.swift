//
//  ImageRepository.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 11.12.24.
//
import SwiftUI

protocol ImageRepository {
    func uploadImage(_ image: UIImage) async throws -> ImgurImageData
}
