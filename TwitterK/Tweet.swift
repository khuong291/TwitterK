//
//  Tweet.swift
//  TwitterK
//
//  Created by Khuong Pham on 11/26/15.
//  Copyright © 2015 Fantageek. All rights reserved.
//

import UIKit

class Tweet: NSObject {
    var id: NSNumber?
    var user: User?
    var replyToStatusId: NSNumber?
    var replyToScreenName: String?
    var text: String?
    var createdAtString: String?
    var createdAt: NSDate?
    var retweetCount: Int?
    var favoriteCount: Int?
    var isRetweeted = false
    var isFavorited = false
    var images = [NSURL]()
    var retweet: Tweet?

    init(dictionary: NSDictionary) {

        id = dictionary["id"] as? NSNumber!

        user = User(dictionary: dictionary["user"] as! NSDictionary)

        replyToStatusId = dictionary["in_reply_to_status_id"] as? NSNumber!
        replyToScreenName = dictionary["in_reply_to_screen_name"] as? String!

        text = dictionary["text"] as? String!
        createdAtString = dictionary["created_at"] as? String!

        let formatter = NSDateFormatter()
        formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
        createdAt = formatter.dateFromString(createdAtString!)

        retweetCount = dictionary["retweet_count"] as? Int!
        favoriteCount = dictionary["favorite_count"] as? Int!

        isRetweeted = (dictionary["retweeted"] as? Bool!)!
        isFavorited = (dictionary["favorited"] as? Bool!)!

        var url = ""
        if let media = dictionary.valueForKeyPath("extended_entities.media") as? [NSDictionary] {
            for image in media {
                if let urlString = image["media_url"] as? String {
                    images.append(NSURL(string: urlString)!)
                }
                url = (image["url"] as? String)!
            }
        }

        // Remove url at the end of text (in case this tweet has images)
        if !url.isEmpty {
            text = text?.replace(url, withString: "")
            text = text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        }

        if let retweetDictionary = dictionary["retweeted_status"] as? NSDictionary {
            retweet = Tweet(dictionary: retweetDictionary)
        }

    }

    class func tweetsWithArray(array: [NSDictionary]) -> [Tweet] {

        var tweets = [Tweet]()

        for dictionary in array {
            tweets.append(Tweet(dictionary: dictionary))
        }

        return tweets
    }

    func formatedDate() -> String {

        let min = 60
        let hour = min * 60
        let day = hour * 24
        let week = day * 7

        let elapsedTime = NSDate().timeIntervalSinceDate(createdAt!)
        let duration = Int(elapsedTime)

        if duration < min {
            return "\(duration)s"
        } else if duration >= min && duration < hour {
            let minDur = duration / min
            return "\(minDur)m"
        } else if duration >= hour && duration < day {
            let hourDur = duration / hour
            return "\(hourDur)h"
        } else if duration >= day && duration < week {
            let dayDur = duration / day
            return "\(dayDur)d"
        } else {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "M/d/yy"
            let dateString = dateFormatter.stringFromDate(createdAt!)

            return dateString
        }
    }

    func formatedDetailDate() -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        dateFormatter.timeStyle = .ShortStyle
        let dateString = dateFormatter.stringFromDate(createdAt!)

        return dateString
    }
}

extension String {

    subscript (r: Range<Int>) -> String {
        get {
            let startIndex = self.startIndex.advancedBy(r.startIndex)
            let endIndex = startIndex.advancedBy(r.endIndex - r.startIndex)
            return self[Range(start: startIndex, end: endIndex)]
        }
    }

    func replace(target: String, withString: String) -> String {
        return self.stringByReplacingOccurrencesOfString(target, withString: withString, options: NSStringCompareOptions.LiteralSearch, range: nil)
    }
}
