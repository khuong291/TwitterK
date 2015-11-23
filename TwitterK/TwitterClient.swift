//
//  TwitterClient.swift
//  TwitterK
//
//  Created by Khuong Pham on 11/24/15.
//  Copyright © 2015 Fantageek. All rights reserved.
//

import UIKit

let twitterConsumerKey = "Gcg7jzE4qiKzjX0f4x0BoC4PU"
let twitterConsumerSecret = "l24v7fw7fQUiGVNpcrOAf4ISRXxdhi4BBOpt6xxBuP1CL5buvM"
let twitterBaseURL = NSURL(string: "http://api.twitter.com")

class TwitterClient: BDBOAuth1RequestOperationManager {

    class var sharedInstance: TwitterClient {
        struct Static {
            static let instance = TwitterClient(baseURL: twitterBaseURL, consumerKey: twitterConsumerKey, consumerSecret: twitterConsumerSecret)
        }

        return Static.instance
    }
}
