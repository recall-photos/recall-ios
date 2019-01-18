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
import Photos

private let reuseIdentifier = "photoCell"

class PhotosViewController: UICollectionViewController {

    private let refreshControl = UIRefreshControl()
    var photos : Array<Photo> = []
    var groupedPhotos : [(key: Date, value: [Photo])] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 10.0, *) {
            self.collectionView?.refreshControl = self.refreshControl
        } else {
            self.collectionView?.addSubview(self.refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        
        self.checkAuthorizationForPhotoLibraryAndGet()

        self.collectionView?.setContentOffset(CGPoint(x: 0, y: -80.0), animated: true)
        self.refreshControl.beginRefreshing()
        self.fetchData()
    }

    @objc func refreshData(_ sender: Any) {
        self.photos = []
        self.groupedPhotos = []
        fetchData()
    }

    func fetchData() {
        Blockstack.shared.getFile(at: "photos.json", decrypt: true) { (response, error) in
            let responseString = (response as! DecryptedValue).plainText
            
            if let parsedPhotos = responseString!.parseJSONString as? Array<Any> {
                for parsedPhoto in parsedPhotos {
                    if let photo = parsedPhoto as? Dictionary<String, Any> {
                        self.photos.append(
                            Photo.init( photoPath: photo["path"] as? String,
                                        compressedPhotoPath: photo["compressedPath"] as? String,
                                        orientation: photo["orientation"] as? Int,
                                        takenAt: photo["takenAt"] as? Double,
                                        uploadedAt: photo["uploadedAt"] as? Double )
                        )
                    }
                }
            }
            
            let groupedPhotos = Dictionary(grouping: self.photos, by: { Calendar.current.startOfDay(for: $0.takenAt ?? $0.uploadedAt ?? Date()) })
            self.groupedPhotos = groupedPhotos.sorted(by: { (first, second) -> Bool in
                return first.key > second.key
            })
            
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
        return self.groupedPhotos.count
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let photos = self.groupedPhotos[section].value
        return photos.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ThumbnailCell
        
        let photos = self.groupedPhotos[indexPath.section].value
        let photo = photos[indexPath.row]
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
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "dateHeader", for: indexPath) as? DateHeader {
            let section = self.groupedPhotos[indexPath.section]
            
            let dateFormatterPrint = DateFormatter()
            dateFormatterPrint.dateFormat = "dd MMM, yyyy"
            let date = dateFormatterPrint.string(from: section.key)
            
            sectionHeader.sectionHeaderlabel.text = date
            return sectionHeader
        }
        return UICollectionReusableView()
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
    
    private func getPhotosAndVideos() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
        let images = PHAsset.fetchAssets(with: fetchOptions)
        print(images.count)
    }
    
    private func checkAuthorizationForPhotoLibraryAndGet() {
        let status = PHPhotoLibrary.authorizationStatus()
        
        if (status == PHAuthorizationStatus.authorized) {
            // Access has been granted.
            getPhotosAndVideos()
        }else {
            PHPhotoLibrary.requestAuthorization({ (newStatus) in
                
                if (newStatus == PHAuthorizationStatus.authorized) {
                    self.getPhotosAndVideos()
                } else {
                    
                }
            })
        }
    }

}
