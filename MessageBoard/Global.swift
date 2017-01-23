//
//  Global.swift
//  MessageBoard
//
//  Created by Ampe on 10/11/16.
//  Copyright © 2016 Ampe. All rights reserved.
//

import UIKit
import CoreLocation
import Parse

struct StoryboardVariables {
    static var storyboard = UIStoryboard(name: "Main", bundle: nil)
    static var feed = storyboard.instantiateViewController(withIdentifier: "feed")
    static var profile = storyboard.instantiateViewController(withIdentifier: "profile")
    static var newpost = storyboard.instantiateViewController(withIdentifier: "newpost")
    static var newcomment = storyboard.instantiateViewController(withIdentifier: "newcomment")
    static var agree = storyboard.instantiateViewController(withIdentifier: "agree")
    static var myPosts = storyboard.instantiateViewController(withIdentifier: "myposts")
    static var settings = storyboard.instantiateViewController(withIdentifier: "settings")
}

struct PostVariables {
    static var postLocation : CLLocation?
    static var postAddress : CLPlacemark?
    static var postCity : String?
    static var postState : String?
    static var postCountry : String?
    static var postColor : UIColor?
}

struct CommentVariables {
    static var commentParent : String?
    static var commentLocation : CLLocation?
    static var commentAddress : CLPlacemark?
    static var commentCity : String?
    static var commentState : String?
    static var commentCountry : String?
}

struct UserVariables {
    static var userLocation : CLLocation?
    static var userAddress : CLPlacemark?
    static var userCity : String?
    static var userState : String?
    static var userCountry : String?
}

struct UniversalVariables {
    static var green = UIColor(red: 87, green: 232, blue: 137)
    static var orange = UIColor(red: 232, green: 141, blue: 87)
    static var blue = UIColor(red: 95, green: 150, blue: 255)
    static var purple = UIColor(red: 244, green: 95, blue: 255)
    static var type : String?
    static var imageFile : PFFile?
    static var originalPosterId : String?
    static var originalText : String?
    static var allCommentId : [String]?
    static var isImage : Bool?
}

