//
//  ImageUpload.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 11.12.24.
//
import SwiftUI
import PhotosUI

struct ImageUploadView: View {
    @State private var selectedImage: UIImage?
    @State private var uploadedImageURL: String?
    @State private var isShowingImagePicker = false
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    @State var imageURL: String? = nil
    let imageRepository: ImageRepository = ImageRepositoryImplementation()
    
    
    var body: some View {
        VStack {
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            }
            
            Button("Select a Photo") {
                isShowingImagePicker = true
            }
            
            Button("Bild hochladen") {
                Task {
                    guard let image = selectedImage else {
                        print("Kein Bild ausgewählt")
                        return
                    }

                    do {
                        print("Bild zum Hochladen: \(image)")
                        let uploadedURL = try await imageRepository.uploadImage(image)
                        uploadedImageURL = uploadedURL
                        imageURL = uploadedURL
                        print("Bild hochgeladen: \(uploadedURL)")
                    } catch {
                        print("Upload Fehler: \(error.localizedDescription)")
                    }
                }
            }
            
            if let urlString = uploadedImageURL {
                Text("Hochgeladene Bild-URL: \(urlString)")
                ImageView(imageURL: urlString)
            }
        }
        .sheet(isPresented: $isShowingImagePicker) {
            VStack {
                PhotosPicker(
                    selection: $selectedItem,
                    matching: .images,
                    photoLibrary: .shared()) {
                        Text("Select a Photo")
                    }
                    .onChange(of: selectedItem) { oldItem, newItem in
                        Task {
                            do {
                                if let data = try await newItem?.loadTransferable(type: Data.self) {
                                    selectedImageData = data
                                    if let uiImage = UIImage(data: data) {
                                        selectedImage = uiImage
                                    } else {
                                        print("Fehler: Bild konnte nicht aus den Daten erstellt werden.")
                                    }
                                } else {
                                    print("Fehler: Keine Daten gefunden.")
                                }
                            } catch {
                                print("Fehler beim Laden der Bilddaten: \(error.localizedDescription)")
                            }
                        }
                    }
                
                if let selectedImageData, let uiImage = UIImage(data: selectedImageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                }
                

            }
        }
    }
}
