import UIKit
import DTPhotoViewerController

private var kElementHorizontalMargin: CGFloat  { return 20 }
private var kElementHeight: CGFloat { return 40 }
private var kElementWidth: CGFloat  { return 50 }
private var kElementBottomMargin: CGFloat  { return 10 }

protocol SimplePhotoViewerControllerDelegate: DTPhotoViewerControllerDelegate {
    func simplePhotoViewerController(_ viewController: SimplePhotoViewerController, saveImage image: UIImage)
    func simplePhotoViewerController(_ viewController: SimplePhotoViewerController, shareImage image: UIImage)
    func simplePhotoViewerController(_ viewController: SimplePhotoViewerController, deletePhoto photo: Photo)
}

class SimplePhotoViewerController: DTPhotoViewerController {
    
    var photo : Photo?
    
    lazy var moreButton: UIButton = {
        let moreButton = UIButton(frame: CGRect.zero)
        moreButton.setImage(UIImage.moreIcon(size: CGSize(width: 16, height: 16), color: UIColor.white), for: UIControl.State.normal)
        moreButton.contentHorizontalAlignment = .right
        moreButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: kElementHorizontalMargin)
        moreButton.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        moreButton.addTarget(self, action: #selector(moreButtonTapped(_:)), for: UIControl.Event.touchUpInside)
        return moreButton
    }()
    
    deinit {
        print("SimplePhotoViewerController deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerClassPhotoViewer(CustomPhotoCollectionViewCell.self)
        view.addSubview(moreButton)
        
        configureOverlayViews(hidden: true, animated: false)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let y = bottomButtonsVerticalPosition()
        
        // Layout subviews
        let buttonWidth: CGFloat = kElementWidth
        
        moreButton.frame = CGRect(origin: CGPoint(x: view.bounds.width - buttonWidth, y: y), size: CGSize(width: buttonWidth, height: kElementHeight))
    }
    
    func bottomButtonsVerticalPosition() -> CGFloat {
        return view.bounds.height - kElementHeight - kElementBottomMargin
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func moreButtonTapped(_ sender: UIButton) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        
        let saveButton = UIAlertAction(title: "Save", style: UIAlertAction.Style.default) { (_) in
            // Save photo to Camera roll
            if let delegate = self.delegate as? SimplePhotoViewerControllerDelegate {
                delegate.simplePhotoViewerController(self, saveImage: self.imageView.image!)
            }
        }
        alertController.addAction(saveButton)
        
        let shareButton = UIAlertAction(title: "Share", style: UIAlertAction.Style.default) { (_) in
            // Share photo
            if let delegate = self.delegate as? SimplePhotoViewerControllerDelegate {
                delegate.simplePhotoViewerController(self, shareImage: self.imageView.image!)
            }
        }
        alertController.addAction(shareButton)
        
        let deleteButton = UIAlertAction(title: "Delete", style: UIAlertAction.Style.destructive) { (_) in
            // Delete photo
            if let delegate = self.delegate as? SimplePhotoViewerControllerDelegate {
                delegate.simplePhotoViewerController(self, deletePhoto: self.photo!)
            }
        }
        alertController.addAction(deleteButton)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func hideInfoOverlayView(_ animated: Bool) {
        configureOverlayViews(hidden: true, animated: animated)
    }
    
    func showInfoOverlayView(_ animated: Bool) {
        configureOverlayViews(hidden: false, animated: animated)
    }
    
    func configureOverlayViews(hidden: Bool, animated: Bool) {
        if hidden != moreButton.isHidden {
            let duration: TimeInterval = animated ? 0.2 : 0.0
            let alpha: CGFloat = hidden ? 0.0 : 1.0
            
            // Always unhide view before animation
            setOverlayElementsHidden(isHidden: false)
            
            UIView.animate(withDuration: duration, animations: {
                self.setOverlayElementsAlpha(alpha: alpha)
                
            }, completion: { (finished) in
                self.setOverlayElementsHidden(isHidden: hidden)
            })
        }
    }
    
    func setOverlayElementsHidden(isHidden: Bool) {
        moreButton.isHidden = isHidden
    }
    
    func setOverlayElementsAlpha(alpha: CGFloat) {
        moreButton.alpha = alpha
    }
    
    override func didReceiveTapGesture() {
        reverseInfoOverlayViewDisplayStatus()
    }
    
    @objc override func willZoomOnPhoto(at index: Int) {
        hideInfoOverlayView(false)
    }
    
    override func didEndZoomingOnPhoto(at index: Int, atScale scale: CGFloat) {
        if scale == 1 {
            showInfoOverlayView(true)
        }
    }
    
    override func didEndPresentingAnimation() {
        showInfoOverlayView(true)
    }
    
    override func willBegin(panGestureRecognizer gestureRecognizer: UIPanGestureRecognizer) {
        hideInfoOverlayView(false)
    }
    
    override func didReceiveDoubleTapGesture() {
        hideInfoOverlayView(false)
    }
    
    // Hide & Show info layer view
    func reverseInfoOverlayViewDisplayStatus() {
        if zoomScale == 1.0 {
            if moreButton.isHidden == true {
                showInfoOverlayView(true)
            }
            else {
                hideInfoOverlayView(true)
            }
        }
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

class CustomPhotoCollectionViewCell: DTPhotoCollectionViewCell {
    lazy var extraLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        addSubview(extraLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let width: CGFloat = 70
        extraLabel.frame = CGRect(x: self.bounds.size.width - width - 20, y: 0, width: width, height: 60)
    }
}

import UIKit
import AVKit
import Photos

extension UIImage {
    
    public class func preferredImageSize(for size: CGSize, with aspectRatio: CGFloat) -> CGSize {
        guard aspectRatio != 1.0 else {
            return CGSize(width: size.height, height: size.height)
        }
        
        let widthDifference = abs(size.width - size.height * aspectRatio) // /
        let heightDiffence = abs(size.height - size.width / aspectRatio)  // *
        
        if (widthDifference < heightDiffence) {
            return CGSize(width: size.height * aspectRatio, height: size.height)
        } else if (widthDifference > heightDiffence) {
            return CGSize(width: size.width, height: size.width / aspectRatio)
        } else {
            // If can not determine which difference is greater then the returned size should be based on the specified height
            return CGSize(width: heightDiffence * aspectRatio, height: size.height)
        }
    }
}

extension UIImage {
    /// More action icon. Aspect ratio 4:1
    public class func moreIcon(size: CGSize, color fillColor: UIColor!) -> UIImage {
        let aspectRatio: CGFloat = 4.0
        let preferredSize = UIImage.preferredImageSize(for: size, with: aspectRatio)
        let frame = CGRect(x: 0, y: 0, width: preferredSize.width, height: preferredSize.height)
        
        UIGraphicsBeginImageContextWithOptions(frame.size, false, 0)
        
        //PaintCode here
        let morePath = UIBezierPath()
        morePath.move(to: CGPoint(x: frame.minX + 0.12500 * frame.width, y: frame.minY + 0.00000 * frame.height))
        morePath.addLine(to: CGPoint(x: frame.minX + 0.12500 * frame.width, y: frame.minY + 0.00000 * frame.height))
        morePath.addCurve(to: CGPoint(x: frame.minX + 0.25000 * frame.width, y: frame.minY + 0.50000 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.19404 * frame.width, y: frame.minY + 0.00000 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.25000 * frame.width, y: frame.minY + 0.22386 * frame.height))
        morePath.addCurve(to: CGPoint(x: frame.minX + 0.12500 * frame.width, y: frame.minY + 1.00000 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.25000 * frame.width, y: frame.minY + 0.77614 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.19404 * frame.width, y: frame.minY + 1.00000 * frame.height))
        morePath.addCurve(to: CGPoint(x: frame.minX + 0.00000 * frame.width, y: frame.minY + 0.50000 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.05596 * frame.width, y: frame.minY + 1.00000 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.00000 * frame.width, y: frame.minY + 0.77614 * frame.height))
        morePath.addLine(to: CGPoint(x: frame.minX + 0.00000 * frame.width, y: frame.minY + 0.50000 * frame.height))
        morePath.addCurve(to: CGPoint(x: frame.minX + 0.12500 * frame.width, y: frame.minY + 0.00000 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.00000 * frame.width, y: frame.minY + 0.22386 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.05596 * frame.width, y: frame.minY + 0.00000 * frame.height))
        morePath.close()
        morePath.move(to: CGPoint(x: frame.minX + 0.50000 * frame.width, y: frame.minY + 0.00000 * frame.height))
        morePath.addLine(to: CGPoint(x: frame.minX + 0.50000 * frame.width, y: frame.minY + 0.00000 * frame.height))
        morePath.addCurve(to: CGPoint(x: frame.minX + 0.62500 * frame.width, y: frame.minY + 0.50000 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.56904 * frame.width, y: frame.minY + 0.00000 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.62500 * frame.width, y: frame.minY + 0.22386 * frame.height))
        morePath.addCurve(to: CGPoint(x: frame.minX + 0.50000 * frame.width, y: frame.minY + 1.00000 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.62500 * frame.width, y: frame.minY + 0.77614 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.56904 * frame.width, y: frame.minY + 1.00000 * frame.height))
        morePath.addCurve(to: CGPoint(x: frame.minX + 0.37500 * frame.width, y: frame.minY + 0.50000 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.43096 * frame.width, y: frame.minY + 1.00000 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.37500 * frame.width, y: frame.minY + 0.77614 * frame.height))
        morePath.addLine(to: CGPoint(x: frame.minX + 0.37500 * frame.width, y: frame.minY + 0.50000 * frame.height))
        morePath.addCurve(to: CGPoint(x: frame.minX + 0.50000 * frame.width, y: frame.minY + 0.00000 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.37500 * frame.width, y: frame.minY + 0.22386 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.43096 * frame.width, y: frame.minY + 0.00000 * frame.height))
        morePath.close()
        morePath.move(to: CGPoint(x: frame.minX + 0.87500 * frame.width, y: frame.minY + 0.00000 * frame.height))
        morePath.addLine(to: CGPoint(x: frame.minX + 0.87500 * frame.width, y: frame.minY + 0.00000 * frame.height))
        morePath.addCurve(to: CGPoint(x: frame.minX + 1.00000 * frame.width, y: frame.minY + 0.50000 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.94404 * frame.width, y: frame.minY + 0.00000 * frame.height), controlPoint2: CGPoint(x: frame.minX + 1.00000 * frame.width, y: frame.minY + 0.22386 * frame.height))
        morePath.addCurve(to: CGPoint(x: frame.minX + 0.87500 * frame.width, y: frame.minY + 1.00000 * frame.height), controlPoint1: CGPoint(x: frame.minX + 1.00000 * frame.width, y: frame.minY + 0.77614 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.94404 * frame.width, y: frame.minY + 1.00000 * frame.height))
        morePath.addCurve(to: CGPoint(x: frame.minX + 0.75000 * frame.width, y: frame.minY + 0.50000 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.80596 * frame.width, y: frame.minY + 1.00000 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.75000 * frame.width, y: frame.minY + 0.77614 * frame.height))
        morePath.addLine(to: CGPoint(x: frame.minX + 0.75000 * frame.width, y: frame.minY + 0.50000 * frame.height))
        morePath.addCurve(to: CGPoint(x: frame.minX + 0.87500 * frame.width, y: frame.minY + 0.00000 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.75000 * frame.width, y: frame.minY + 0.22386 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.80596 * frame.width, y: frame.minY + 0.00000 * frame.height))
        morePath.close()
        morePath.usesEvenOddFillRule = true
        fillColor.setFill()
        morePath.fill()
        
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return image
    }
}
