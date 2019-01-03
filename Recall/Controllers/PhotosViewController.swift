//
//  PhotosViewController.swift
//  Recall
//
//  Created by Tiago Alves on 24/12/2018.
//  Copyright © 2018 Recall. All rights reserved.
//

import UIKit
import Blockstack

class PhotosViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        Blockstack.shared.getFile(at: "photos.json", decrypt: true) { (response, error) in
            let responseString = (response as! DecryptedValue).plainText
            if let photos = responseString!.parseJSONString {
                print(photos)
            }
        }
    }
}
