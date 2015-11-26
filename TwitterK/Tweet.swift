//
//  Tweet.swift
//  TwitterK
//
//  Created by Khuong Pham on 11/26/15.
//  Copyright © 2015 Fantageek. All rights reserved.
//

import UIKit

class Tweet: NSObject {
    var user: User?
    var text: String?
    var createdAtString: String?
    var createdAt: NSDate?

    init(dictionary: NSDictionary) {

        user = User(dictionary: dictionary["user"] as! NSDictionary)
        text = dictionary["text"] as? String!
        createdAtString = dictionary["created_at"] as? String!

        let formatter = NSDateFormatter()
        formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
        createdAt = formatter.dateFromString(createdAtString!)
    }

    class func tweetsWithArray(array: [NSDictionary]) -> [Tweet] {
        var tweets = [Tweet]()

        for dictionary in array {
            tweets.append(Tweet(dictionary: dictionary))
        }

        return tweets
    }
}
