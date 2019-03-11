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
    var uuid : String?
    var orientation : Int?
    var takenAt : Date?
    var uploadedAt : Date?
    
    init(photoPath: String?, compressedPhotoPath: String?, uuid: String?, orientation: Int?, takenAt: Double? = nil, uploadedAt: Double? = nil) {
        if let photoPath = photoPath {
            self.photoPath = photoPath
        }
        if let compressedPhotoPath = compressedPhotoPath {
            self.compressedPhotoPath = compressedPhotoPath
        }
        if let uuid = uuid {
            self.uuid = uuid
        }
        if let orientation = orientation {
            self.orientation = orientation
        }
        if let takenAt = takenAt {
            let date = Date(timeIntervalSince1970: TimeInterval(takenAt) / 1000)
            self.takenAt = date
        }
        if let uploadedAt = uploadedAt {
            let date = Date(timeIntervalSince1970: TimeInterval(uploadedAt) / 1000)
            self.uploadedAt = date
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
