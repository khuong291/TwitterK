//
//  DetailViewController.swift
//  TwitterK
//
//  Created by Khuong Pham on 11/27/15.
//  Copyright © 2015 Fantageek. All rights reserved.
//

import UIKit

@objc protocol DetailViewControllerDelegate {
    optional func detailViewController(detailViewController: DetailViewController, didUpdateTweet selectedTweet: Tweet, indexPath: NSIndexPath?, replyTweet: Tweet?)
}

class DetailViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var topIcon: UIImageView!

    @IBOutlet weak var topLabel: UILabel!

    @IBOutlet weak var profileImage: UIImageView!

    @IBOutlet weak var nameLabel: UILabel!

    @IBOutlet weak var screenNameLabel: UILabel!

    @IBOutlet weak var contentLabel: UILabel!

    @IBOutlet weak var imagesView: UIView!

    @IBOutlet weak var createdAtLabel: UILabel!

    @IBOutlet weak var replyButton: UIButton!

    @IBOutlet weak var retweetButton: UIButton!

    @IBOutlet weak var retweetCountLabel: UILabel!

    @IBOutlet weak var favoriteButton: UIButton!

    @IBOutlet weak var favoriteCountLabel: UILabel!

    @IBOutlet weak var replyTextView: UITextView!

    @IBOutlet weak var replyTweetButton: UIButton!

    @IBOutlet weak var limitLabel: UILabel!


    @IBOutlet weak var topIconHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var topLabelHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var imagesViewHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var textViewTrailingConstraint: NSLayoutConstraint!

    @IBOutlet weak var textViewLeadingConstraint: NSLayoutConstraint!

    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!


    var selectedTweet: Tweet?
    var indexPath: NSIndexPath?
    var replyTweet: Tweet?

    weak var delegate: DetailViewControllerDelegate?

    var limit = 140
    var placeholder = ""
    var screenName = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWasShown:"), name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWasHiden:"), name:UIKeyboardWillHideNotification, object: nil)

        profileImage.layer.cornerRadius = 8
        profileImage.layer.masksToBounds = true

        imagesView.layer.cornerRadius = 8
        imagesView.layer.masksToBounds = true

        replyTextView.layer.cornerRadius = 5
        replyTextView.layer.masksToBounds = true
        replyTextView.textColor = UIColor.grayColor()
        replyTextView.delegate = self

        setDetail()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setDetail() {

        let retweetedConstraints = [topIconHeightConstraint, topLabelHeightConstraint]
        let imagesViewConstraints = [imagesViewHeightConstraint]

        TwitterHelper.sharedInstance.setDetail(selectedTweet, topLabel: topLabel, topIcon: topIcon, nameLabel: nameLabel, screenNameLabel: screenNameLabel, createdAtLabel: createdAtLabel, contentLabel: contentLabel, profileImage: profileImage, retweetCountLabel: retweetCountLabel, favoriteCountLabel: favoriteCountLabel, retweetButton: retweetButton, favoriteButton: favoriteButton, imagesView: imagesView, retweetedConstraints: retweetedConstraints, imagesViewConstraints: imagesViewConstraints, isDetailView: true)

        if let name = nameLabel.text {
            placeholder = "Reply to \(name)"
            replyTextView.text = placeholder
        }

        if let screenName = screenNameLabel.text {
            self.screenName = screenName
        }
    }

    // MARK: Button

    @IBAction func onBackButton(sender: AnyObject) {

        if let selectedTweet = selectedTweet {
            self.delegate?.detailViewController?(self, didUpdateTweet: selectedTweet, indexPath: indexPath, replyTweet: replyTweet)
        }

        dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func onReplyTweet(sender: UIButton) {

        TwitterClient.sharedInstance.replyTweet(replyTextView.text, originalId: selectedTweet!.id!, completion: { (tweet, error) -> () in

            if let newTweet = tweet {
                self.replyTweet = newTweet

                if let selectedTweet = self.selectedTweet {
                    self.delegate?.detailViewController?(self, didUpdateTweet: selectedTweet, indexPath: self.indexPath, replyTweet: self.replyTweet)
                }

                self.dismissViewControllerAnimated(true, completion: nil)
            }
        })
    }

    // MARK: Action button

    @IBAction func onReply(sender: UIButton) {
        replyTextView.becomeFirstResponder()
    }

    @IBAction func onRetweet(sender: UIButton) {

        if let selectedTweet = selectedTweet {
            TwitterHelper.sharedInstance.handleRetweet(selectedTweet, retweetCountLabel: retweetCountLabel, retweetButton: retweetButton)
        }
    }

    @IBAction func onFavorite(sender: UIButton) {

        if let selectedTweet = selectedTweet {
            TwitterHelper.sharedInstance.handleFavorite(selectedTweet, favoriteCountLabel: favoriteCountLabel, favoriteButton: favoriteButton)
        }
    }

    // MARK: Keyboard

    func keyboardWasShown(notification: NSNotification) {

        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()

        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.bottomConstraint.constant = keyboardFrame.size.height
            self.textViewTrailingConstraint.constant = 56
            self.textViewLeadingConstraint.constant = 38
        })
    }

    func keyboardWasHiden(notification: NSNotification) {

        if replyTextView.text == "\(screenName) " || replyTextView.text == "\(screenName)" {
            replyTextView.text = placeholder
            replyTextView.textColor = UIColor.grayColor()
            replyTweetButton.enabled = false
            limit = 140
        }

        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.bottomConstraint.constant = 0
            self.textViewLeadingConstraint.constant = 8
            if !self.replyTweetButton.enabled {
                self.textViewTrailingConstraint.constant = 8
            }
        })
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        replyTextView.resignFirstResponder()
    }

    // MARK: Text view

    func textViewDidBeginEditing(textView: UITextView) {

        if replyTextView.text == placeholder {
            replyTextView.text = "\(screenName) "
            limit = 140 - replyTextView.text.utf8.count
            limitLabel.text = "\(limit)"
        }
    }

    func textViewDidChange(textView: UITextView) {

        if replyTextView.text.isEmpty {
            replyTextView.text = placeholder
            replyTextView.textColor = UIColor.grayColor()
            replyTweetButton.enabled = false
            moveCursorToStart(replyTextView)
            limit = 140
            limitLabel.text = "\(limit)"

        } else {
            let firstCharacter = Array(replyTextView.text.characters)[0]
            if replyTextView.text == "\(firstCharacter)\(placeholder)" {
                replyTextView.text = "\(firstCharacter)"
            }

            if replyTextView.text.utf8.count > 140 {
                replyTextView.text = replyTextView.text[0..<140]
            }

            replyTextView.textColor = UIColor.blackColor()
            replyTweetButton.enabled = true
            limit = 140 - replyTextView.text.utf8.count
            limitLabel.text = "\(limit)"
        }

        // Increase text view's height automatically
        let fixedWidth = replyTextView.frame.size.width
        replyTextView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
        textViewHeightConstraint.constant = newSize.height
    }

    func moveCursorToStart(aTextView: UITextView) {

        dispatch_async(dispatch_get_main_queue(), {
            aTextView.selectedRange = NSMakeRange(0, 0);
        })
    }
    
}

