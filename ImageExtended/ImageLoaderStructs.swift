//
//  ImageLoaderStructs.swift
//  ImageExtended
//


import UIKit


public typealias ImageDownloaderCompletion = (ImageInstance?, NSError?) -> Void


public enum ImageInstanceState {
    case new, cached, downloading
}


public struct ImageInstance {
    
    public let image: UIImage?
    public let data: Data?
    public let state: ImageInstanceState
    public let url: URL?
    
    init(image: UIImage?, data: Data? = nil, state: ImageInstanceState, url: URL?) {
        self.image = image
        self.state = state
        self.url = url
        self.data = data
    }
    
}
