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

    
    /// Lädt das ausgewählte Bild zu einem Imgur-Server hoch.
    /// - Updates: `uploadedImgurImageData` und `uploadedImage` mit den Daten des hochgeladenen Bildes.
    /// - Prints: Fehlermeldungen, wenn das Bild nicht hochgeladen werden kann.
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

    /// Verarbeitet die Auswahl eines neuen Bildes und lädt die Bilddaten.
    /// - Parameters:
    ///   - newItem: Das neu ausgewählte Bild.
    /// - Updates: `selectedImageData` und `selectedImage` mit den abgerufenen Bilddaten.
    /// - Prints: Fehlermeldungen, wenn das Bild nicht geladen werden kann.
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

    /// Verarbeitet die Auswahl mehrerer neuer Bilder und lädt die Bilddaten.
    /// - Parameters:
    ///   - newItems: Die neu ausgewählten Bilder.
    /// - Updates: `selectedImages` mit den abgerufenen Bilddaten.
    /// - Prints: Fehlermeldungen, wenn ein Bild nicht geladen werden kann.
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

    /// Lädt die ausgewählten Bilder zu einem Imgur-Server hoch.
    /// - Updates: `uploadedImages` mit den Daten der hochgeladenen Bilder.
    /// - Sets: `isLoading` auf true während des Uploads und auf false danach.
    /// - Prints: Fehlermeldungen, wenn ein Bild nicht hochgeladen werden kann.
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
    
    /// Setzt die Felder `selectedImages`, `selectedItems` und `uploadedImages` zurück.
    func resetFields() {
        selectedImages = []
        selectedItems = []
        uploadedImages  = []
    }
    
    /// Verarbeitet und lädt mehrere Bilder gleichzeitig hoch.
    /// - Parameters:
    ///   - items: Die zu verarbeitenden und hochzuladenden Bilder.
    /// - Updates: `selectedImages` und `uploadedImages` mit den abgerufenen und hochgeladenen Bilddaten.
    /// - Sets: `isLoading` auf true während des Prozesses und auf false danach.
    /// - Prints: Fehlermeldungen, wenn ein Bild nicht hochgeladen werden kann.
    func processAndUploadImages(items: [PhotosPickerItem]) async {
        isLoading = true
        var newImages: [UIImage] = []
        var uploadedUrls: [AppImage] = []
        
        await withTaskGroup(of: UIImage?.self) { group in
            for item in items {
                group.addTask {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        return uiImage
                    }
                    return nil
                }
            }
            
            for await image in group {
                if let image = image {
                    newImages.append(image)
                }
            }
        }
        await withTaskGroup(of: AppImage?.self) { group in
            for image in newImages {
                group.addTask {
                    do {
                        let uploadedImageData = try await self.imageRepository.uploadImage(image)
                        return AppImage(
                            id: uploadedImageData.id,
                            deletehash: uploadedImageData.deletehash,
                            url: uploadedImageData.link
                        )
                    } catch {
                        print("Upload Error: \(error.localizedDescription)")
                        return nil
                    }
                }
            }
            
            for await result in group {
                if let uploadedImage = result {
                    uploadedUrls.append(uploadedImage)
                }
            }
        }
        self.selectedImages = newImages
        self.uploadedImages = uploadedUrls
        self.isLoading = false
    }
    
}
