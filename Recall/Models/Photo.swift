//
//  Photo.swift
//  Recall
//
//  Created by Tiago Alves on 10/01/2019.
//  Copyright © 2019 Recall. All rights reserved.
//

import Foundation

class Photo {
    var compressedPhotoPath : String
    var orientation : Int?
    
    init(compressedPhotoPath: String, orientation: Int?) {
        self.compressedPhotoPath = compressedPhotoPath
        if let orientation = orientation {
            self.orientation = orientation
        }
    }
}
