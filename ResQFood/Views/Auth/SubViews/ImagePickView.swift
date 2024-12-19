//
//  ImagePickView.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 18.12.24.
//

import PhotosUI
import SwiftUI

struct ImagePickView: View {
    @EnvironmentObject var profileVM: ProfileViewModel
    @EnvironmentObject var imageVM: ImageViewModel

    var body: some View {
        VStack {
            if imageVM.selectedImage != nil {
                
                if let image = imageVM.selectedImage {
                    ImageView(image: Image(uiImage: image))
                }

            } else {
                PhotosPicker(
                    selection: $imageVM.selectedItem,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    ImageView(image: Image("placeholder"))
                }
            }

            PhotosPicker(
                selection: $imageVM.selectedItem,
                matching: .images,
                photoLibrary: .shared()
            ) {
                Text("Bild auswählen")

            }
            .primaryButtonStyle()

            Button("Bild hochladen") {
                Task {
                    await imageVM.uploadImage()
                    profileVM.pictureUrl = imageVM.uploadedImage?.url
                }
            }
            .primaryButtonStyle()
        }
        .onChange(of: imageVM.selectedItem) {
            oldItems, newItems in
            Task {
                await imageVM.handleImageSelection(
                    newItem: newItems)
            }
        }
    }
}
