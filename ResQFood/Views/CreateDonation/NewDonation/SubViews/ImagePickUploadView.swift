import PhotosUI
//
//  ImageUpload.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 11.12.24.
//
import SwiftUI

struct ImagePickUploadView: View {
    @EnvironmentObject var donVM: DonationViewModel
    @EnvironmentObject var locVM: LocationViewModel
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
            
            Button("Bilder hochladen") {
                Task {
                    await imageVM.uploadImages()
                    for image in imageVM.uploadedImages {
                        donVM.picturesUrl.append(image.url)
                    }
                }
            }
            .primaryButtonStyle()
        }
        .onChange(of: imageVM.selectedItems) {
            oldItems, newItems in
            Task {
                await imageVM.handleImageSelection(
                    newItems: newItems)
            }
        }
    }
}

