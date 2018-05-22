//
//  ImageManager.swift
//  ImageExtended
//


import UIKit

class ImageManager {
    
//    MARK: Variables
    
    static let sharedManager = ImageManager()
    
    private let downloadQueue = OperationQueue()
    private var downloadsInProgress = [URL: ImageDownloadOperation]()
    
    
//    MARK: - Deinit methods
    
    deinit {
        downloadQueue.cancelAllOperations()
    }
    
    
//    MARK: - Interface methods
    
    func downloadImage(atUrl url: URL,
                       imageView: UIImageView?,
                       storage: ImageStorageProtocol = ImageStorage.sharedStorage,
                       completion: ImageDownloaderCompletion?) -> ImageDownloadOperation?
    {
        if let cachedImage = storage.image(forKey: url.absoluteString) {
            completion?(ImageInstance(image: cachedImage, state: .cached, url: url), nil)
        } else {
            if downloadsInProgress[url] == nil {
                let downloadOperation = ImageDownloadOperation(imageURL: url)
                downloadOperation.qualityOfService = .userInitiated
                downloadOperation.completionHandler = downloadHandlerWithStorage(url, imageView: imageView, storage: storage, completion: completion)
                downloadsInProgress[url] = downloadOperation
                downloadQueue.addOperation(downloadOperation)
                return downloadOperation
            } else {
                completion?(ImageInstance(image: nil, state: .downloading, url: nil), nil)
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1), execute: {
                    _ = self.downloadImage(atUrl: url, imageView: imageView, storage: storage, completion: completion)
                })
            }
        }
        return nil
    }
    
    
//    MARK: - Private methods
    
    private func downloadHandlerWithStorage(_ url: URL, imageView: UIImageView?, storage: ImageStorageProtocol,
                                            completion: ImageDownloaderCompletion?) -> ImageDownloaderCompletion {
        return { [weak self] imageInstance, error in
            self?.downloadsInProgress[url] = nil
            if let newImage = imageInstance?.image {
                if let imageData = imageInstance?.data {
                    storage.store(image: newImage, data: imageData, forKey: url.absoluteString)
                }
                completion?(ImageInstance(image: newImage, state: .new, url: imageInstance?.url), nil)
            } else {
                completion?(nil, error)
            }
        }
    }

    
}
