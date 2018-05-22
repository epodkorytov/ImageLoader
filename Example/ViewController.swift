//
//  ViewController.swift
//  Example
//


import UIKit
import ImageExtended

class ViewController: UIViewController, UICollectionViewDataSource {

//    MARK: Constants
    
    private let CELL_IDENTIFIER = "collectionViewCell"
    
    
//    MARK: - Variables
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var itemsURL: [String] = ["http://wlpapers.com/images/beautiful-face-1.jpg",
                                      "http://wallpapereasy.com/wp-content/uploads/2014/10/girls-beautiful-face-wallpaper999.jpg",
                                      "https://wallpaperstock.net/beautiful-face-wallpapers_40846_1920x1200.jpg",
                                      "http://www.mulierchile.com/beautiful-girl-face-wallpaper/beautiful-girl-face-wallpaper-011.jpg",
                                      "http://www.lovethispic.com/uploaded_images/182198-Adriana-Lima-Beautiful-Face-Picture.jpg",
                                      "https://i.pinimg.com/736x/d6/9e/df/d69edfe403f0507bb4d4da89cebf23f1--beautiful-models-beautiful-eyes.jpg",
                                      "http://wallscreenart.com/wp-content/uploads/2016/06/great-beautiful-face-girl-image-wallpaper.jpg",
                                      "http://freshwallpapers.in/walls/beautiful_face_of_sonali_raut-HD.jpg",
                                      "http://eskipaper.com/images/beautiful-face-wallpaper-1.jpg",
                                      "https://wallpapercave.com/wp/UP11LgD.jpg",
                                      "http://www.mulierchile.com/beautiful-face-wallpaper/beautiful-face-wallpaper-013.jpg",
                                      "https://www.proprofs.com/api/ckeditor_images/Glamour-Girl-Hair-Lips-Face-HD-Wallpaper-LoveWallpapers4u_Blogspot_Com_.jpg"]
    
    private var itemURL: [String] = ["http://wlpapers.com/images/beautiful-face-1.jpg"]
    
    
//    MARK: - Overriden methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // This line of code is located here only for an example
        DiskStorage.sharedStorage.clearStorage()
        // -----------------------------------------------------
        collectionView.dataSource = self
    }

    
//    MARK: - Delegated methods
    
//    MARK: UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemsURL.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CELL_IDENTIFIER,
                                                      for: indexPath) as! CollectionViewCell
        cell.imageView.image(stringOrURL: itemsURL[indexPath.item],
                             placeholderType: .activityIndicator(type: .infinit),
                             brokenImagePlaceholder: #imageLiteral(resourceName: "brokenImagePlaceholder"))
        return cell
    }
    


}

