//
//  UIImage+Extension.swift
//  ImageExtended
//


import UIKit

extension UIImage {
    
    static func imageWithCachedData(_ data: Data) -> UIImage? {
        guard !data.isEmpty else { return nil }
        return UIImage(data: data)
    }
    
}
