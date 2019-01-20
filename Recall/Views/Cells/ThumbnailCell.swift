//
//  ThumbnailCell.swift
//  Recall
//
//  Created by Tiago Alves on 10/01/2019.
//  Copyright © 2019 Recall. All rights reserved.
//

import UIKit
import Blockstack

class ThumbnailCell: UICollectionViewCell {
    @IBOutlet var imageView : UIImageView!
    
    func setPhoto(photo: Photo) {
        Blockstack.shared.getFile(at: photo.minimalPhotoPath(), decrypt: true, completion: { (imageData, error) in
            if let decryptedResponse = imageData as? DecryptedValue {
                if let decryptedImage = decryptedResponse.bytes {
                    let imageData = NSData(bytes: decryptedImage, length: decryptedImage.count)
                    DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                        var image = UIImage(data: imageData as Data)
                        if photo.orientation == 2 || photo.orientation == 4 || photo.orientation == 5 || photo.orientation == 7 {
                            image = image?.imageRotatedByDegrees(degrees: 0, flip: true)
                        }
                        if photo.orientation == 3 || photo.orientation == 4 {
                            image = image?.imageRotatedByDegrees(degrees: 180, flip: false)
                        }
                        if photo.orientation == 7 || photo.orientation == 8 {
                            image = image?.imageRotatedByDegrees(degrees: 90, flip: false)
                        }
                        if photo.orientation == 5 || photo.orientation == 6 {
                            image = image?.imageRotatedByDegrees(degrees: 270, flip: false)
                        }
                        
                        self.imageView.image = image
                    })
                }
            }
        })
    }
}

extension UIImage {
    public func imageRotatedByDegrees(degrees: CGFloat, flip: Bool) -> UIImage {
        let degreesToRadians: (CGFloat) -> CGFloat = {
            return $0 / 180.0 * CGFloat(Double.pi)
        }
        
        // calculate the size of the rotated view's containing box for our drawing space
        let rotatedViewBox = UIView(frame: CGRect(origin: CGPoint.zero, size: size))
        let t = CGAffineTransform(rotationAngle: degreesToRadians(degrees));
        rotatedViewBox.transform = t
        let rotatedSize = rotatedViewBox.frame.size
        
        // Create the bitmap context
        UIGraphicsBeginImageContext(rotatedSize)
        let bitmap = UIGraphicsGetCurrentContext()
        
        // Move the origin to the middle of the image so we will rotate and scale around the center.
        bitmap?.translateBy(x: rotatedSize.width / 2.0, y: rotatedSize.height / 2.0)
        
        //   // Rotate the image context
        bitmap?.rotate(by: degreesToRadians(degrees))
        
        // Now, draw the rotated/scaled image into the context
        var yFlip: CGFloat
        
        if(flip){
            yFlip = CGFloat(-1.0)
        } else {
            yFlip = CGFloat(1.0)
        }
        
        bitmap?.scaleBy(x: yFlip, y: -1.0)
        bitmap?.draw(cgImage!, in: CGRect.init(x: -size.width / 2, y: -size.height / 2, width: size.width, height: size.height))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}
