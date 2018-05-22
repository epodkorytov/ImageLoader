//
//  UIImageView+Extension.swift
//  UIImageView+Extension
//


import UIKit
import Indicator

extension UIImageView: ImageDownloadDelegate {

//    MARK: - Structs
    
    public enum IndicatorType {
        case infinit
        case progress
    }
    
    
    public enum PlaceholderType {
        case image(image: UIImage)
        case activityIndicator(type: IndicatorType)
    }
    
    
    private struct AssociatedKeys {
        static var ActionKey = "ActionKey"
        static var key: URL? = nil
        static var brokenImage: UIImage? = nil
        static var operation: ImageDownloadOperation? = nil
        static var indicator: Indicator? = nil
        static var indicatorType: IndicatorType? = nil
    }
    
    
//    MARK: - Variables
    
    private var key: URL? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.key) as? URL
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.key, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private var brokenImage: UIImage? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.brokenImage) as? UIImage
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.brokenImage, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private var operation: ImageDownloadOperation? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.operation) as? ImageDownloadOperation
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.operation, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private var indicator: Indicator? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.indicator) as? Indicator
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.indicator, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private var indicatorType: IndicatorType? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.indicatorType) as? IndicatorType
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.indicatorType, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    
//    MARK: - Interface methods
    
    public func image(stringOrURL source: Any,
                      placeholderType: PlaceholderType? = nil,
                      brokenImagePlaceholder: UIImage? = nil,
                      completion: ImageDownloaderCompletion? = nil)
    {
        var sourceUrl: URL
        brokenImage = brokenImagePlaceholder
        if let string = source as? String {
            if let url = URL(string: string) {
                sourceUrl = url
            } else {
                completion?(nil, NSError(domain: "",
                                         code: 1001,
                                         userInfo: [NSLocalizedFailureErrorKey: "Wrong URL string"]))
                return
            }
        } else if let url = source as? URL {
            sourceUrl = url
        } else {
            completion?(nil, NSError(domain: "",
                                     code: 1002,
                                     userInfo: [NSLocalizedFailureErrorKey: "Unknown URL attribute, it should be string type or URL"]))
            return
        }
        var placeholderImage: UIImage?
        if let placeholderType = placeholderType {
            switch placeholderType {
            case .image(let image):
                placeholderImage = image
            case .activityIndicator(let type):
                indicatorType = type
                if indicator != nil {
                    indicator?.center = center
                } else {
                    var style = IndicatorStyleDefault()
                    style.strokeWidth = 2.0
                    if indicatorType == .progress {
                        style.progress = 0.15
                    }
                    indicator = Indicator(style: style)
                    indicator?.center = center
                    indicator?.startAnimating()
                    addSubview(indicator!)
                }
            }
        }
        image(withUrl: sourceUrl, withPlaceholder: placeholderImage, completion: completion)
    }
    
    
//    MARK: - Private methods
    
    private func image(withUrl url: URL,
                       withPlaceholder placeholder: UIImage? = nil,
                       completion: ImageDownloaderCompletion? = nil)
    {
        if let placeholder = placeholder {
            image = placeholder
        }
        cancelDownload()
        self.key = url
        if let operation = downloadOperationWithURL(url, placeholder: placeholder, completion: completion) {
            operation.delegate = self
            self.operation = operation
            
        }
    }
    
    
    private func downloadOperationWithURL(_ url: URL, placeholder: UIImage? = nil, completion: ImageDownloaderCompletion? = nil) -> ImageDownloadOperation? {
        return ImageManager.sharedManager.downloadImage(atUrl: url, imageView: self)
        { [weak weakSelf = self] (imageInstance, error) in
            DispatchQueue.main.async {
                if let instance = imageInstance {
                    if let _ = placeholder , instance.state != .cached {
                        weakSelf?.layer.add(CATransition(), forKey: nil)
                    }
                    if weakSelf?.key == instance.url {
                        weakSelf?.image = instance.image
                    }
                } else {
                    weakSelf?.image = weakSelf?.brokenImage
                }
                weakSelf?.indicator?.stopAnimating()
                weakSelf?.indicator?.isHidden = true
                completion?(imageInstance, error)
            }
        }
    }
    
    
    private func cancelDownload() {
        operation?.cancel()
        key = nil
    }
    
    
//    MARK: - Delegated methods
    
//    MARK: ImageDownloadDelegate
    
    public func imageDownloaderDelegate(_ downloader: ImageDownloadOperation, didReportProgress progress: Progress) {
        if progress.completedUnitCount != progress.totalUnitCount {
            if (indicator?.isHidden ?? false) {
                indicator?.startAnimating()
                indicator?.isHidden = false
            }
            if indicatorType == .progress {
                let progressPercent = CGFloat(progress.completedUnitCount) / CGFloat(progress.totalUnitCount)
                indicator?.progress = progressPercent
            }
        } else {
            indicator?.stopAnimating()
            indicator?.isHidden = true
        }
    }
    
}


public extension UIImage {
    
    /// Tint pictogram with color
    /// Method work on single colors without fading, mainly for svg images
    ///
    /// - Parameter fillColor: TintColor: Tint color
    /// - Returns:             Tinted image
    public func tintPictogram(with fillColor: UIColor) -> UIImage {
        
        return modifiedImage { context, rect in
            // draw tint color
            context.setBlendMode(.normal)
            fillColor.setFill()
            context.fill(rect)
            
            // mask by alpha values of original image
            context.setBlendMode(.destinationIn)
            context.draw(cgImage!, in: rect)
        }
    }
    
    /// Modified Image Context, apply modification on image
    ///
    /// - Parameter draw: (CGContext, CGRect) -> ())
    /// - Returns:        UIImage
    fileprivate func modifiedImage(_ draw: (CGContext, CGRect) -> ()) -> UIImage {
        
        // using scale correctly preserves retina images
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        let context: CGContext! = UIGraphicsGetCurrentContext()
        assert(context != nil)
        
        // correctly rotate image
        context.translateBy(x: 0, y: size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        
        let rect = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
        
        draw(context, rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}
