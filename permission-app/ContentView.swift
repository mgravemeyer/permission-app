//
//  ContentView.swift
//  permission-app
//
//  Created by Maximilian Gravemeyer on 25.05.21.
//

import SwiftUI
import Photos

struct ContentView: View {
    
    @Environment(\.scenePhase) var scenePhase
    
    @State var images = [UIImage]()
    @State var permission = String()
    
    var body: some View {
        VStack {
            Text("Permission: \(self.permission)")
            Button("Load Photos!") {
                let fetchOptionsPhoto = PHFetchOptions()
                fetchOptionsPhoto.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: false)]
                fetchOptionsPhoto.fetchLimit = 3
                let reqImage = PHAsset.fetchAssets(with: .image, options: fetchOptionsPhoto)
                reqImage.enumerateObjects { (phAsset, _, _) in
                let options = PHImageRequestOptions()
                options.isSynchronous  = true
                    phAsset.requestContentEditingInput(with: PHContentEditingInputRequestOptions()) { (eidtingInput, info) in
                        self.images.append(getAssetThumbnail(asset: phAsset))
                    }
                }
            }
            ForEach(self.images, id: \.self) { image in
                Image(uiImage: image)
            }
        }
        .onAppear {
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                switch status {
                case PHAuthorizationStatus.notDetermined:
                    permission = "notDetermined"
                    print("here")
                    break
                case PHAuthorizationStatus.restricted:
                    permission = "restricted"
                    break
                case PHAuthorizationStatus.denied:
                    permission = "denied"
                    break
                case PHAuthorizationStatus.authorized:
                    permission = "authorized"
                    break
                case PHAuthorizationStatus.limited:
                    permission = "limited"
                    break
                @unknown default:
                    fatalError()
                }
            }
        }
    }
}

func getAssetThumbnail(asset: PHAsset) -> UIImage {
    let manager = PHImageManager.default()
    let option = PHImageRequestOptions()
    var thumbnail = UIImage()
    option.isSynchronous = true
    manager.requestImage(for: asset, targetSize: CGSize(width: 100.0, height: 100.0), contentMode: .aspectFit, options: option, resultHandler: {(result, info)->Void in
            thumbnail = result!
    })
    return thumbnail
}
