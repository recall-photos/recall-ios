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
import YPImagePicker
import SVProgressHUD

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
        refreshControl.addTarget(self, action: #selector(refreshPhotos(_:)), for: .valueChanged)
        
//        self.checkAuthorizationForPhotoLibraryAndGet()

        self.collectionView?.setContentOffset(CGPoint(x: 0, y: -80.0), animated: true)
        self.refreshControl.beginRefreshing()
        self.fetchData()
    }

    @objc func refreshPhotos(_ sender: Any) {
        fetchData()
    }

    func fetchData() {
        Blockstack.shared.getFile(at: "photos.json", decrypt: true) { (response, error) in
            if let decryptedResponse = response as? DecryptedValue {
                let responseString = decryptedResponse.plainText
                
                self.photos = []
                
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
                
                self.groupedPhotos = []
                let groupedPhotos = Dictionary(grouping: self.photos, by: { Calendar.current.startOfDay(for: $0.takenAt ?? $0.uploadedAt ?? Date()) })
                self.groupedPhotos = groupedPhotos.sorted(by: { (first, second) -> Bool in
                    return first.key > second.key
                })
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                    self.collectionView?.reloadData()
                    self.refreshControl.endRefreshing()
                })
            } else {
                // Could not fetch photos.json file
                DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                    self.refreshControl.endRefreshing()
                })
            }
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
        
        cell.imageView.image = nil
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
        if let image = imageView.image {
            let imageInfo      = GSImageInfo(image: image, imageMode: .aspectFit, imageHD: nil)
            let transitionInfo = GSTransitionInfo(fromView: imageView)
            let imageViewer    = GSImageViewerController(imageInfo: imageInfo, transitionInfo: transitionInfo)
            present(imageViewer, animated: true, completion: nil)
        }
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
    
    @IBAction func openPhotoPicker() {
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
        var takenAt : Date? = nil
        if let exifMeta = photo.exifMeta {
            if let tiff = exifMeta["{TIFF}"] as? Dictionary<String, Any> {
                if let dateTimeString = tiff["DateTime"] as? String {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy:MM:dd HH:mm:ss"
                    let date = dateFormatter.date(from:dateTimeString)!
                    takenAt = date
                }
            }
        }
        
        if let imageData = photo.image.jpeg(.highest), let compressedImageData = photo.image.jpeg(.lowest) {
            let bytes = imageData.bytes
            let compressedBytes = compressedImageData.bytes

            let uuid = UUID().uuidString
            let imageName = "\(uuid).jpg"

            SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.clear)
            SVProgressHUD.show()

            Blockstack.shared.getFile(at: "photos.json", decrypt: true, completion: { (response, error) in
                if let decryptedResponse = response as? DecryptedValue {
                    let responseString = decryptedResponse.plainText

                    if let parsedPhotos = responseString!.parseJSONString as? Array<Any> {
                        var photosArray = parsedPhotos as! Array<NSDictionary>
                        
                        Blockstack.shared.putFile(to: "compressed_images/\(imageName)", bytes: compressedBytes, encrypt: true, completion: { (file, error) in
                            Blockstack.shared.putFile(to: "images/\(imageName)", bytes: bytes, encrypt: true, completion: { (file, error) in
                                let newPhoto = [
                                    "path": "images/\(imageName)",
                                    "uploadedAt": Date().millisecondsSince1970,
                                    "uuid": uuid,
                                    "compressedPath": "compressed_images/\(imageName)",
                                    "name": imageName
                                ] as NSMutableDictionary
                                
                                if let takenAtDate = takenAt {
                                    newPhoto.setValue(takenAtDate.millisecondsSince1970, forKey: "takenAt")
                                }

                                photosArray.append(newPhoto)

                                Blockstack.shared.putFile(to: "photos.json", text: self.json(from: photosArray)!, encrypt: true, completion: { (file, error) in
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                                        SVProgressHUD.dismiss()
                                        self.fetchData()
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
