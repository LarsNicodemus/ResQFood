//
//  ImageUpload.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 11.12.24.
//
import SwiftUI
import PhotosUI

struct ImagePickUploadView: View {
    @EnvironmentObject var donVM: DonationViewModel
    @EnvironmentObject var imageVM: ImageViewModel

    var body: some View {
        VStack {
            if !imageVM.selectedImages.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(
                            imageVM.selectedImages, id: \.self
                        ) { image in
                            ImageView(image: Image(uiImage: image))
                        }
                    }
                }
            } else {
                PhotosPicker(
                    selection: $imageVM.selectedItems,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    ImageView(image: Image("placeholder"))
                }
            }

            PhotosPicker(
                selection: $imageVM.selectedItems,
                matching: .images,
                photoLibrary: .shared()
            ) {
                Text("Bilder auswählen")

            }
            .primaryButtonStyle()

            if let picturesError = donVM.picturesError {
                Text(picturesError)
                    .font(.caption)
                    .foregroundStyle(Color("error"))
            }
        }
        .onChange(of: imageVM.selectedItems) { _, newItems in
                    Task {
                        await imageVM.processAndUploadImages(items: newItems)
                        if !imageVM.uploadedImages.isEmpty {
                            donVM.picturesUrl = imageVM.uploadedImages.map(\.url)
                        }
                    }
                }
        .overlay {
                    if imageVM.isLoading {
                        ProgressView()
                            .background(Color.black.opacity(0.4))
                    }
                }
    }
}

