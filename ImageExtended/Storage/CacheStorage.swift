//
//  CacheStorage.swift
//  ImageExtended
//


import UIKit

public class CacheStorage: ImageStorageProtocol {
    
//    MARK: - Variables
    
    public static let sharedStorage = CacheStorage()
    
    private let cache = NSCache<NSString, UIImage>()
    
    
//    MARK: - Instance initialization
    
    public init() {
        cache.name = Constants.baseStoragePath + Constants.defaultStorageName
    }
    
    
//    MARK: - Private methods
    
    private func cacheCost(forImage image: UIImage) -> Int {
        let imagesCount = image.images?.count ?? 0
        return imagesCount * Int(image.size.width * image.size.height * image.scale * image.scale)
    }
    
    
//    MARK: - Protocol methods
    
//    MARK: ImageStorageProtocol
    
    public func store(image: UIImage, data: Data?, forKey key: String) {
        cache.setObject(image, forKey: key as NSString, cost: cacheCost(forImage: image))
    }

    
    public func image(forKey key: String) -> UIImage? {
        return cache.object(forKey: key as NSString)
    }
    
    
    public func removeImage(forKey key: String) {
        cache.removeObject(forKey: key as NSString)
    }
    
    
    public func clearStorage() {
        cache.removeAllObjects()
    }
    
}

