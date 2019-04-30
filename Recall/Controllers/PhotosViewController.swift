//
//  PhotosViewController.swift
//  Recall
//
//  Created by Tiago Alves on 24/12/2018.
//  Copyright © 2018 Recall. All rights reserved.
//

import UIKit
import Blockstack
import DTPhotoViewerController
import AVFoundation
import Photos
import SVProgressHUD

private let reuseIdentifier = "photoCell"

class PhotosViewController: UICollectionViewController, SimplePhotoViewerControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

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
            if (error != nil) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                    self.refreshControl.endRefreshing()
                    
                    let msg = error?.localizedDescription
                    let alert = UIAlertController(title: "Error",
                                                  message: msg,
                                                  preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                })
                return
            }
            
            if let decryptedResponse = response as? DecryptedValue {
                let responseString = decryptedResponse.plainText
                
                self.photos = []
                
                if let parsedPhotos = responseString!.parseJSONString as? Array<Any> {
                    for parsedPhoto in parsedPhotos {
                        if let photo = parsedPhoto as? Dictionary<String, Any> {
                            self.photos.append(
                                Photo.init( photoPath: photo["path"] as? String,
                                            compressedPhotoPath: photo["compressedPath"] as? String,
                                            uuid: photo["uuid"] as? String,
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
        cell.startLoading()
        let photos = self.groupedPhotos[indexPath.section].value
        let photo = photos[indexPath.row]
        cell.photo = photo
        cell.setPhoto(photo: photo)

        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = self.collectionView.cellForItem(at: indexPath) as! ThumbnailCell
        if let image = cell.imageView.image {
            let photoViewer = SimplePhotoViewerController(referencedView: cell.imageView, image: image)
            photoViewer.delegate = self
            photoViewer.photo = cell.photo
            present(photoViewer, animated: true, completion: nil)
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
        PHPhotoLibrary.requestAuthorization() { status in
            if status == .authorized {
                let pickerController = UIImagePickerController()
                pickerController.delegate = self
                pickerController.allowsEditing = false
                pickerController.mediaTypes = ["public.image"]
                pickerController.sourceType = .photoLibrary
                self.present(pickerController, animated: true, completion: nil)
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        self.upload(info: info)
    }
    
    func simplePhotoViewerController(_ viewController: SimplePhotoViewerController, saveImage image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
    
    func simplePhotoViewerController(_ viewController: SimplePhotoViewerController, shareImage image: UIImage) {
        let imageShare = [ image ]
        let activityViewController = UIActivityViewController(activityItems: imageShare , applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        viewController.present(activityViewController, animated: true, completion: nil)
    }
    
    func simplePhotoViewerController(_ viewController: SimplePhotoViewerController, deletePhoto photo: Photo) {
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.clear)
        SVProgressHUD.show()
        
        Blockstack.shared.getFile(at: "photos.json", decrypt: true, completion: { (response, error) in
            var photosArray : Array<NSDictionary> = []
            
            if let decryptedResponse = response as? DecryptedValue {
                let responseString = decryptedResponse.plainText
                
                if let parsedPhotos = responseString!.parseJSONString as? Array<Any> {
                    photosArray = parsedPhotos as! Array<NSDictionary>
                }
            }
            
            let photo = photosArray.filter{ ($0["uuid"] as! String) == photo.uuid }.first
            if let index = photosArray.index(of: photo!) {
                photosArray.remove(at: index)
                
                Blockstack.shared.putFile(to: "photos.json", text: self.json(from: photosArray)!, encrypt: true, completion: { (file, error) in
                    if let compressedPath = photo?["compressedPath"] as? String {
                        Blockstack.shared.putFile(to: compressedPath, bytes: [], encrypt: true, completion: { (file, error) in
                            print("Deleted compressed photo!")
                        })
                    }
                    if let path = photo?["path"] as? String {
                        Blockstack.shared.putFile(to: path, bytes: [], encrypt: true, completion: { (file, error) in
                            print("Deleted full-res photo")
                        })
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                        SVProgressHUD.dismiss()
                        viewController.dismiss(animated: true, completion: nil)
                        self.fetchData()
                        print("Deleted photo")
                    })
                })
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                    SVProgressHUD.dismiss()
                    print("Couldn't find photo")
                })
            }
        })
    }
    
    func upload(info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else {
            self.triggerErrorWith(title: "Failed to get photo", content: "There was an error processing your photo. Please try again.")
            return
        }
        
        var asset: PHAsset?
        asset = info[.phAsset] as? PHAsset
        
        var takenAt : Date? = nil
        if let asset = asset {
            takenAt = asset.creationDate
        }
        
        if let imageData = image.jpeg(.highest), let compressedImageData = image.jpeg(.lowest) {
            let bytes = imageData.bytes
            let compressedBytes = compressedImageData.bytes

            let uuid = UUID().uuidString
            let imageName = "\(uuid).jpg"

            SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.clear)
            SVProgressHUD.show()

            Blockstack.shared.getFile(at: "photos.json", decrypt: true, completion: { (response, error) in
                var photosArray : Array<NSDictionary> = []

                if (response != nil) {
                    // Populate with latest photos
                    if let decryptedResponse = response as? DecryptedValue {
                        let responseString = decryptedResponse.plainText

                        if let parsedPhotos = responseString!.parseJSONString as? Array<Any> {
                            photosArray = parsedPhotos as! Array<NSDictionary>
                        }
                    }
                } else if (error != nil) {
                    let msg = error?.localizedDescription
                    self.triggerErrorWith(title: "Error", content: msg!)
                }

                Blockstack.shared.putFile(to: "compressed_images/\(imageName)", bytes: compressedBytes, encrypt: true, completion: { (file, error) in
                    if (error == nil) {
                        Blockstack.shared.putFile(to: "images/\(imageName)", bytes: bytes, encrypt: true, completion: { (file, error) in
                            if (error == nil) {
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
                                    if (error == nil) {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                                            SVProgressHUD.dismiss()
                                            self.fetchData()
                                            print("Uploaded photo")
                                        })
                                    } else {
                                        self.triggerErrorWith(title: "Failed to upload photo", content: "There was an error uploading your photo. Please try again.")
                                    }
                                })
                            } else {
                                self.triggerErrorWith(title: "Failed to upload photo", content: "There was an error uploading your photo. Please try again.")
                            }
                        })
                    } else {
                        self.triggerErrorWith(title: "Failed to upload photo", content: "There was an error uploading your photo. Please try again.")
                    }
                })
            })
        }
    }
    
    func triggerErrorWith(title: String, content: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
            SVProgressHUD.dismiss()
            
            let alert = UIAlertController(title: title,
                                          message: content,
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        })
        return
    }
    
    func json(from object:Any) -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: []) else {
            return nil
        }
        return String(data: data, encoding: String.Encoding.utf8)
    }

}
