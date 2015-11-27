//
//  User.swift
//  TwitterK
//
//  Created by Khuong Pham on 11/26/15.
//  Copyright © 2015 Fantageek. All rights reserved.
//

import UIKit

var _currentUser: User?
let currentUserKey = "kCurrentUserKey"
let userDidLoginNotification = "userDidLoginNotification"
let userDidLogoutNotification = "userDidLogoutNotification"

class User: NSObject {
    var name: String?
    var screenName: String?
    var profileImageUrl: NSURL?
    var tagline: String?
    var dictionary: NSDictionary

    init(dictionary: NSDictionary) {

        self.dictionary = dictionary

        name = dictionary["name"] as? String
        screenName = dictionary["screen_name"] as? String

        let imageURLString = dictionary["profile_image_url"] as? String
        if imageURLString != nil {
            profileImageUrl = NSURL(string: imageURLString!)
        } else {
            profileImageUrl = nil
        }

        tagline = dictionary["description"] as? String
    }

    func logout() {

        User.currentUser = nil
        TwitterClient.sharedInstance.requestSerializer.removeAccessToken()

        NSNotificationCenter.defaultCenter().postNotificationName(userDidLogoutNotification, object: nil)
    }

    class var currentUser: User? {

        get {
        if _currentUser == nil {
        let data = NSUserDefaults.standardUserDefaults().objectForKey(currentUserKey) as? NSData
        if data != nil {
        let dictionary = (try! NSJSONSerialization.JSONObjectWithData(data!, options: [])) as! NSDictionary
        _currentUser = User(dictionary: dictionary)
        }
        }
        return _currentUser
        }
        set(user) {
            _currentUser = user

            if _currentUser != nil {
                let data = try? NSJSONSerialization.dataWithJSONObject(user!.dictionary, options: [])
                NSUserDefaults.standardUserDefaults().setObject(data, forKey: currentUserKey)
            } else {
                NSUserDefaults.standardUserDefaults().setObject(nil, forKey: currentUserKey)
            }
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
}