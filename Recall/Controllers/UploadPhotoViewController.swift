//
//  UploadPhotoViewController.swift
//  Recall
//
//  Created by Tiago Alves on 03/02/2019.
//  Copyright © 2019 Recall. All rights reserved.
//

import UIKit
import YPImagePicker

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
                
            }
            picker.dismiss(animated: true, completion: nil)
        }
        present(picker, animated: true, completion: nil)
    }
}
