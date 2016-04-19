//
//  ImageTableViewCell.swift
//  Smashtag
//
//  Created by Andrew Loutfi on 4/5/16.
//  Copyright © 2016 Andrew Loutfi. All rights reserved.
//

import UIKit

class ImageTableViewCell: UITableViewCell {

    var imageUrl: NSURL? {
        didSet {
            updateUI()
        }
    }
    
    @IBOutlet weak var mediaImageView: UIImageView!
    @IBOutlet weak var activityIndcator: UIActivityIndicatorView!
    
    func updateUI() {
                mediaImageView.image = nil
        
        if let imageUrl = imageUrl {
            
            activityIndcator.startAnimating()
            let qos = Int(QOS_CLASS_USER_INITIATED.rawValue)
 
            dispatch_async(dispatch_get_global_queue(qos, 0)) {
                if let data = NSData(contentsOfURL: imageUrl) {
                    

                    dispatch_async(dispatch_get_main_queue()) {
                        self.mediaImageView?.image = UIImage(data: data)
                        self.activityIndcator.stopAnimating()
                    }
                } else {
                    self.activityIndcator.stopAnimating()
                }
            }
        }
    }
}
