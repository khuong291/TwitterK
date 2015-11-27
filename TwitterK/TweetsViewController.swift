//
//  TweetsViewController.swift
//  TwitterK
//
//  Created by Khuong Pham on 11/26/15.
//  Copyright © 2015 Fantageek. All rights reserved.
//

import UIKit

class TweetsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UpdateViewControllerDelegate, DetailViewControllerDelegate {

    @IBOutlet weak var tableView: UITableView!

    var refreshControl: UIRefreshControl?
    var tableFooterView: UIView!
    var loadingView: UIActivityIndicatorView!
    var notificationLabel: UILabel!

    var tweets = [Tweet]()

    override func viewDidLoad() {
        super.viewDidLoad()

        let logo = UIImageView(image: UIImage(named: "WhiteLogo"))
        self.navigationItem.titleView = logo

        tableView.dataSource = self
        tableView.delegate = self

        tableView.estimatedRowHeight = 228
        tableView.rowHeight = UITableViewAutomaticDimension

        addTableFooterView()
        loadData()
        pullToRefresh()

    }

    override func viewDidLayoutSubviews() {
        // When rotate device

        // Change size of the loading icon
        tableFooterView.frame = CGRect(x: 0, y: 0, width: CGRectGetWidth(tableView.superview!.frame), height: 50)
        notificationLabel.frame = CGRect(x: 0, y: 0, width: CGRectGetWidth(tableView.superview!.frame), height: 50)
        loadingView.center = tableFooterView.center
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onSignOut(sender: AnyObject) {
        User.currentUser?.logout()
    }

    func loadData() {

        TwitterClient.sharedInstance.homeTimelineWithParams(nil, maxId: nil, completion: { (tweets, error) -> () in
            self.tweets = tweets!
            for tweet in self.tweets {
                print("text: \(tweet.text), created: \(tweet.createdAt)")
            }
            self.tableView.reloadData()
        })

        refreshControl?.endRefreshing()
    }

    func pullToRefresh() {
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl!.addTarget(self, action: "loadData", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl!)
    }

    // MARK: Table view

    func addTableFooterView() {

        tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: CGRectGetWidth(tableView.superview!.frame), height: 50))
        print("width: \(tableFooterView.frame.width)")
        loadingView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        loadingView.startAnimating()
        loadingView.center = tableFooterView.center
        tableFooterView.addSubview(loadingView)

        notificationLabel = UILabel(frame: CGRect(x: 0, y: 0, width: CGRectGetWidth(tableView.superview!.frame), height: 50))
        notificationLabel.text = "No more tweets"
        notificationLabel.textAlignment = NSTextAlignment.Center
        notificationLabel.hidden = true
        tableFooterView.addSubview(notificationLabel)

        tableView.tableFooterView = tableFooterView
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCellWithIdentifier("TweetCell", forIndexPath: indexPath) as! TweetCell

        cell.tweet = tweets[indexPath.row]

        cell.contentLabel.numberOfLines = 0
        cell.contentLabel.sizeToFit()

        if indexPath.row == tweets.count - 1 {

            loadingView.startAnimating()
            notificationLabel.hidden = true
            getMoreTweets()

        } else {
            loadingView.stopAnimating()
        }

        if indexPath.row % 2 == 0 {
            cell.backgroundColor = UIColor(red: 222/255, green: 243/255, blue: 255/255, alpha: 1.0)
        } else {
            cell.backgroundColor = UIColor.whiteColor()
        }

        // Set full width for the separator
        cell.layoutMargins = UIEdgeInsetsZero
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsetsZero

        return cell
    }

    func getMoreTweets() {

        if tweets.count > 0 {
            let maxId = ((tweets[tweets.count - 1].id)!.longLongValue - NSNumber(integer: 1).longLongValue) as NSNumber

            TwitterClient.sharedInstance.homeTimelineWithParams(20, maxId: maxId, completion: { (tweets, error) -> () in
                let newTweets = tweets!
                for tweet in newTweets {
                    self.tweets.append(tweet)
                }
                self.tableView.reloadData()

                print(error)
            })
        }
    }

    // MARK: Transfer between 2 view controllers

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        let navigationController = segue.destinationViewController as! UINavigationController

        if navigationController.topViewController is UpdateViewController {
            let updateViewController = navigationController.topViewController as! UpdateViewController
            updateViewController.delegate = self

            if segue.identifier == "replySegue" {
                if let chosenTweetCell = sender!.superview!!.superview as? TweetCell {
                    let chosenTweet = chosenTweetCell.tweet
                    updateViewController.replyTweet = chosenTweet
                }
            }
        } else if navigationController.topViewController is DetailViewController {
            let detailViewController = navigationController.topViewController as! DetailViewController
            detailViewController.delegate = self

            var indexPath: AnyObject!
            indexPath = tableView.indexPathForCell(sender as! UITableViewCell)

            detailViewController.selectedTweet = tweets[indexPath!.row]
            detailViewController.indexPath = indexPath! as? NSIndexPath
        }

    }

    func updateViewController(updateViewController: UpdateViewController, didUpdateTweet newTweet: Tweet) {
        addNewTweet(newTweet)
    }

    func detailViewController(detailViewController: DetailViewController, didUpdateTweet selectedTweet: Tweet, indexPath: NSIndexPath?, replyTweet: Tweet?) {

        // Handle retweet and favorite
        if let indexPath = indexPath {
            tweets[indexPath.row] = selectedTweet
            let cell = tableView.cellForRowAtIndexPath(indexPath) as! TweetCell

            // Set count
            if let tweetCount = selectedTweet.retweetCount {
                if tweetCount > 0 {
                    cell.retweetCountLabel.text = "\(tweetCount)"
                } else {
                    cell.retweetCountLabel.text = ""
                }
            }

            if let favoriteCount = selectedTweet.favoriteCount {
                if favoriteCount > 0 {
                    cell.favoriteCountLabel.text = "\(favoriteCount)"
                } else {
                    cell.favoriteCountLabel.text = ""
                }
            }

            // Set suitable icons for retweet button and favorite button
            if selectedTweet.isRetweeted {
                cell.retweetButton.setImage(UIImage(named: "RetweetOn"), forState: .Normal)
            } else {
                cell.retweetButton.setImage(UIImage(named: "Retweet"), forState: .Normal)
            }

            if selectedTweet.isFavorited {
                cell.favoriteButton.setImage(UIImage(named: "FavoriteOn"), forState: .Normal)
            } else {
                cell.favoriteButton.setImage(UIImage(named: "Favorite"), forState: .Normal)
            }
        }

        // If has new reply
        if let replyTweet = replyTweet {
            addNewTweet(replyTweet)
        }
    }

    func addNewTweet(newTweet: Tweet) {

        tweets.insert(newTweet, atIndex: 0)
        tableView.reloadData()

        // Scroll to the top of table view
        self.tableView.contentOffset = CGPointMake(0, 0 - self.tableView.contentInset.top)
    }
    
}
