//
//  TwitterHelper.swift
//  TwitterK
//
//  Created by Khuong Pham on 11/27/15.
//  Copyright © 2015 Fantageek. All rights reserved.
//

import UIKit

class TwitterHelper: NSObject {

    class var sharedInstance: TwitterHelper {
        struct Static {
            static let instance = TwitterHelper()
        }

        return Static.instance
    }

    // MARK: Hide view

    func hideView(constraints: [NSLayoutConstraint!]) {

        for constraint in constraints {
            constraint.constant = 0
        }
    }

    // MARK: Display images

    func displayImages(tweet: Tweet, imagesView: UIView, imagesViewConstraints: [NSLayoutConstraint!]) {

        switch tweet.images.count {
        case 0:
            hideView(imagesViewConstraints)
            break
        case 1:
            let imagesViewTmp = NSBundle.mainBundle().loadNibNamed("ImagesView1", owner: self, options: nil).first! as! ImagesView1
            imagesViewTmp.images = tweet.images
            imagesViewTmp.imageView.setImageWithURL(tweet.images[0])
            imagesView.addSubview(imagesViewTmp)
            addConstraintImagesView(imagesViewTmp, imagesView: imagesView)
            break
        case 2:
            let imagesViewTmp = NSBundle.mainBundle().loadNibNamed("ImagesView2", owner: self, options: nil).first! as! ImagesView2
            imagesViewTmp.images = tweet.images
            imagesViewTmp.imageView1.setImageWithURL(tweet.images[0])
            imagesViewTmp.imageView2.setImageWithURL(tweet.images[1])
            imagesView.addSubview(imagesViewTmp)
            addConstraintImagesView(imagesViewTmp, imagesView: imagesView)
            break
        case 3:
            let imagesViewTmp = NSBundle.mainBundle().loadNibNamed("ImagesView3", owner: self, options: nil).first! as! ImagesView3
            imagesViewTmp.images = tweet.images
            imagesViewTmp.imageView1.setImageWithURL(tweet.images[0])
            imagesViewTmp.imageView2.setImageWithURL(tweet.images[1])
            imagesViewTmp.imageView3.setImageWithURL(tweet.images[2])
            imagesView.addSubview(imagesViewTmp)
            addConstraintImagesView(imagesViewTmp, imagesView: imagesView)
            break
        case 4:
            let imagesViewTmp = NSBundle.mainBundle().loadNibNamed("ImagesView4", owner: self, options: nil).first! as! ImagesView4
            imagesViewTmp.images = tweet.images
            imagesViewTmp.imageView1.setImageWithURL(tweet.images[0])
            imagesViewTmp.imageView2.setImageWithURL(tweet.images[1])
            imagesViewTmp.imageView3.setImageWithURL(tweet.images[2])
            imagesViewTmp.imageView4.setImageWithURL(tweet.images[3])
            imagesView.addSubview(imagesViewTmp)
            addConstraintImagesView(imagesViewTmp, imagesView: imagesView)
            break
        default:
            break
        }
    }

    func addConstraintImagesView(tmpView: UIView, imagesView: UIView) {

        tmpView.translatesAutoresizingMaskIntoConstraints = false
        imagesView.translatesAutoresizingMaskIntoConstraints = false

        let myConstraintTop =
        NSLayoutConstraint(item: tmpView,
            attribute: NSLayoutAttribute.Top,
            relatedBy: NSLayoutRelation.Equal,
            toItem: imagesView,
            attribute: NSLayoutAttribute.Top,
            multiplier: 1.0,
            constant: 0)

        let myConstraintBottom =
        NSLayoutConstraint(item: tmpView,
            attribute: NSLayoutAttribute.Bottom,
            relatedBy: NSLayoutRelation.Equal,
            toItem: imagesView,
            attribute: NSLayoutAttribute.Bottom,
            multiplier: 1.0,
            constant: 0)

        let myConstraintTrailing =
        NSLayoutConstraint(item: tmpView,
            attribute: NSLayoutAttribute.Trailing,
            relatedBy: NSLayoutRelation.Equal,
            toItem: imagesView,
            attribute: NSLayoutAttribute.Trailing,
            multiplier: 1.0,
            constant: 0)

        let myConstraintLeading =
        NSLayoutConstraint(item: tmpView,
            attribute: NSLayoutAttribute.Leading,
            relatedBy: NSLayoutRelation.Equal,
            toItem: imagesView,
            attribute: NSLayoutAttribute.Leading,
            multiplier: 1.0,
            constant: 0)

        imagesView.addConstraints([myConstraintBottom, myConstraintLeading, myConstraintTop, myConstraintTrailing])
        imagesView.updateConstraints()
    }

    // MARK: Set detail

    func setDetail(selectedTweet: Tweet!, topLabel: UILabel!, topIcon: UIImageView!, nameLabel: UILabel!, screenNameLabel: UILabel!, createdAtLabel: UILabel!, contentLabel: UILabel!, profileImage: UIImageView!, retweetCountLabel: UILabel!, favoriteCountLabel: UILabel!, retweetButton: UIButton!, favoriteButton: UIButton!, imagesView: UIView!, retweetedConstraints: [NSLayoutConstraint!], imagesViewConstraints: [NSLayoutConstraint!], isDetailView: Bool) {

        var tweet = selectedTweet

        if let retweet = tweet.retweet {
            if let name = tweet.user?.name {
                topLabel.text = "\(name) retweeted"
                topIcon.image = UIImage(named: "RetweetOn")
            }
            tweet = retweet
        }
        else if let replyTweetName = tweet.replyToScreenName {
            topLabel.text = "In reply to @\(replyTweetName)"
            topIcon.image = UIImage(named: "ReplyHover")
        }
        else {
            hideView(retweetedConstraints)
        }

        nameLabel.text = tweet.user?.name
        if let screenName = tweet.user?.screenName {
            screenNameLabel.text = "@\(screenName)"
        }

        if isDetailView {
            createdAtLabel.text = tweet.formatedDetailDate()
        } else {
            createdAtLabel.text = tweet.formatedDate()
        }

        contentLabel.text = tweet.text
        profileImage.setImageWithURL((tweet.user?.profileImageUrl)!)

        if let tweetCount = tweet.retweetCount {
            if tweetCount > 0 {
                retweetCountLabel.text = "\(tweetCount)"
            } else {
                retweetCountLabel.text = ""
            }
        }

        if let favoriteCount = tweet.favoriteCount {
            if favoriteCount > 0 {
                favoriteCountLabel.text = "\(favoriteCount)"
            } else {
                favoriteCountLabel.text = ""
            }
        }

        // Set suitable icons for retweet button and favorite button
        if tweet.isRetweeted {
            retweetButton.setImage(UIImage(named: "RetweetOn"), forState: .Normal)
        } else {
            retweetButton.setImage(UIImage(named: "Retweet"), forState: .Normal)
        }

        if tweet.isFavorited {
            favoriteButton.setImage(UIImage(named: "FavoriteOn"), forState: .Normal)
        } else {
            favoriteButton.setImage(UIImage(named: "Favorite"), forState: .Normal)
        }

        // Disable retweet button if this is current user's tweet
        if let currentUser = User.currentUser {
            if tweet.user?.screenName == currentUser.screenName {
                retweetButton.enabled = false
            } else {
                retweetButton.enabled = true
            }
        }

        // Display images
        displayImages(tweet, imagesView: imagesView, imagesViewConstraints: imagesViewConstraints)
    }

    // MARK: Action button

    func handleRetweet(selectedTweet: Tweet, retweetCountLabel: UILabel!, retweetButton: UIButton!) {

        if selectedTweet.isRetweeted {
            TwitterClient.sharedInstance.getRetweetedId(selectedTweet.id!, completion: { (retweetedId, error) -> () in
                if let myRetweetId = retweetedId {
                    TwitterClient.sharedInstance.unretweet(myRetweetId, completion: { (response, error) -> () in
                        if response != nil {
                            selectedTweet.isRetweeted = false
                            let retweetCount = selectedTweet.retweetCount! - 1
                            selectedTweet.retweetCount = retweetCount
                            if retweetCount != 0 {
                                retweetCountLabel.text = "\(retweetCount)"
                            } else {
                                retweetCountLabel.text = ""
                            }

                            retweetButton.setImage(UIImage(named: "Retweet"), forState: .Normal)
                        }
                    })
                }
            })
        } else {
            TwitterClient.sharedInstance.retweet(selectedTweet.id!, completion: { (response, error) -> () in
                if response != nil {
                    selectedTweet.isRetweeted = true
                    let retweetCount = selectedTweet.retweetCount! + 1
                    selectedTweet.retweetCount = retweetCount
                    retweetCountLabel.text = "\(retweetCount)"
                    retweetButton.setImage(UIImage(named: "RetweetOn"), forState: .Normal)
                }
            })
        }
    }

    func handleFavorite(selectedTweet: Tweet, favoriteCountLabel: UILabel!, favoriteButton: UIButton!) {

        if selectedTweet.isFavorited {
            TwitterClient.sharedInstance.unfavoriteTweet(selectedTweet.id!, completion: { (response, error) -> () in
                if response != nil {
                    selectedTweet.isFavorited = false
                    let favoriteCount = selectedTweet.favoriteCount! - 1
                    selectedTweet.favoriteCount = favoriteCount
                    if favoriteCount != 0 {
                        favoriteCountLabel.text = "\(favoriteCount)"
                    } else {
                        favoriteCountLabel.text = ""
                    }

                    favoriteButton.setImage(UIImage(named: "Favorite"), forState: .Normal)
                }
            })
        } else {
            TwitterClient.sharedInstance.favoriteTweet(selectedTweet.id!, completion: { (response, error) -> () in
                if response != nil {
                    selectedTweet.isFavorited = true
                    let favoriteCount = selectedTweet.favoriteCount! + 1
                    selectedTweet.favoriteCount = favoriteCount
                    favoriteCountLabel.text = "\(favoriteCount)"
                    favoriteButton.setImage(UIImage(named: "FavoriteOn"), forState: .Normal)
                }
            })
        }
    }


    // MARK: Gesture for image view

    func tapImage(view: UIView, images: [NSURL], index: Int) {

        let photoVC = view.parentViewController!.storyboard?.instantiateViewControllerWithIdentifier("photoVC") as! PhotoViewController

        photoVC.images = images
        photoVC.index = index

        view.parentViewController!.presentViewController(photoVC, animated: true, completion: nil)
    }
    
}

