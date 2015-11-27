//
//  UpdateViewController.swift
//  TwitterK
//
//  Created by Khuong Pham on 11/27/15.
//  Copyright © 2015 Fantageek. All rights reserved.
//

import UIKit

@objc protocol UpdateViewControllerDelegate {
    optional func updateViewController(updateViewController: UpdateViewController, didUpdateTweet newTweet: Tweet)
}

class UpdateViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!

    @IBOutlet weak var tweetText: UITextView!

    @IBOutlet weak var tweetButton: UIButton!

    @IBOutlet weak var limitLabel: UILabel!

    @IBOutlet weak var replyIcon: UIImageView!

    @IBOutlet weak var replyLabel: UILabel!

    var limit = 140

    var replyTweet: Tweet?

    weak var delegate: UpdateViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWasShown:"), name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWasHiden:"), name:UIKeyboardWillHideNotification, object: nil)

        tweetText.delegate = self
        tweetText.textColor = UIColor.grayColor()
        tweetText.becomeFirstResponder()

        customizeTweetButton()
        customizeBarButton()

        if replyTweet != nil {
            tweetText.textColor = UIColor.blackColor()

            if let replyName = replyTweet?.user?.name {
                replyLabel.text = "In reply to \(replyName)"
                self.navigationItem.title = "Reply Tweet"
            }
            if let replyScreeName = replyTweet?.user?.screenName {
                tweetText.text = "@\(replyScreeName) "
                limit = 140 - tweetText.text.utf8.count
                limitLabel.text = "\(limit)"
            }
        } else {
            hideReply()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: Customize button

    func customizeTweetButton() {

        tweetButton.backgroundColor = UIColor(red: 82/255, green: 173/255, blue: 243/255, alpha: 1.0)
        tweetButton.tintColor = UIColor.whiteColor()
        tweetButton.layer.cornerRadius = 5
        tweetButton.alpha = 0.7
        tweetButton.enabled = false
    }

    func customizeBarButton() {

        let avatar = UIImageView(frame: CGRect(x: 0, y: 0, width: 22, height: 22))
        avatar.setImageWithURL((User.currentUser?.profileImageUrl)!)

        let button: UIButton = UIButton()
        button.setImage(avatar.image, forState: .Normal)
        button.frame = CGRectMake(0, 0, 22, 22)
        //button.targetForAction("actioncall", withSender: nil)

        let leftItem:UIBarButtonItem = UIBarButtonItem()
        leftItem.customView = button
        leftItem.customView?.layer.cornerRadius = 11
        leftItem.customView?.layer.masksToBounds = true
        self.navigationItem.leftBarButtonItem = leftItem
    }

    func hideReply() {

        replyIcon.translatesAutoresizingMaskIntoConstraints = false
        let myConstraintWidthIcon =
        NSLayoutConstraint(item: replyIcon,
            attribute: NSLayoutAttribute.Width,
            relatedBy: NSLayoutRelation.Equal,
            toItem: nil,
            attribute: NSLayoutAttribute.Width,
            multiplier: 1.0,
            constant: 0)

        let myConstraintHeightIcon =
        NSLayoutConstraint(item: replyIcon,
            attribute: NSLayoutAttribute.Height,
            relatedBy: NSLayoutRelation.Equal,
            toItem: nil,
            attribute: NSLayoutAttribute.Height,
            multiplier: 1.0,
            constant: 0)
        replyIcon.addConstraints([myConstraintHeightIcon, myConstraintWidthIcon])

        replyLabel.translatesAutoresizingMaskIntoConstraints = false
        let myConstraintWidthLabel =
        NSLayoutConstraint(item: replyLabel,
            attribute: NSLayoutAttribute.Width,
            relatedBy: NSLayoutRelation.Equal,
            toItem: nil,
            attribute: NSLayoutAttribute.Width,
            multiplier: 1.0,
            constant: 0)

        let myConstraintHeightLabel =
        NSLayoutConstraint(item: replyLabel,
            attribute: NSLayoutAttribute.Height,
            relatedBy: NSLayoutRelation.Equal,
            toItem: nil,
            attribute: NSLayoutAttribute.Height,
            multiplier: 1.0,
            constant: 0)
        replyLabel.addConstraints([myConstraintHeightLabel, myConstraintWidthLabel])

    }

    // MARK: Button

    @IBAction func onCancelButotn(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func onTweetButton(sender: AnyObject) {

        if let replyTweet = replyTweet {
            TwitterClient.sharedInstance.replyTweet(tweetText.text, originalId: replyTweet.id!, completion: { (tweet, error) -> () in
                let newTweet = tweet

                if let newTweet = newTweet {
                    print("new reply")
                    self.delegate?.updateViewController?(self, didUpdateTweet: newTweet)

                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            })
        } else {
            TwitterClient.sharedInstance.updateTweet(tweetText.text, completion: { (tweet, error) -> () in
                let newTweet = tweet

                if let newTweet = newTweet {
                    print("get new tweet")
                    self.delegate?.updateViewController?(self, didUpdateTweet: newTweet)

                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            })
        }
    }

    // MARK: Keyboard

    func keyboardWasShown(notification: NSNotification) {

        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()

        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.bottomConstraint.constant = keyboardFrame.size.height
        })
    }

    func keyboardWasHiden(notification: NSNotification) {

        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.bottomConstraint.constant = 0
        })
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        tweetText.resignFirstResponder()
    }

    // MARK: Text view

    func textViewDidBeginEditing(textView: UITextView) {
        if replyTweet == nil {
            if tweetText.text == "What's happening?" {
                moveCursorToStart(tweetText)
                limit = 140
            }
        }
    }

    func textViewDidChange(textView: UITextView) {

        if tweetText.text.isEmpty {
            tweetText.text = "What's happening?"
            tweetText.textColor = UIColor.grayColor()
            tweetButton.alpha = 0.7
            tweetButton.enabled = false
            moveCursorToStart(tweetText)
            limit = 140
            limitLabel.text = "\(limit)"

        } else {
            let firstCharacter = Array(tweetText.text.characters)[0]
            if tweetText.text == "\(firstCharacter)What's happening?" {
                tweetText.text = "\(firstCharacter)"
            }

            if tweetText.text.utf8.count > 140 {
                tweetText.text = tweetText.text[0..<140]
            }


            tweetText.textColor = UIColor.blackColor()
            tweetButton.alpha = 1
            tweetButton.enabled = true
            limit = 140 - tweetText.text.utf8.count
            limitLabel.text = "\(limit)"
        }
    }

    func moveCursorToStart(aTextView: UITextView) {

        dispatch_async(dispatch_get_main_queue(), {
            aTextView.selectedRange = NSMakeRange(0, 0);
        })
    }
}

