//
//  ImageViewModel.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 12.12.24.
//

import PhotosUI
import SwiftUI

@MainActor
class ImageViewModel: ObservableObject {

    let imageRepository: ImageRepository = ImageRepositoryImplementation()

    @Published var selectedImage: UIImage?
    @Published var uploadedImageURL: String?
    @Published var selectedItem: PhotosPickerItem? = nil

    @Published var selectedImages: [UIImage] = []
    @Published var selectedItems: [PhotosPickerItem] = []
    @Published var uploadedImages: [AppImage] = []

    @Published var selectedImageData: Data?
    @Published var imageURL: String? = nil
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var images: [ImgurImageData] = []
    @Published var uploadedImgurImageData: ImgurImageData?
    @Published var uploadedImage: AppImage?

    func uploadImage() async {
        guard let image = selectedImage else {
            print("No image selected")
            return
        }

        do {
            print("Image to upload: \(image)")
            let uploadedImageData = try await imageRepository.uploadImage(image)

            uploadedImgurImageData = uploadedImageData
            uploadedImage = AppImage(
                id: uploadedImgurImageData!.id,
                deletehash: uploadedImgurImageData!.deletehash,
                url: uploadedImgurImageData!.link)

            print("Image uploaded: \(uploadedImageData)")
        } catch {
            print("Upload Error: \(error.localizedDescription)")
        }
    }

    func uploadImagenew() async {
        isLoading = true
        uploadedImages = []
        do {
            for image in selectedImages {
                let uploadedImageData = try await imageRepository.uploadImage(
                    image)
                let appImage = AppImage(
                    id: uploadedImageData.id,
                    deletehash: uploadedImageData.deletehash,
                    url: uploadedImageData.link)
                uploadedImages.append(appImage)
            }
            print("Images uploaded: \(uploadedImages)")
        } catch {
            print("Upload Error: \(error.localizedDescription)")
        }
        isLoading = false
    }

    func handleImageSelection(newItem: PhotosPickerItem?) async {
        do {
            if let data = try await newItem?.loadTransferable(type: Data.self) {
                selectedImageData = data
                if let uiImage = UIImage(data: data) {
                    selectedImage = uiImage
                } else {
                    print(
                        "Error: Image could not be created from data.")
                }
            } else {
                print("Error: No data found.")
            }
        } catch {
            print(
                "Error loading image data: \(error.localizedDescription)"
            )
        }
    }

    func deleteImage(_ image: ImgurImageData) {
        Task {
            isLoading = true
            do {
                let success = try await imageRepository.deleteImage(
                    deleteHash: image.deletehash)
                if success {
                    uploadedImgurImageData = nil
                    uploadedImage = nil
                    print("Image deleted")
                }
            } catch {
                errorMessage =
                    "Fehler beim Löschen: \(error.localizedDescription)"
            }
            isLoading = false
        }
    }

    func handleImageSelection(newItems: [PhotosPickerItem]) async {
        selectedImages = []

        for item in newItems {
            do {
                if let data = try await item.loadTransferable(type: Data.self),
                    let uiImage = UIImage(data: data)
                {
                    selectedImages.append(uiImage)
                } else {
                    print("Error: Could not load image data.")
                }
            } catch {
                print("Error loading image data: \(error.localizedDescription)")
            }
        }
    }

    func uploadImages() async {
        isLoading = true
        uploadedImages = []
        do {
            for image in selectedImages {
                let uploadedImageData = try await imageRepository.uploadImage(
                    image)
                let appImage = AppImage(
                    id: uploadedImageData.id,
                    deletehash: uploadedImageData.deletehash,
                    url: uploadedImageData.link)
                uploadedImages.append(appImage)
            }
            print("Images uploaded: \(uploadedImages)")
        } catch {
            print("Upload Error: \(error.localizedDescription)")
        }
        isLoading = false
    }
}
