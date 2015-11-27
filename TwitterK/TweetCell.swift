//
//  TweetCell.swift
//  TwitterK
//
//  Created by Khuong Pham on 11/27/15.
//  Copyright © 2015 Fantageek. All rights reserved.
//

import UIKit

class TweetCell: UITableViewCell {

    @IBOutlet weak var topIcon: UIImageView!

    @IBOutlet weak var topLabel: UILabel!

    @IBOutlet weak var profileImage: UIImageView!

    @IBOutlet weak var nameLabel: UILabel!

    @IBOutlet weak var screenNameLabel: UILabel!

    @IBOutlet weak var createdAtLabel: UILabel!

    @IBOutlet weak var contentLabel: UILabel!

    @IBOutlet weak var imagesView: UIView!

    @IBOutlet weak var replyButton: UIButton!

    @IBOutlet weak var retweetButton: UIButton!

    @IBOutlet weak var retweetCountLabel: UILabel!

    @IBOutlet weak var favoriteButton: UIButton!

    @IBOutlet weak var favoriteCountLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
