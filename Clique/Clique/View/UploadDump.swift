//
//  UploadDump.swift
//  Clique
//
//  Created by Administrator on 4/16/25.
//

import SwiftUI
import PhotosUI

struct UploadDump: View {
    @State private var selectedItems  = [PhotosPickerItem]()
    @State private var selectedImages = [UIImage]()
    @StateObject var postViewModel: PostViewModel
    @ObservedObject var userViewModel: UserViewModel
    @State private var captions: [String] = ["", "", "", "", ""]

    let currentGroupID: String

    var body: some View {
        NavigationStack {
            contentView
                .onChange(of: selectedItems, perform: loadImages)
                .toolbar { nextButton }
                .navigationTitle("New Dump")
        }
    }

    // MARK: – Split out the scrolling/photo list
    private var contentView: some View {
        ScrollView {
            LazyVStack {
                PhotosPicker(
                    "Select images",
                    selection: $selectedItems,
                    maxSelectionCount: 5,
                    matching: .images
                )
                ForEach(0..<selectedImages.count, id: \.self) { i in
                    UploadPhotoView(
                        postViewModel: postViewModel,
                        img: Image(uiImage: selectedImages[i]),
                        caption: $captions[i]
                    )
                }
            }
            .padding()
        }
    }

    // MARK: – Split out the Next button into its own ToolbarItem
    private var nextButton: some ToolbarContent {
        ToolbarItem(placement: .confirmationAction) {
            Button("Next") {
                Task {
                    do {
                        try await postViewModel.uploadDump(
                            groupID: currentGroupID,
                            imgs: selectedImages,
                            captions: captions
                        )
                        // …handle success (dismiss or navigate)…
                    } catch {
                        print("Upload failed:", error)
                    }
                }
                
            }
            .disabled(selectedImages.isEmpty)
        }
    }

    // MARK: – Move your onChange handler into a named function
    private func loadImages(_ items: [PhotosPickerItem]) {
        selectedImages.removeAll()
        Task {
            for item in items {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    await MainActor.run {
                        selectedImages.append(uiImage)
                    }
                }
            }
        }
    }
}


/*
 struct UploadDump_Previews: PreviewProvider {
 static var previews: some View {
 UploadDump()
 }
 }
 */
