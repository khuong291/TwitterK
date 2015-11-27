//
//  PhotoViewController.swift
//  TwitterK
//
//  Created by Khuong Pham on 11/27/15.
//  Copyright © 2015 Fantageek. All rights reserved.
//

import UIKit

class PhotoViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!

    var imageUrl: NSURL?

    var pinchGestureRecognizer: UIPinchGestureRecognizer?
    var panGestureRecognizer: UIPanGestureRecognizer?
    var upSwipe: UISwipeGestureRecognizer?
    var downSwipe: UISwipeGestureRecognizer?
    var leftSwipe: UISwipeGestureRecognizer?
    var rightSwipe: UISwipeGestureRecognizer?

    var images = [NSURL]()
    var index = -1

    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.setImageWithURL(images[index])

        imageView.userInteractionEnabled = true

        pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: "pinchGestureDetected:")
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "panGestureDetected:")

        upSwipe = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipes:"))
        downSwipe = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipes:"))
        leftSwipe = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipes:"))
        rightSwipe = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipes:"))

        upSwipe!.direction = .Up
        downSwipe!.direction = .Down
        leftSwipe!.direction = .Left
        rightSwipe!.direction = .Right

        imageView.addGestureRecognizer(pinchGestureRecognizer!)
        imageView.addGestureRecognizer(upSwipe!)
        imageView.addGestureRecognizer(downSwipe!)
        imageView.addGestureRecognizer(leftSwipe!)
        imageView.addGestureRecognizer(rightSwipe!)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func onClose(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    func handleSwipes(sender:UISwipeGestureRecognizer) {

        switch sender.direction {
        case UISwipeGestureRecognizerDirection.Up:
            dismissViewControllerAnimated(true, completion: nil)
            break
        case UISwipeGestureRecognizerDirection.Down:
            dismissViewControllerAnimated(true, completion: nil)
            break
        case UISwipeGestureRecognizerDirection.Right:
            if index - 1 >= 0 {
                index--
                imageView.setImageWithURL(images[index])
            }
            break
        case UISwipeGestureRecognizerDirection.Left:
            if index + 1 < images.count {
                index++
                UIView.animateWithDuration(1.0, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                    self.imageView.setImageWithURL(self.images[self.index])
                    }, completion: nil)
            }
            break
        default:
            break
        }
    }

    func pinchGestureDetected(sender:UIPinchGestureRecognizer) {

        let state = sender.state
        let scale = sender.scale

        if (state == UIGestureRecognizerState.Began || state == UIGestureRecognizerState.Changed) {
            if !(scale < 1 && imageIsSmallerThanScreen()) {
                imageView.transform = CGAffineTransformScale(imageView.transform, scale, scale)
                sender.scale = 1

                if imageIsSmallerThanScreen() {
                    imageView.removeGestureRecognizer(panGestureRecognizer!)
                    imageView.addGestureRecognizer(upSwipe!)
                    imageView.addGestureRecognizer(downSwipe!)

                    imageView.transform = CGAffineTransformMakeTranslation(0, 0)

                } else {
                    imageView.removeGestureRecognizer(upSwipe!)
                    imageView.removeGestureRecognizer(downSwipe!)
                    imageView.addGestureRecognizer(panGestureRecognizer!)
                }
            }
        }
    }

    func panGestureDetected(sender:UIPanGestureRecognizer) {

        let state = sender.state
        if (state == UIGestureRecognizerState.Changed) {
            let translation = sender.translationInView(sender.view!)
            imageView.transform = CGAffineTransformTranslate(imageView.transform, translation.x, translation.y)
            //            imageView.center = CGPointMake(translation.x, translation.y)
            sender.setTranslation(CGPointZero, inView: sender.view)
        }
    }

    func imageIsSmallerThanScreen() -> Bool {

        if imageView.frame.width < UIScreen.mainScreen().bounds.width && imageView.frame.height < UIScreen.mainScreen().bounds.height {
            return true
        }

        if imageView.frame.width == UIScreen.mainScreen().bounds.width || imageView.frame.height == UIScreen.mainScreen().bounds.height {
            return true
        }

        return false
    }
    
}

