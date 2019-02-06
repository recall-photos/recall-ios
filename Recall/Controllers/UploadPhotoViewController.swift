//
//  UploadPhotoViewController.swift
//  Recall
//
//  Created by Tiago Alves on 03/02/2019.
//  Copyright © 2019 Recall. All rights reserved.
//

import UIKit
import YPImagePicker
import Blockstack
import SVProgressHUD

class UploadPhotoViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var config = YPImagePickerConfiguration()
        config.library.mediaType = .photo
        config.isScrollToChangeModesEnabled = true
        config.usesFrontCamera = false
        config.showsFilters = true
        config.filters = [YPFilter(name: "Normal", applier: nil),
                          YPFilter(name: "Nashville", applier: YPFilter.nashvilleFilter),
                          YPFilter(name: "Chrome", coreImageFilterName: "CIPhotoEffectChrome"),
                          YPFilter(name: "Fade", coreImageFilterName: "CIPhotoEffectFade"),
                          YPFilter(name: "Instant", coreImageFilterName: "CIPhotoEffectInstant"),
                          YPFilter(name: "Mono", coreImageFilterName: "CIPhotoEffectMono"),
                          YPFilter(name: "Noir", coreImageFilterName: "CIPhotoEffectNoir"),
                          YPFilter(name: "Process", coreImageFilterName: "CIPhotoEffectProcess"),
                          YPFilter(name: "Transfer", coreImageFilterName: "CIPhotoEffectTransfer"),
                          YPFilter(name: "Tone", coreImageFilterName: "CILinearToSRGBToneCurve"),
                          YPFilter(name: "Sepia", coreImageFilterName: "CISepiaTone")]
        config.startOnScreen = .library
        config.screens = [.library, .photo]
        config.showsCrop = .none
        config.targetImageSize = YPImageSize.original
        config.hidesStatusBar = false
        config.hidesBottomBar = false
        
        let picker = YPImagePicker(configuration: config)
        picker.didFinishPicking { [unowned picker] items, _ in
            if let photo = items.singlePhoto {
                self.upload(photo: photo)
            }
            picker.dismiss(animated: true, completion: nil)
        }
        present(picker, animated: true, completion: nil)
    }
    
    func upload(photo : YPMediaPhoto) {
        if let imageData = photo.image.jpeg(.lowest) {
            let bytes = imageData.bytes
            
            let imageName = "mobileUpload.jpg"
            
            SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.clear)
            SVProgressHUD.show()
            
            Blockstack.shared.getFile(at: "photos.json", decrypt: true, completion: { (response, error) in
                if let decryptedResponse = response as? DecryptedValue {
                    let responseString = decryptedResponse.plainText
                    
                    if let parsedPhotos = responseString!.parseJSONString as? Array<Any> {
                        var photosArray = parsedPhotos as! Array<NSDictionary>
                        
                        Blockstack.shared.putFile(to: "compressed_images/\(imageName)", bytes: bytes, encrypt: true, completion: { (file, error) in
                            Blockstack.shared.putFile(to: "images/\(imageName)", bytes: bytes, encrypt: true, completion: { (file, error) in
                                let newPhoto = [
                                    "path": "images/\(imageName)",
                                    "uploadedAt": Date().millisecondsSince1970,
                                    "uuid": "1234",
                                    "compressedPath": "compressed_images/\(imageName)",
                                    "name": imageName
                                ] as NSDictionary
                                
                                photosArray.append(newPhoto)
                                
                                Blockstack.shared.putFile(to: "photos.json", text: self.json(from: photosArray)!, encrypt: true, completion: { (file, error) in
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                                        SVProgressHUD.dismiss()
                                        print("Uploaded photo")
                                    })
                                })
                            })
                        })
                        
                    }
                }
            })
        }
    }
    
    func json(from object:Any) -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: []) else {
            return nil
        }
        return String(data: data, encoding: String.Encoding.utf8)
    }
}
