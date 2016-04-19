//
//  ImageCollectionViewCell.swift
//  Smashtag
//
//  Created by Andrew Loutfi on 4/5/16.
//  Copyright © 2016 Andrew Loutfi. All rights reserved.
//
import UIKit

@objc protocol ImageCollectionViewDelegate {
    optional func didFinishDownloadingImage(image: UIImage, sender: ImageCollectionViewCell)
}

class ImageCollectionViewCell: UICollectionViewCell {
    
    var imageUrl: NSURL? {
        didSet {
            updateUI()
        }
    }
    
    var delegate: ImageCollectionViewDelegate?
    
    @IBOutlet weak var tweetImage: UIImageView!

    private func updateUI() {
        

        tweetImage.image = nil
        
        if let placeholder = UIImage(named: "PlaceHolder") {
            tweetImage.image = placeholder
        }
        
        if let imageUrl = imageUrl {
            let qos = Int(QOS_CLASS_USER_INITIATED.rawValue)

            dispatch_async(dispatch_get_global_queue(qos, 0)) {
                if let fetchedData = NSData(contentsOfURL: imageUrl) {
                    if let image = UIImage(data: fetchedData) {
                        

                        dispatch_async(dispatch_get_main_queue()) {
                            self.tweetImage.image = image
                        }
                        
                        self.delegate?.didFinishDownloadingImage!(image, sender: self)
                    }
                }
            }
        }
    }

}
