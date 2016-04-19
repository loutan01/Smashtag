//
//  RecentSearchTableViewController.swift
//  Smashtag
//
//  Created by Andrew Loutfi on 4/5/16.
//  Copyright © 2016 Andrew Loutfi. All rights reserved.
//

import UIKit


class RecentSearchTableViewController: UITableViewController {
    
    private let userDefaults = UserDefaults()

    private var recentSearches: [String] {
        return userDefaults.fetchSearchTerms()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Recent Searches"

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        tableView.reloadData()
    }
    
    private struct Storyboard {
        static let TableViewReusableCellIdentifier = "RecentSearch"
        static let SegueIdentifier = "Show Tweets"
    }
    
    
    @IBAction func unwindToMainMenu(sender: UIStoryboardSegue) {
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recentSearches.count
    }

  
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.TableViewReusableCellIdentifier, forIndexPath: indexPath) 
        
        cell.textLabel?.text = recentSearches[indexPath.row]

        return cell
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            userDefaults.deleteSearchTerm(removeAtIndexPath: indexPath)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }


    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
            case Storyboard.SegueIdentifier:
                if let cell = sender as? UITableViewCell, let text = cell.textLabel?.text {
                    if let tvc = segue.destinationViewController as? TweetTableViewController {
                        tvc.searchText = text
                    }
                }
            default: break
            }
        }
    }
}
