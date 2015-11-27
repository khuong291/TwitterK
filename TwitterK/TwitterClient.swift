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


class TwitterClient: BDBOAuth1RequestOperationManager {

    var loginCompletion: ((user: User?, error: NSError?) -> ())?

    class var sharedInstance: TwitterClient {
        struct Static {
            static let instance = TwitterClient(baseURL: twitterBaseURL, consumerKey: twitterConsumerKey, consumerSecret: twitterConsumerSecret)
        }

        return Static.instance
    }

    // MARK: Login

    func loginWithCompletion(completion: (user: User?, error: NSError?) -> ()) {
        loginCompletion = completion

        // Fetch request token & redirect to authorization page
        TwitterClient.sharedInstance.requestSerializer.removeAccessToken()
        TwitterClient.sharedInstance.fetchRequestTokenWithPath("oauth/request_token", method: "GET", callbackURL: NSURL(string: "TwitterK://oauth"), scope: nil, success: { (requestToken: BDBOAuth1Credential!) -> Void in
            print("Got the request token")
            let authURL = NSURL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(requestToken.token)")
            UIApplication.sharedApplication().openURL(authURL!)
            }) { (error: NSError!) -> Void in
                print("Error getting the request token: \(error)")
                self.loginCompletion?(user: nil, error: error)
        }

    }

    func openURL(url: NSURL) {
        fetchAccessTokenWithPath("oauth/access_token", method: "POST", requestToken: BDBOAuth1Credential(queryString: url.query), success: { (accessToken: BDBOAuth1Credential!) -> Void in
            print("Got the access token")

            TwitterClient.sharedInstance.requestSerializer.saveAccessToken(accessToken)

            TwitterClient.sharedInstance.GET("1.1/account/verify_credentials.json", parameters: nil, success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in

                let user = User(dictionary: response as! NSDictionary)
                User.currentUser = user
                print("user name: \(user.name)")
                self.loginCompletion!(user: user, error: nil)
                }, failure: { (operation: AFHTTPRequestOperation?, error: NSError?) -> Void in
                    print("error getting current user")
                    self.loginCompletion?(user: nil, error: error)
            })

            }) { (error: NSError!) -> Void in
                print("Failed to receive access token")
                self.loginCompletion?(user: nil, error: error)
        }

    }

    // MARK: Timeline

    func homeTimelineWithParams(count: Int?, maxId: NSNumber?, completion: (tweets: [Tweet]?, error: NSError?) -> ()) {

        var params = [String : AnyObject]()

        if count != nil {
            params["count"] = count!
        }

        if maxId != nil {
            params["max_id"] = maxId!
        }

        GET("1.1/statuses/home_timeline.json", parameters: params, success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in

            let tweets = Tweet.tweetsWithArray(response as! [NSDictionary])
            completion(tweets: tweets, error: nil)


            }, failure: { (operation: AFHTTPRequestOperation?, error: NSError?) -> Void in
                print("error getting home timeline")
                completion(tweets: nil, error: error)
        })
    }

    // MARK: Update

    func updateTweet(text: String, completion: (tweet: Tweet?, error: NSError?) -> ()) {

        var params = [String : AnyObject]()
        params["status"] = text

        POST("1.1/statuses/update.json", parameters: params, success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in

            let newTweet = Tweet(dictionary: response as! NSDictionary)
            completion(tweet: newTweet, error: nil)

            }, failure: { (operation: AFHTTPRequestOperation?, error: NSError?) -> Void in
                print("error updating new tweet")
                completion(tweet: nil, error: error)
        })
    }

    func replyTweet(text: String, originalId: NSNumber, completion: (tweet: Tweet?, error: NSError?) -> ()) {

        var params = [String : AnyObject]()
        params["status"] = text
        params["in_reply_to_status_id"] = originalId

        POST("1.1/statuses/update.json", parameters: params, success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in

            let newTweet = Tweet(dictionary: response as! NSDictionary)
            completion(tweet: newTweet, error: nil)

            }, failure: { (operation: AFHTTPRequestOperation?, error: NSError?) -> Void in
                print("error updating new tweet")
                completion(tweet: nil, error: error)
        })
    }

    // MARK: Favorite

    func favoriteTweet(id: NSNumber, completion: (response: AnyObject?, error: NSError?) -> ()) {

        var params = [String : AnyObject]()
        params["id"] = id

        POST("1.1/favorites/create.json", parameters: params, success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in

            completion(response: response, error: nil)

            }, failure: { (operation: AFHTTPRequestOperation?, error: NSError?) -> Void in
                print("error favoriting tweet")
                completion(response: nil, error: error)
        })
    }

    func unfavoriteTweet(id: NSNumber, completion: (response: AnyObject?, error: NSError?) -> ()) {

        var params = [String : AnyObject]()
        params["id"] = id

        POST("1.1/favorites/destroy.json", parameters: params, success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in

            completion(response: response, error: nil)

            }, failure: { (operation: AFHTTPRequestOperation?, error: NSError?) -> Void in
                print("error unfavoriting tweet")
                completion(response: nil, error: error)
        })
    }

    // MARK: Retweet

    func retweet(id: NSNumber, completion: (response: AnyObject?, error: NSError?) -> ()) {

        let request = "1.1/statuses/retweet/\(id).json"

        POST(request, parameters: nil, success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in

            completion(response: response, error: nil)

            }, failure: { (operation: AFHTTPRequestOperation?, error: NSError?) -> Void in
                print("error retweeting tweet")
                completion(response: nil, error: error)
        })
    }

    func getRetweetedId(id: NSNumber, completion: (retweetedId: NSNumber?, error: NSError?) -> ()) {

        var retweetedId: NSNumber?

        var params = [String : AnyObject]()
        params["include_my_retweet"] = true

        GET("1.1/statuses/show/\(id).json", parameters: params, success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in

            let tweet = response as! NSDictionary
            let curUserRetweet = tweet["current_user_retweet"] as? NSDictionary
            retweetedId = curUserRetweet!["id"] as? NSNumber

            completion(retweetedId: retweetedId, error: nil)

            }, failure: { (operation: AFHTTPRequestOperation?, error: NSError?) -> Void in
                print("error getting home timeline")
                completion(retweetedId: nil, error: error)
        })
    }

    func unretweet(id: NSNumber, completion: (response: AnyObject?, error: NSError?) -> ()) {

        let request = "1.1/statuses/destroy/\(id).json"

        POST(request, parameters: nil, success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in

            completion(response: response, error: nil)

            }, failure: { (operation: AFHTTPRequestOperation?, error: NSError?) -> Void in
                print("error unretweeting tweet")
                completion(response: nil, error: error)
        })
    }
}

