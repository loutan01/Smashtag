//
//  ScrollViewController.swift
//  Smashtag
//
//  Created by Andrew Loutfi on 4/5/16.
//  Copyright © 2016 Andrew Loutfi. All rights reserved.
//

import UIKit

class ScrollViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.delegate = self
            scrollView.contentSize = imageView.frame.size
            scrollView.minimumZoomScale = 0.03
            scrollView.maximumZoomScale = 1.0
        }
    }
    
    private var imageView = UIImageView()
    
    var image: UIImage? {
        get { return imageView.image }
        set {
            imageView.image = newValue
            imageView.sizeToFit()
            scrollView?.contentSize = imageView.frame.size

            if let imageWidth = newValue?.size.width, imageHeight = newValue?.size.height, frameWidth = scrollView?.frame.width, frameHeight = scrollView?.frame.height {
                let zoomScale = max(frameWidth / imageWidth, frameHeight / imageHeight)
                scrollView?.minimumZoomScale = zoomScale / 10
                scrollView?.maximumZoomScale = zoomScale * 10
                scrollView?.setZoomScale(zoomScale, animated: true)
            }
        }
    }
    
    var imageUrl: NSURL? {
        didSet {

            image = nil
            if view.window != nil {
                loadImage()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.addSubview(imageView)
        
        let unwindToRootButton =  UIBarButtonItem(barButtonSystemItem: .Stop, target: self, action: "unwind")
        navigationItem.rightBarButtonItem = unwindToRootButton
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        if image == nil {
            loadImage()
        }
    }
    
    private struct Storyboard {
        static let UnwindSegueIdentifier = "Unwind To Main Menu"
    }
    
    func unwind() {
        performSegueWithIdentifier(Storyboard.UnwindSegueIdentifier, sender: self)
    }
    

    private func loadImage() {
        if let url = imageUrl {
            let qos = Int(QOS_CLASS_USER_INTERACTIVE.rawValue)

            dispatch_async(dispatch_get_global_queue(qos, 0)) {
                if let fetchedData = NSData(contentsOfURL: url) {

                    dispatch_async(dispatch_get_main_queue()) {
                        if let image = UIImage(data: fetchedData) {
                            self.image = image
                        } else {
                            self.image = nil
                        }
                    }
                }
            }
        }
    }

    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
