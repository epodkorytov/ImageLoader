//
//  DiskStorage.swift
//  ImageExtended
//

import UIKit

public class DiskStorage: ImageStorageProtocol {
    
//    MARK: - Variables
    
    public static let sharedStorage = DiskStorage()
    
    private let fileManager = FileManager.default
    private let storageQueue = DispatchQueue(label: Constants.queueLabel, attributes: [])
    private let storagePath: String
    
    public var maxTTL: TimeInterval = Constants.defaultTTL
    
    
//    MARK: - Instance initialization
    
    public init() {
        let path = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first! as NSString
        storagePath = path.appendingPathComponent(Constants.baseStoragePath + Constants.defaultStorageName)
        try? fileManager.createDirectory(atPath: storagePath, withIntermediateDirectories: true, attributes: nil)
    }
    
    
//    MARK: - Private methods
    
    private func defaultStoragePath(forKey key: String) -> String {
        let key  = key.components(separatedBy: .punctuationCharacters).joined()
        return (storagePath as NSString).appendingPathComponent(key)
    }
    
    
    private func expiredFiles(usingEnumerator enumerator: FileManager.DirectoryEnumerator) -> [URL] {
        let expirationDate = Date(timeIntervalSinceNow: -maxTTL)
        var expiredFiles: [URL] = []
        while let fileURL = enumerator.nextObject() as? URL {
            if self.isDirectory(fileURL) {
                enumerator.skipDescendants()
                continue
            }
            if let modificationDate = modificationDate(fileURL), (modificationDate as NSDate).laterDate(expirationDate) == expirationDate {
                expiredFiles.append(fileURL)
            }
        }
        return expiredFiles
    }
    
    
    private func isDirectory(_ fileURL: URL) -> Bool {
        var isDirectoryResource: AnyObject?
        try? (fileURL as NSURL).getResourceValue(&isDirectoryResource, forKey: .isDirectoryKey)
        guard let isDirectory = isDirectoryResource as? NSNumber else { return false }
        return isDirectory.boolValue
    }
    
    
    private func modificationDate(_ fileURL: URL) -> Date? {
        var modificationDateResource: AnyObject?
        try? (fileURL as NSURL).getResourceValue(&modificationDateResource, forKey: .contentModificationDateKey)
        return modificationDateResource as? Date
    }
    
    
    private func deleteExpiredFiles(_ files: [URL]) {
        for file in files {
            try? fileManager.removeItem(at: file)
        }
    }
    
    
    private func reduceStorage() {
        storageQueue.async { [unowned self] in
            let directoryURL = URL(fileURLWithPath: self.storagePath, isDirectory: true)
            let keys: [URLResourceKey] = [.isDirectoryKey, .contentModificationDateKey]
            guard let enumerator = self.fileManager.enumerator(at: directoryURL,
                                                               includingPropertiesForKeys: keys,
                                                               options: .skipsHiddenFiles,
                                                               errorHandler: nil)
                else { return }
            self.deleteExpiredFiles(self.expiredFiles(usingEnumerator: enumerator))
        }
    }
    

//    MARK: - Protocol methods
    
//    MARK: ImageStorageProtocol
    
    public func store(image: UIImage, data: Data?, forKey key: String) {
        storageQueue.async { [weak self] in
            guard let data = data ?? image.pngData(), let storage = self else { return }
            storage.fileManager.createFile(atPath: storage.defaultStoragePath(forKey: key), contents: data,
                                           attributes: nil)
            storage.reduceStorage()
        }
    }
    
    
    public func image(forKey key: String) -> UIImage? {
        let path = defaultStoragePath(forKey: key)
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else { return nil }
        return UIImage.imageWithCachedData(data)
    }
    
    
    public func removeImage(forKey key: String) {
        storageQueue.async { [weak self] in
            guard let path = self?.defaultStoragePath(forKey: key) else { return }
            let _ = try? self?.fileManager.removeItem(atPath: path)
        }
    }
    
    
    public func clearStorage() {
        storageQueue.async { [weak self] in
            guard let path = self?.storagePath else { return }
            let _ = try? self?.fileManager.removeItem(atPath: path)
            let _ = try? self?.fileManager.createDirectory(atPath: path, withIntermediateDirectories: true,
                                                           attributes: nil)
        }
    }
    
}

