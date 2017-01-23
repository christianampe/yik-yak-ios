//
//  Database.swift
//  MessageBoard
//
//  Created by Ampe on 10/13/16.
//  Copyright © 2016 Ampe. All rights reserved.
//

import Parse
import SwiftLocation
import CoreLocation

class Database {
    
    func grantAccess() {
        let query = PFUser.current()
        query?["accessGranted"] = true
    }
    
    func postToDatabase(image : UIImage , imageName : String , text : String , location : CLLocation , city : String , state : String , country : String) {
        let query = PFObject(className: "Posts")
        let coordinates = PFGeoPoint(location: location)
        let user = PFUser.current()?.objectId
        let array : [Int] = [1,2,3,4]
        let randomIndex = Int(arc4random_uniform(UInt32(array.count)))
        let pictureUIImage = UIImageJPEGRepresentation(image, 0.5)
        let picturePFFile = PFFile(name: imageName, data: pictureUIImage!)
        query["image"] = picturePFFile
        query["userID"] = user
        query["text"] = text
        query["coordinates"] = coordinates
        query["city"] = city
        query["state"] = state
        query["country"] = country
        query["world"] = "World"
        query["comments"] = 0
        query["score"] = 0
        query["userLike"] = [user!]
        query["userDislike"] = []
        query["flags"] = 0
        query["color"] = array[randomIndex]
        query.saveInBackground()
        let scoreQuery = PFQuery(className: "Points")
        scoreQuery.whereKey("userId", equalTo: user!)
        scoreQuery.getFirstObjectInBackground { (objects: PFObject?, error: Error?) in
            objects?.incrementKey("posts")
            objects?.incrementKey("score", byAmount: 10)
            objects?.saveInBackground()
        }
    }
    
    func commentToDatabase(image : UIImage , imageName : String , parent : String , text : String , location : CLLocation , city : String , state : String , country : String) {
        let query = PFObject(className: "Comments")
        let coordinates = PFGeoPoint(location: location)
        let user = PFUser.current()?.objectId
        let array : [Int] = [1,2,3,4]
        let randomIndex = Int(arc4random_uniform(UInt32(array.count)))
        let pictureUIImage = UIImageJPEGRepresentation(image, 0.5)
        let picturePFFile = PFFile(name: imageName, data: pictureUIImage!)
        query["image"] = picturePFFile
        
        let comment = PFQuery(className: "Posts")
        comment.whereKey("objectId", equalTo: parent)
        comment.getFirstObjectInBackground { (objects: PFObject?, error: Error?) in
            objects?.incrementKey("comments")
            objects?.saveInBackground()
        }
        query["userID"] = user
        query["parentID"] = parent
        query["text"] = text
        query["coordinates"] = coordinates
        query["city"] = city
        query["state"] = state
        query["country"] = country
        query["world"] = "World"
        query["comments"] = 0
        query["score"] = 0
        query["userLike"] = [user!]
        query["userDislike"] = []
        query["flags"] = 0
        query["color"] = array[randomIndex]
        query.saveInBackground()
        let scoreQuery = PFQuery(className: "Points")
        scoreQuery.whereKey("userId", equalTo: user!)
        scoreQuery.getFirstObjectInBackground { (objects: PFObject?, error: Error?) in
            objects?.incrementKey("comments")
            objects?.incrementKey("score", byAmount: 5)
            objects?.saveInBackground()
        }
    }
    
    func postUpVoteToDatabase(postId : String, userId : String) {
        let query = PFQuery(className: "Posts")
        let userID = PFUser.current()?.objectId!
        query.whereKey("objectId", equalTo: postId)
        query.getFirstObjectInBackground() { (objects: PFObject?, error: Error?) in
            objects?.incrementKey("score")
            objects?.add(userID!, forKey: "userLike")
            objects?.saveInBackground()
        }
        let scoreQuery = PFQuery(className: "Points")
        scoreQuery.whereKey("userId", equalTo: userID!)
        scoreQuery.getFirstObjectInBackground { (objects: PFObject?, error: Error?) in
            objects?.incrementKey("upVotes")
            objects?.incrementKey("score", byAmount: 2)
            objects?.saveInBackground()
        }
        let scoreQuery2 = PFQuery(className: "Points")
        scoreQuery2.whereKey("userId", equalTo: userId)
        scoreQuery2.getFirstObjectInBackground { (objects: PFObject?, error: Error?) in
            objects?.incrementKey("upVotes")
            objects?.incrementKey("score", byAmount: 2)
            objects?.saveInBackground()
        }
    }
    
    func postDownVoteToDatabase(postId : String, userId : String) {
        let query = PFQuery(className: "Posts")
        let userID = PFUser.current()?.objectId!
        query.whereKey("objectId", equalTo: postId)
        query.getFirstObjectInBackground() { (objects: PFObject?, error: Error?) in
            objects?.incrementKey("score", byAmount: -1)
            objects?.add(userID!, forKey: "userDislike")
            objects?.saveInBackground()
        }
        let scoreQuery = PFQuery(className: "Points")
        scoreQuery.whereKey("userId", equalTo: userID!)
        scoreQuery.getFirstObjectInBackground { (objects: PFObject?, error: Error?) in
            objects?.incrementKey("downVotes")
            objects?.incrementKey("score", byAmount: 1)
            objects?.saveInBackground()
        }
        let scoreQuery2 = PFQuery(className: "Points")
        scoreQuery2.whereKey("userId", equalTo: userId)
        scoreQuery2.getFirstObjectInBackground { (objects: PFObject?, error: Error?) in
            objects?.incrementKey("downVote")
            objects?.incrementKey("score", byAmount: 1)
            objects?.saveInBackground()
        }
    }
    
    func commentUpVoteToDatabase(postId : String, userId : String) {
        let query = PFQuery(className: "Comments")
        let userID = PFUser.current()?.objectId!
        query.whereKey("objectId", equalTo: postId)
        query.getFirstObjectInBackground() { (objects: PFObject?, error: Error?) in
            objects?.incrementKey("score")
            objects?.add(userID!, forKey: "userLike")
            objects?.saveInBackground()
        }
        let scoreQuery = PFQuery(className: "Points")
        scoreQuery.whereKey("userId", equalTo: userID!)
        scoreQuery.getFirstObjectInBackground { (objects: PFObject?, error: Error?) in
            objects?.incrementKey("upVotes")
            objects?.incrementKey("score", byAmount: 2)
            objects?.saveInBackground()
        }
        let scoreQuery2 = PFQuery(className: "Points")
        scoreQuery2.whereKey("userId", equalTo: userId)
        scoreQuery2.getFirstObjectInBackground { (objects: PFObject?, error: Error?) in
            objects?.incrementKey("upVote")
            objects?.incrementKey("score", byAmount: 2)
            objects?.saveInBackground()
        }
    }
    
    func commentDownVoteToDatabase(postId : String, userId : String) {
        let query = PFQuery(className: "Comments")
        let userID = PFUser.current()?.objectId!
        query.whereKey("objectId", equalTo: postId)
        query.getFirstObjectInBackground() { (objects: PFObject?, error: Error?) in
            objects?.incrementKey("score", byAmount: -1)
            objects?.add(userID!, forKey: "userDislike")
            objects?.saveInBackground()
        }
        let scoreQuery = PFQuery(className: "Points")
        scoreQuery.whereKey("userId", equalTo: userID!)
        scoreQuery.getFirstObjectInBackground { (objects: PFObject?, error: Error?) in
            objects?.incrementKey("downVotes")
            objects?.incrementKey("score", byAmount: 2)
            objects?.saveInBackground()
        }
        let scoreQuery2 = PFQuery(className: "Points")
        scoreQuery2.whereKey("userId", equalTo: userId)
        scoreQuery2.getFirstObjectInBackground { (objects: PFObject?, error: Error?) in
            objects?.incrementKey("downVote")
            objects?.incrementKey("score", byAmount: 1)
            objects?.saveInBackground()
        }
    }
    
    func createNewUser(location : CLLocation , city : String , state : String , country : String) {
        let query = PFUser.current()
        let coordinates = PFGeoPoint(location: location)
        query?["coordinates"] = coordinates
        query?["city"] = city
        query?["state"] = state
        query?["country"] = country
        query?["world"] = "World"
        query?["blocked"] = []
        query?.saveInBackground()
        let pointQuery = PFObject(className: "Points")
        let userId = PFUser.current()?.objectId
        pointQuery["score"] = 100
        pointQuery["userId"] = userId
        pointQuery["upVotes"] = 0
        pointQuery["downVotes"] = 0
        pointQuery["posts"] = 0
        pointQuery["comments"] = 0
        pointQuery["reports"] = 0
        pointQuery.saveInBackground()
    }
    
    func updateUserLocation(location : CLLocation , city : String , state : String , country : String) {
        let query = PFUser.current()
        let coordinates = PFGeoPoint(location: location)
        query?["coordinates"] = coordinates
        query?["city"] = city
        query?["state"] = state
        query?["country"] = country
        query?["world"] = "World"
        query?.saveInBackground()
    }
    
    func getLocation() {
        Location.getLocation(withAccuracy: .neighborhood, frequency: .oneShot, timeout: nil, onSuccess: { (loc) in
            UserVariables.userLocation = loc
            PostVariables.postLocation = loc
            CommentVariables.commentLocation = loc
            Location.reverse(coordinates: loc.coordinate, onSuccess: { foundPlacemark in
                UserVariables.userAddress = foundPlacemark
                PostVariables.postAddress = foundPlacemark
                CommentVariables.commentAddress = foundPlacemark
                Database().createNewUser(location: loc, city: foundPlacemark.addressDictionary?["City"] as! String, state: foundPlacemark.addressDictionary?["State"] as! String, country: foundPlacemark.addressDictionary?["Country"] as! String)
                
            }) { error in
            }
        }) { (lastValidLocation, error) in
            let defaultLoc = CLLocation(latitude: +37.78583400, longitude: -122.40641700)
            UserVariables.userLocation = defaultLoc
            PostVariables.postLocation = defaultLoc
            CommentVariables.commentLocation = defaultLoc
            Location.reverse(coordinates: defaultLoc.coordinate, onSuccess: { foundPlacemark in
                UserVariables.userAddress = foundPlacemark
                PostVariables.postAddress = foundPlacemark
                CommentVariables.commentAddress = foundPlacemark
                Database().createNewUser(location: defaultLoc, city: foundPlacemark.addressDictionary?["City"] as! String, state: foundPlacemark.addressDictionary?["State"] as! String, country: foundPlacemark.addressDictionary?["Country"] as! String)
                
            }) { error in
            }
        }
    }
    
    func updateLocation() {
        Location.getLocation(withAccuracy: .neighborhood, frequency: .oneShot, timeout: nil, onSuccess: { (loc) in
            UserVariables.userLocation = loc
            PostVariables.postLocation = loc
            CommentVariables.commentLocation = loc
            Location.reverse(coordinates: loc.coordinate, onSuccess: { foundPlacemark in
                UserVariables.userAddress = foundPlacemark
                PostVariables.postAddress = foundPlacemark
                CommentVariables.commentAddress = foundPlacemark
                Database().updateUserLocation(location: loc, city: foundPlacemark.addressDictionary?["City"] as! String, state: foundPlacemark.addressDictionary?["State"] as! String, country: foundPlacemark.addressDictionary?["Country"] as! String)
            }) { error in
            }
        }) { (lastValidLocation, error) in
            let defaultLoc = CLLocation(latitude: +37.78583400, longitude: -122.40641700)
            UserVariables.userLocation = defaultLoc
            PostVariables.postLocation = defaultLoc
            CommentVariables.commentLocation = defaultLoc
            Location.reverse(coordinates: defaultLoc.coordinate, onSuccess: { foundPlacemark in
                UserVariables.userAddress = foundPlacemark
                PostVariables.postAddress = foundPlacemark
                CommentVariables.commentAddress = foundPlacemark
                Database().createNewUser(location: defaultLoc, city: foundPlacemark.addressDictionary?["City"] as! String, state: foundPlacemark.addressDictionary?["State"] as! String, country: foundPlacemark.addressDictionary?["Country"] as! String)
                
            }) { error in
            }
        }
    }
    
    func rowActionPost(userID : String! , postID : String!) {
        
        let appearance = SCLAlertView.SCLAppearance(
            showCircularIcon: false
        )
        
        if (userID == PFUser.current()?.objectId) {
            let alert = SCLAlertView(appearance: appearance)
            _ = alert.addButton("Delete") {
                self.deletePost(postID: postID)
            }
            
            let color = UniversalVariables.blue
            
            _ = alert.showCustom("Options", subTitle: "", color: color, icon: UIImage())
        }
        else {
            let alert = SCLAlertView(appearance: appearance)
            _ = alert.addButton("Report Post") {
                self.flagPost(postID: postID)
            }
            
            _ = alert.addButton("Block User") {
                self.blockUser(userID: userID)
            }
            
            let color = UniversalVariables.blue
            
            _ = alert.showCustom("Options", subTitle: "", color: color, icon: UIImage())
        }
    }
    
    func rowActionComment(userID : String! , postID : String!) {
        
        let appearance = SCLAlertView.SCLAppearance(
            showCircularIcon: false
        )
        
        if (userID == PFUser.current()?.objectId) {
            let alert = SCLAlertView(appearance: appearance)
            _ = alert.addButton("Delete") {
                self.deleteComment(postID: postID)
            }
            
            let color = UniversalVariables.blue
            
            _ = alert.showCustom("Options", subTitle: "", color: color, icon: UIImage())
        }
        else {
            let alert = SCLAlertView(appearance: appearance)
            _ = alert.addButton("Report Comment") {
                self.flagComment(postID: postID)
            }
            
            _ = alert.addButton("Block User") {
                self.blockUser(userID: userID)
            }
            
            let color = UniversalVariables.blue
            
            _ = alert.showCustom("Options", subTitle: "", color: color, icon: UIImage())
        }
    }
    
    func deletePost(postID : String) {
        let query = PFQuery(className: "Posts")
        query.whereKey("objectId", equalTo: postID)
        query.getFirstObjectInBackground() { (objects: PFObject?, error: Error?) in
            objects?.deleteInBackground()
            objects?.saveInBackground()
        }
    }
    
    func deleteComment(postID : String) {
        let query = PFQuery(className: "Comments")
        query.whereKey("objectId", equalTo: postID)
        query.getFirstObjectInBackground() { (objects: PFObject?, error: Error?) in
            objects?.deleteInBackground()
            objects?.saveInBackground()
        }
    }
    
    func blockUser(userID : String) {
        let query = PFUser.current()
        query?.addUniqueObject(userID, forKey: "blocked")
        query?.saveInBackground()
    }
    
    func flagPost(postID : String) {
        let query = PFQuery(className: "Posts")
        query.whereKey("objectId", equalTo: postID)
        query.getFirstObjectInBackground() { (objects: PFObject?, error: Error?) in
            objects?.incrementKey("flags")
            objects?.saveInBackground()
        }
    }
    
    func flagComment(postID : String) {
        let query = PFQuery(className: "Comments")
        query.whereKey("objectId", equalTo: postID)
        query.getFirstObjectInBackground() { (objects: PFObject?, error: Error?) in
            objects?.incrementKey("flags")
            objects?.saveInBackground()
        }
    }
}
