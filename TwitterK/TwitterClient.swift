//
//  TwitterClient.swift
//  TwitterK
//
//  Created by Khuong Pham on 11/24/15.
//  Copyright © 2015 Fantageek. All rights reserved.
//

import UIKit
import AFNetworking
import BDBOAuth1Manager

let twitterConsumerKey = "Gcg7jzE4qiKzjX0f4x0BoC4PU"
let twitterConsumerSecret = "l24v7fw7fQUiGVNpcrOAf4ISRXxdhi4BBOpt6xxBuP1CL5buvM"
let twitterBaseURL = NSURL(string: "https://api.twitter.com")
let requestTokenUrl = "https://api.twitter.com/oauth/request_token"
let authorizeUrl = "https://api.twitter.com/oauth/authorize"
let accessTokenUrl = "https://api.twitter.com/oauth/access_token"


class TwitterClient: BDBOAuth1RequestOperationManager {

    var loginCompletion: ((user: User?, error: NSError?) -> ())?

    class var sharedInstance: TwitterClient {
        struct Static {
            static let instance = TwitterClient(baseURL: twitterBaseURL, consumerKey: twitterConsumerKey, consumerSecret: twitterConsumerSecret)
        }

        return Static.instance
    }

    func loginWithCompletion(completion: (user: User?, error: NSError?) -> ()) {
        loginCompletion = completion

        // Fetch request token & redirect to authorization page
        TwitterClient.sharedInstance.requestSerializer.removeAccessToken()
        TwitterClient.sharedInstance.fetchRequestTokenWithPath("oauth/request_token", method: "GET", callbackURL: NSURL(string: "TwitterK://oauth"), scope: nil,

            success: { (requestToken: BDBOAuth1Credential!) -> Void in
                print("got the request token\n")
                let authURL = NSURL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(requestToken.token)")
                UIApplication.sharedApplication().openURL(authURL!)
            }) { (error: NSError!) -> Void in
                print("failed to get request token: \(error)")
                self.loginCompletion?(user: nil, error: error)
        }
    }

    func openURL(url: NSURL) {
        fetchAccessTokenWithPath("oauth/access_token", method: "POST", requestToken: BDBOAuth1Credential(queryString: url.query), success: { (accessToken: BDBOAuth1Credential!) -> Void in
            print("Got the access token")

            TwitterClient.sharedInstance.requestSerializer.saveAccessToken(accessToken)

            TwitterClient.sharedInstance.GET("1.1/account/verify_credentials.json", parameters: nil, success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
                //print("user: \(response)")
                let user = User(dictionary: response as! NSDictionary)
                print("user: \(user.name)")
                self.loginCompletion?(user: nil, error: nil)
                }, failure: { (operation: AFHTTPRequestOperation?, error: NSError?) -> Void in
                    print("error getting current user")
            })

            TwitterClient.sharedInstance.GET("1.1/statuses/home_timeline.json", parameters: nil, success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
                //print("home timeline: \(response)")
//                let tweets = Tweet.tweetsWithArray(response as! [NSDictionary])
//
//                for tweet in tweets {
//                    print("text: \(tweet.text), created: \(tweet.createdAt)")
//                }
                }, failure: { (operation: AFHTTPRequestOperation?, error: NSError?) -> Void in
                    print("error getting home timeline")
            })

            }) { (error: NSError!) -> Void in
                print("Failed to receive access token")
                self.loginCompletion?(user: nil, error: error)
        }

    }

}
