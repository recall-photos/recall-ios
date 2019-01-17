//
//  Photo.swift
//  Recall
//
//  Created by Tiago Alves on 10/01/2019.
//  Copyright © 2019 Recall. All rights reserved.
//

import Foundation

class Photo {
    var compressedPhotoPath : String?
    var photoPath : String?
    var orientation : Int?
    
    init(photoPath: String?, compressedPhotoPath: String?, orientation: Int?) {
        if let photoPath = photoPath {
            self.photoPath = photoPath
        }
        if let compressedPhotoPath = compressedPhotoPath {
            self.compressedPhotoPath = compressedPhotoPath
        }
        if let orientation = orientation {
            self.orientation = orientation
        }
    }
    
    init(compressedPhotoPath: String?, orientation: Int?) {
        if let compressedPhotoPath = compressedPhotoPath {
            self.compressedPhotoPath = compressedPhotoPath
        }
        if let orientation = orientation {
            self.orientation = orientation
        }
    }
    
    func minimalPhotoPath() -> String {
        if let compressedPhotoPath = self.compressedPhotoPath {
            return compressedPhotoPath
        } else if let photoPath = self.photoPath {
            return photoPath
        } else {
            return ""
        }
    }
}
