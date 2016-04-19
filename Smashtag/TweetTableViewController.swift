//
//  TweetTableViewController.swift
//  Smashtag
//
//  Created by Andrew Loutfi on 4/5/16.
//  Copyright © 2016 Andrew Loutfi. All rights reserved.
//

import UIKit

class TweetTableViewController: UITableViewController, UITextFieldDelegate {
    
    var tweets = [[Tweet]]()
    
    private let userDefaults = UserDefaults()
    
    private var searchTerms: [String] {
        get { return userDefaults.fetchSearchTerms() }
        set { userDefaults.storeSearchTerms(newValue) }
    }
    
    @IBOutlet weak var refreshIndicator: UIRefreshControl!
    @IBOutlet weak var twitterSearchField: UITextField! {
        didSet {
            twitterSearchField.delegate = self
            twitterSearchField.text = searchText
        }
    }
    
    @IBAction func unwindToMainMenu(sender: UIStoryboardSegue) {
    }
    
    var tweetToShow: Tweet? {
        didSet {
            if tweetToShow != nil  {
                tweets.removeAll()
                tweets.append([tweetToShow!])
                tableView.reloadData()
            }
        }
    }
    
    var searchText: String? {
        didSet {
            lastSuccessfulRequest = nil
            twitterSearchField?.text = searchText
            tweets.removeAll()
            tableView.reloadData()
            fetchTweets()
            
            if let searchText = searchText  {
                searchTerms.insert(searchText, atIndex: 0)
            }
        }
    }
    
    private struct Storyboard {
        static let TableViewReusableCellIdentifier = "Tweet"
        static let SegueIdentifier = "Show Mentions"
        static let CollectionSegueIdentifier = "Show Images"
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        fetchTweets()
    }
    
    var lastSuccessfulRequest: TwitterRequest?
    
    var nextRequestToAttempt: TwitterRequest? {
        if lastSuccessfulRequest == nil  {
            if searchText != nil {
                return TwitterRequest(search: searchText!, count: 100)
            } else {
              return nil
            }
        } else {
            return lastSuccessfulRequest!.requestForNewer
        }
    }
    
    private func fetchTweets() {
        if refreshIndicator != nil {
            refreshIndicator?.beginRefreshing()
        }
        refresh(refreshIndicator)
    }
    

    @IBAction func refresh(sender: UIRefreshControl?) {
        if searchText != nil {
            title = searchText
            if let request = nextRequestToAttempt {
                request.fetchTweets { (tweets) -> Void in
                    dispatch_async(dispatch_get_main_queue()) {
                        if tweets.count > 0 {
                            self.lastSuccessfulRequest = request
                            self.tweets.insert(tweets, atIndex: 0)
                            self.tableView.reloadData()
                        }
                        sender?.endRefreshing()
                    }
                }
            }
        } else {
            sender?.endRefreshing()
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == twitterSearchField {
            searchText = textField.text
            
        }

        textField.resignFirstResponder()
        return true
    }


    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return tweets.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets[section].count
    }
  
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.TableViewReusableCellIdentifier, forIndexPath: indexPath) as! TweetTableViewCell
        let tweet = tweets[indexPath.section][indexPath.row]
        cell.tweet = tweet
        
        return cell
    }

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if let identifier = segue.identifier {
            switch identifier {
            case Storyboard.SegueIdentifier:
                if let tmvc = segue.destinationViewController as? TweetMentionsTableViewController {
                    let cell = sender as! TweetTableViewCell
                    if let indexPath = tableView.indexPathForCell(cell) {
                        tmvc.tweet = self.tweets[indexPath.section][indexPath.row]
                    }
                }
            case Storyboard.CollectionSegueIdentifier:
                if let tcvc = segue.destinationViewController as? TweetCollectionViewController {
                    tcvc.tweets = tweets
                    tcvc.title = title
                }
                
            default: break
            }
        }
    }
    
    override func canPerformUnwindSegueAction(action: Selector, fromViewController: UIViewController, withSender sender: AnyObject) -> Bool {
        if let first = navigationController?.viewControllers.first as? TweetTableViewController {
            if first == self {
                return true
            }
        }
        
        if let sender = sender as? UITableViewCell {
            return true
        }
        return false
    }
}
