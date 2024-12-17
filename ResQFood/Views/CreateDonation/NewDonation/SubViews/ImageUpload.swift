import PhotosUI
//
//  ImageUpload.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 11.12.24.
//
import SwiftUI

struct ImageUploadView: View {

    @StateObject var imageVM: ImageViewModel = ImageViewModel()

    var body: some View {
        VStack {

            PhotosPicker(
                selection: $imageVM.selectedItem,
                matching: .images,
                photoLibrary: .shared()
            ) {
                Text("Bild auswählen")
            }
            .onChange(of: imageVM.selectedItem) { oldItem, newItem in
                Task {
                    await imageVM.handleImageSelection(newItem: newItem)
                }
            }

            if let selectedImageData = imageVM.selectedImageData,
                let uiImage = UIImage(data: selectedImageData)
            {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .frame(width: 200, height: 200)
            }

            Button("Bild hochladen") {
                Task {
                    await imageVM.uploadImage()
                }
            }

//            if let urlString = imageVM.uploadedImgurImageData?.link {
//                Text("Hochgeladene Bild-URL: \(urlString)")
//                ImageView(imageURL: urlString)
//            }
        }
        
//        Button("Bild Löschen") {
//            Task {
//                 imageVM.deleteImage(imageVM.uploadedImgurImageData!)
//            }
//        }
        
    }
}
#Preview {
    ImageUploadView()
}
