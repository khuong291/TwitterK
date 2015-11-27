//
//  ImagesView1.swift
//  TwitterK
//
//  Created by Khuong Pham on 11/27/15.
//  Copyright © 2015 Fantageek. All rights reserved.
//

import UIKit

class ImagesView1: UIView {

    @IBOutlet weak var imageView: UIImageView!

    //    var imageUrl: NSURL?

    var images = [NSURL]()

    override func awakeFromNib() {
        super.awakeFromNib()

        imageView.userInteractionEnabled = true
        let tapImage = UITapGestureRecognizer(target: self, action: "tapImage:")
        imageView.addGestureRecognizer(tapImage)
    }

    func tapImage(sender:UITapGestureRecognizer) {
        TwitterHelper.sharedInstance.tapImage(self, images: images, index: 0)
    }
}


extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.nextResponder()
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}
