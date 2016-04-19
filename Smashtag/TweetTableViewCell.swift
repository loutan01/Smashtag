//
//  TweetTableViewCell.swift
//  Smashtag
//
//  Created by Andrew Loutfi on 4/5/16.
//  Copyright © 2016 Andrew Loutfi. All rights reserved.
//

import UIKit

class TweetTableViewCell: UITableViewCell {
    
    var tweet: Tweet? {
        didSet {
            updateUI()
        }
    }
    

    @IBOutlet weak var createdTimeLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bodyTextLabel: UILabel!
    @IBOutlet weak var tweetImageView: UIImageView!
    
    private func updateUI() {
  
        titleLabel.text = nil
        bodyTextLabel.text = nil
        tweetImageView.image = nil
        createdTimeLabel.text = nil
        
        
        if let tweet = self.tweet {
            titleLabel?.text = "\(tweet.user)"
            
            setAndFormatBodyText(tweet)
            
            if let url = tweet.user.profileImageURL {
                let qos = Int(QOS_CLASS_UTILITY.rawValue)
                

                dispatch_async(dispatch_get_global_queue(qos,0)) {
                    if let fetchedData = NSData(contentsOfURL: url ) {

                        dispatch_async(dispatch_get_main_queue()) {
                            self.tweetImageView?.image = UIImage(data: fetchedData)
                        }
                    }
                }
            }
        
        let formatter = NSDateFormatter()
            if NSDate().timeIntervalSinceDate(tweet.created) > 24 * 60 * 60 {
                formatter.dateStyle = NSDateFormatterStyle.ShortStyle
            } else {
                formatter.timeStyle = NSDateFormatterStyle.ShortStyle
            }
            createdTimeLabel?.text = formatter.stringFromDate(tweet.created)
        
        }
    }
  
    
    var hashTagColor = UIColor.orangeColor()
    var urlColor = UIColor.blueColor()
    var userMentionColor = UIColor.redColor()

    private func setAndFormatBodyText (tweet: Tweet) {
        
        var text = tweet.text
        for _ in tweet.media {
            text += " 📷"
        }
        
        let attributedString = NSMutableAttributedString(string: text)
        
        if !tweet.hashtags.isEmpty {
            for hashtag in tweet.hashtags {
                attributedString.addAttribute(NSForegroundColorAttributeName, value: hashTagColor, range: hashtag.nsrange)
            }
        }
        
        if !tweet.urls.isEmpty {
            for url in tweet.urls {
                attributedString.addAttribute(NSForegroundColorAttributeName, value: urlColor, range: url.nsrange)
            }
        }
        
        if !tweet.userMentions.isEmpty {
            for userMention in tweet.userMentions {
                attributedString.addAttribute(NSForegroundColorAttributeName, value: userMentionColor, range: userMention.nsrange)
            }
        }
        
        bodyTextLabel?.attributedText = attributedString
    }
}


