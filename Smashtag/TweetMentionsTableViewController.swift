//
//  TweetMentionsTableViewController.swift
//  Smashtag
//
//  Created by Andrew Loutfi on 4/5/16.
//  Copyright © 2016 Andrew Loutfi. All rights reserved.
//

import UIKit

class TweetMentionsTableViewController: UITableViewController {
    
    var tweet: Tweet? {
        didSet{
            mentions.removeAll()
            
            if let user = tweet?.user {
                title = "\(user)"
            }
            
            if let imageMention = tweet?.media {
                if imageMention.count > 0 {
                    let imageMentionArray = Mentions(title: Constants.ImageMentionTitle, data: imageMention.map { (MentionItem.Image($0.url, $0.aspectRatio)) })
                    mentions.append(imageMentionArray)
                }
            }
            if let urlMention = tweet?.urls {
                if urlMention.count > 0 {
                    let urlMentionArray = Mentions(title: Constants.UrlMentionTitle, data: urlMention.map {(MentionItem.Keyword($0.keyword))})
                    mentions.append(urlMentionArray)
                }
            }

            if let userScreenName = tweet?.user.screenName {
                var userArray = Mentions(title: Constants.UserMentionTitle, data: [MentionItem.Keyword("@\(userScreenName)")])
                if let userMention = tweet?.userMentions {
                    if userMention.count > 0 {
                        let userMentionArray = userMention.map {(MentionItem.Keyword($0.keyword))}
                        userArray.data.appendContentsOf(userMentionArray)
                    }
                }
                mentions.append(userArray)
            }
            
            if let hashTagMention = tweet?.hashtags {
                if hashTagMention.count > 0 {
                    let hashTagArray = Mentions(title: Constants.HashtagMentionTitle, data: hashTagMention.map {(MentionItem.Keyword($0.keyword))})
                    mentions.append(hashTagArray)
                }
            }
        tableView?.reloadData()
        }
    }
    
    private var mentions = [Mentions]()
    
    private struct Mentions {
        var title: String
        var data: [MentionItem] = []
    }
    
    private enum MentionItem {
        case Image(NSURL, Double)
        case Keyword(String)
    }
    
    private struct Constants {
        static let ImageMentionTitle = "Image"
        static let UrlMentionTitle = "Url"
        static let UserMentionTitle = "User"
        static let HashtagMentionTitle = "HashTag"
        static let ImageBaseHeight:CGFloat = 200
        
    }
    
    private struct Storyboard {
        static let TableViewReusableImageCellIdentifier = "ImageMention"
        static let TableViewReusableTextCellIdentifier = "TextMention"
        static let UnwindToMainMenuIdentifier = "Unwind To Main Menu"
        static let WebviewSegueIdentifier = "Show WebView"
        static let ScrollViewSegueIdentifier = "Show ScrollableImage"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return mentions.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mentions[section].data.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let mention = mentions[indexPath.section].data[indexPath.row]
        
        switch mention {
        case .Image(let url, let aspectRatio):
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.TableViewReusableImageCellIdentifier, forIndexPath: indexPath) as! ImageTableViewCell
            cell.imageUrl = url
            return cell
        
        case .Keyword(let keyword):
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.TableViewReusableTextCellIdentifier, forIndexPath: indexPath) 
            cell.textLabel?.text = "\(keyword)"
            return cell
        }
    }
        override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return mentions[section].title
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        let mention = mentions[indexPath.section].data[indexPath.row]
        
        switch mention {
        case .Image(_, let aspectRatio):
            return tableView.bounds.size.width / CGFloat(aspectRatio)
            
        default: return UITableViewAutomaticDimension
        }
        
    }
    

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let mention = mentions[indexPath.section].data[indexPath.row]
        
        switch mention {
        case .Keyword(let keyword):
            let mentionTitle = mentions[indexPath.section].title
            if mentionTitle == Constants.UrlMentionTitle {

                performSegueWithIdentifier(Storyboard.WebviewSegueIdentifier, sender: tableView.cellForRowAtIndexPath(indexPath))
                
            } else {

                performSegueWithIdentifier(Storyboard.UnwindToMainMenuIdentifier, sender: tableView.cellForRowAtIndexPath(indexPath))
            }
        case .Image(_, _):

            performSegueWithIdentifier(Storyboard.ScrollViewSegueIdentifier, sender: tableView.cellForRowAtIndexPath(indexPath))
        }
        
    }
    

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if let identifier = segue.identifier {
            switch identifier {
            case Storyboard.UnwindToMainMenuIdentifier:
                let cell = sender as! UITableViewCell
                if let indexPath = tableView.indexPathForCell(cell) {
                    if let tvc = segue.destinationViewController as? TweetTableViewController {
                        let mentionTitle = mentions[indexPath.section].title
                        
                       
                    }
                }
                
            case Storyboard.WebviewSegueIdentifier:
                let cell = sender as! UITableViewCell
                if let indexPath = tableView.indexPathForCell(cell) {
                    if let wvc = segue.destinationViewController as? WebViewController {
                        let urlString = cell.textLabel?.text
                        wvc.url = NSURL(string: urlString!)
                    }
                }
            
            case Storyboard.ScrollViewSegueIdentifier:
                let cell = sender as! ImageTableViewCell
                if let indexPath = tableView.indexPathForCell(cell) {
                    if let svc = segue.destinationViewController as? ScrollViewController {
                        let mention = mentions[indexPath.section].data[indexPath.row]
                        switch mention {
                        case .Image(let nsurl, _):
                            svc.imageUrl = nsurl
                        default: break
                        }
                    }
                }
            default: break
            }
        }
    }
}


