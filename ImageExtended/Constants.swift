//
//  Constants.swift
//  ImageExtended
//

import Foundation

class Constants {
    
    static let baseStoragePath = Bundle.main.bundleIdentifier!
    static let queueLabel = "\(baseStoragePath).Storage"
    static let defaultStorageName = "default"
    
    static let defaultTTL: TimeInterval = 60 * 60 * 24 * 7
    
}
