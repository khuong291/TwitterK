//
//  ViewController.swift
//  TwitterK
//
//  Created by Khuong Pham on 11/24/15.
//  Copyright © 2015 Fantageek. All rights reserved.
//

import UIKit
import Alamofire
import OAuthSwift
import WebKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func onLogin(sender: AnyObject) {
        let oauthswift = OAuth1Swift(
            consumerKey:    "Gcg7jzE4qiKzjX0f4x0BoC4PU",
            consumerSecret: "l24v7fw7fQUiGVNpcrOAf4ISRXxdhi4BBOpt6xxBuP1CL5buvM",
            requestTokenUrl: "https://api.twitter.com/oauth/request_token",
            authorizeUrl:    "https://api.twitter.com/oauth/authorize",
            accessTokenUrl:  "https://api.twitter.com/oauth/access_token"
        )
        oauthswift.authorizeWithCallbackURL(
            NSURL(string: "TwitterK://")!,
            success: { credential, response in
                print(credential.oauth_token + "\n")
                print(credential.oauth_token_secret + "\n")
            },
            failure: { error in
                print(error.localizedDescription)
            }             
        )
    }

}

