//
//  PhotosViewController.swift
//  Recall
//
//  Created by Tiago Alves on 24/12/2018.
//  Copyright © 2018 Recall. All rights reserved.
//

import UIKit
import Blockstack
import GSImageViewerController
import AVFoundation

private let reuseIdentifier = "photoCell"

class PhotosViewController: UICollectionViewController {

    private let refreshControl = UIRefreshControl()
    var photos : Array<Photo> = []

    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 10.0, *) {
            self.collectionView?.refreshControl = self.refreshControl
        } else {
            self.collectionView?.addSubview(self.refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)

        self.collectionView?.setContentOffset(CGPoint(x: 0, y: -80.0), animated: true)
        self.refreshControl.beginRefreshing()
        self.fetchData()
    }

    @objc func refreshData(_ sender: Any) {
        fetchData()
    }

    func fetchData() {
        Blockstack.shared.getFile(at: "photos.json", decrypt: true) { (response, error) in
            let responseString = (response as! DecryptedValue).plainText
            
            if let parsedPhotos = responseString!.parseJSONString as? Array<Any> {
                for parsedPhoto in parsedPhotos {
                    if let photo = parsedPhoto as? Dictionary<String, Any> {
                        if let compressedPath = photo["compressedPath"] as? String {
                            self.photos.append(Photo.init(compressedPhotoPath: compressedPath, orientation: photo["orientation"] as? Int))
                        }
                    }
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                self.collectionView?.reloadData()
                self.refreshControl.endRefreshing()
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photos.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ThumbnailCell
        let photo = self.photos[indexPath.row]
        cell.setPhoto(photo: photo)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PhotosViewController.openImage(_:)))
        cell.imageView.isUserInteractionEnabled = true
        cell.imageView.tag = indexPath.row
        cell.imageView.addGestureRecognizer(tapGestureRecognizer)

        return cell
    }

    @objc func openImage(_ sender: AnyObject) {
        let imageView = sender.view! as! UIImageView
        let imageInfo      = GSImageInfo(image: imageView.image!, imageMode: .aspectFit, imageHD: nil)
        let transitionInfo = GSTransitionInfo(fromView: imageView)
        let imageViewer    = GSImageViewerController(imageInfo: imageInfo, transitionInfo: transitionInfo)
        present(imageViewer, animated: true, completion: nil)
    }

    // MARK: UICollectionViewDelegate

    /*
     // Uncomment this method to specify if the specified item should be highlighted during tracking
     override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
     return true
     }
     */

    /*
     // Uncomment this method to specify if the specified item should be selected
     override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
     return true
     }
     */

    /*
     // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
     override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
     return false
     }

     override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
     return false
     }

     override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {

     }
     */

}
