//
//  Storage.swift
//  ImageExtended
//


import UIKit

protocol ImageStorageProtocol {
    
    func store(image: UIImage, data: Data?, forKey key: String)
    func image(forKey key: String) -> UIImage?
    func removeImage(forKey key: String)
    func clearStorage()
    
}

class ImageStorage: ImageStorageProtocol {
    
//    MARK: Variables
    
    private let inMemoryStorage: ImageStorageProtocol
    private let diskStorage: ImageStorageProtocol
    
    static let sharedStorage = ImageStorage()
    
    
//    MARK: - Instance initialization
    
    private init() {
        inMemoryStorage = CacheStorage.sharedStorage
        diskStorage = DiskStorage.sharedStorage
    }
    

//    MARK: - Protocol methods
    
//    MARK: ImageStorageProtocol
    
    func store(image: UIImage, data: Data?, forKey key: String) {
        inMemoryStorage.store(image: image, data: data, forKey: key)
        diskStorage.store(image: image, data: data, forKey: key)
    }
    
    func image(forKey key: String) -> UIImage? {
        if let image = inMemoryStorage.image(forKey: key) {
            return image
        } else if let image = diskStorage.image(forKey: key) {
            inMemoryStorage.store(image: image, data: nil, forKey: key)
            return image
        }
        return nil
    }
    
    func removeImage(forKey key: String) {
        inMemoryStorage.removeImage(forKey: key)
        diskStorage.removeImage(forKey: key)
    }
    
    func clearStorage() {
        inMemoryStorage.clearStorage()
        diskStorage.clearStorage()
    }
    
}

