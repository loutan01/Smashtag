//
//  WebViewController.swift
//  Smashtag
//
//  Created by Andrew Loutfi on 4/5/16.
//  Copyright © 2016 Andrew Loutfi. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController, UIWebViewDelegate {
    
    var url: NSURL? {
        didSet {
            if view.window != nil {
                webView?.stopLoading()
                loadUrl()
            }
        }
    }

    @IBOutlet weak var webView: UIWebView! {
        didSet {
            webView.delegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadUrl()
        
        let unwindToRootButton =  UIBarButtonItem(barButtonSystemItem: .Stop, target: self, action: "unwind")
        navigationItem.rightBarButtonItem = unwindToRootButton
        
        
    }
    
    private struct Storyboard {
        static let UnwindSegueIdentifier = "Unwind to Main Menu"
    }
    
    func unwind() {
        performSegueWithIdentifier(Storyboard.UnwindSegueIdentifier, sender: self)
    }
    
    private func loadUrl() {
        if url != nil {
            let request = NSURLRequest(URL: url!)
            webView?.loadRequest(request)
        }
    }
    @IBAction func goBack(sender: AnyObject) {
        if (webView?.canGoBack != nil) {
            webView?.goBack()
        }
    }
    @IBAction func goForward(sender: AnyObject) {
        if (webView?.canGoForward != nil) {
            webView?.goForward()
        }
    }
    @IBAction func refresh(sender: AnyObject) {
        webView?.stopLoading()
        webView?.reload()
        
    }
    
}
