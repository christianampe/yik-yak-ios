//
//  CommentTableView.swift
//  MessageBoard
//
//  Created by Ampe on 10/12/16.
//  Copyright © 2016 Ampe. All rights reserved.


import UIKit
import HidingNavigationBar
import Parse
import ReachabilitySwift

class CommentTableView : UIViewController , UITableViewDelegate , UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var animationTarget: UILabel!
    
    var transition = QZCircleSegue()
    var hidingNavBarManager: HidingNavigationBarManager?
    var navController = UINavigationController()
    var parentNavigationController : UINavigationController?
    
    var refresher = UIRefreshControl()
    
    var imageFile : PFFile!
    var mainText : String!
    var mainLocation : String!
    var mainTime : String!
    var mainScore : String!
    var mainUpVote : CGFloat!
    var mainDownVote : CGFloat!
    var mainID : String!
    var mainOriginalPoster : String!
    var isImage : Bool!
    
    var imageName = [PFFile]()
    var postID = [String]()
    var text = [String]()
    var place = [String]()
    var score = [Int]()
    var time = [Date]()
    var userLike = [NSArray]()
    var userDislike = [NSArray]()
    var originalPoster = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refresher.tintColor = UIColor.white
        
        self.tableView.estimatedRowHeight = 60
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.backgroundColor = PostVariables.postColor
        
        let width = view.frame.size.width
        let height = view.frame.size.height
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: height - 40, width: width, height: 40))
        toolbar.isTranslucent = false
        toolbar.clipsToBounds = true
        view.addSubview(toolbar)
        
        let postButton = UIButton(frame: CGRect(x: 0, y: 0, width: width, height: 40))
        postButton.titleLabel!.font =  UIFont(name: "FontAwesome", size: 20)
        postButton.setTitle("", for: .normal)
        postButton.setTitleColor(UIColor.black, for: .normal)
        postButton.backgroundColor = UIColor.white
        postButton.addTarget(self, action: #selector(makePost), for: .touchUpInside)
        toolbar.addSubview(postButton)
        
        hidingNavBarManager = HidingNavigationBarManager(viewController: self, scrollView: tableView)
        hidingNavBarManager?.manageBottomBar(toolbar)
        
        refresher.addTarget(self, action: #selector(self.loadPosts), for: UIControlEvents.valueChanged)
        tableView.addSubview(refresher)
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.longPress))
        self.view.addGestureRecognizer(longPressRecognizer)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hidingNavBarManager?.viewWillAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        hidingNavBarManager?.viewDidLayoutSubviews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadPosts()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        hidingNavBarManager?.viewWillDisappear(animated)
    }
    
    func loadPosts() {
        
        let reachability = Reachability()!
        if reachability.currentReachabilityStatus == .notReachable {
            Warning().noConnection()
            self.refresher.endRefreshing()
        }
        else {
            Database().updateLocation()
            let query = PFQuery(className: "Comments")
            query.limit = 100
            query.whereKey("parentID", equalTo: CommentVariables.commentParent!)
            query.findObjectsInBackground (block: { (objects:[PFObject]?, error: Error?) -> Void in
                
                self.imageName.removeAll(keepingCapacity: false)
                self.postID.removeAll(keepingCapacity: false)
                self.text.removeAll(keepingCapacity: false)
                self.place.removeAll(keepingCapacity: false)
                self.score.removeAll(keepingCapacity: false)
                self.time.removeAll(keepingCapacity: false)
                self.userLike.removeAll(keepingCapacity: false)
                self.userDislike.removeAll(keepingCapacity: false)
                self.originalPoster.removeAll(keepingCapacity: false)
                
                for object in objects! {
                    self.imageName.append(object.value(forKey: "image") as! PFFile)
                    self.postID.append(object.value(forKey: "objectId") as! String)
                    self.text.append(object.value(forKey: "text") as! String)
                    self.place.append(object.value(forKey: "city") as! String)
                    self.score.append(object.value(forKey: "score") as! Int)
                    self.userLike.append(object.value(forKey: "userLike") as! NSArray)
                    self.userDislike.append(object.value(forKey: "userDislike") as! NSArray)
                    self.originalPoster.append(object.value(forKey: "userID") as! String)
                    self.time.append(object.createdAt!)
                }
                self.tableView?.reloadData()
                self.refresher.endRefreshing()
            })
        }
    }
    
    
    func makePost(sender : UIButton!) {
        UniversalVariables.type = "comment"
        UniversalVariables.originalPosterId = mainOriginalPoster
        UniversalVariables.originalText = mainText
        UniversalVariables.allCommentId = originalPoster
        present(StoryboardVariables.newcomment, animated: true, completion: nil)
    }
    
    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        hidingNavBarManager?.shouldScrollToTop()
        
        return true
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "postcell", for: indexPath) as! PostTableViewCell
            
            if isImage == false {
                cell.imageLabel.isHidden = true
            }
            else {
                cell.imageLabel.isHidden = false
            }
            
            if (mainUpVote < 1.0 || mainDownVote < 1.0) {
                cell.upVote.isEnabled = false
                cell.downVote.isEnabled = false
                cell.upVote.alpha = mainUpVote
                cell.downVote.alpha = mainDownVote
            }
                
            else {
                cell.upVote.isEnabled = true
                cell.downVote.isEnabled = true
            }
            
            cell.postID.text = mainID
            cell.postID.isHidden = true
            cell.postText.text = mainText
            cell.postLocation.text = mainLocation
            cell.timeSince.text = mainTime
            cell.postScore.text = mainScore
            cell.postView.backgroundColor = PostVariables.postColor
            
            return cell
        }
            
        else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "commentcell", for: indexPath) as! CommentTableViewCell
            
            if time.count == 0 {
                
            }
                
            else {
                
                cell.imageLabel.isHidden = true
                cell.contentView.backgroundColor = PostVariables.postColor
                
                if (mainOriginalPoster == originalPoster[indexPath.row - 1]) {
                    cell.originalPoster.text = "  OP"
                }
                    
                else {
                    cell.originalPoster.isHidden = true
                }
                
                let userObjectId = PFUser.current()?.objectId as String?
                let likeContained = self.userLike[indexPath.row - 1].contains(userObjectId!)
                let dislikeContained = self.userDislike[indexPath.row - 1].contains(userObjectId!)
                
                if (likeContained == true || dislikeContained == true) {
                    if (likeContained == true && dislikeContained == false) {
                        cell.upVote.isEnabled = false
                        cell.downVote.isEnabled = false
                        cell.upVote.alpha = 0.75
                        cell.downVote.alpha = 0.25
                    }
                    else if (likeContained == false && dislikeContained == true) {
                        cell.upVote.isEnabled = false
                        cell.downVote.isEnabled = false
                        cell.upVote.alpha = 0.25
                        cell.downVote.alpha = 0.75
                    }
                    else {
                    }
                }
                else {
                    cell.upVote.isEnabled = true
                    cell.downVote.isEnabled = true
                }
                
                let date = time[indexPath.row - 1]
                let now = Date()
                let unitFlags = Set<Calendar.Component>([.second, .minute, .hour, .day])
                let difference = Calendar.current.dateComponents(unitFlags, from: date, to: now)
                
                if difference.second! <= 0 {
                    cell.timeSince.text = "  " + "now"
                }
                if (difference.second! > 0 && difference.minute! == 0) {
                    cell.timeSince.text = "  " + "\(difference.second!)s"
                }
                if (difference.minute! > 0 && difference.hour! == 0) {
                    cell.timeSince.text = "  " + "\(difference.minute!)m"
                }
                if (difference.hour! > 0 && difference.day! == 0) {
                    cell.timeSince.text = "  " + "\(difference.hour!)h"
                }
                if (difference.day! > 0) {
                    cell.timeSince.text = "  " + "\(difference.day!)d"
                }
                
                if (imageName[indexPath.row - 1].name.contains("aaaaupload.jpg") || imageName[indexPath.row - 1].name.contains("aaaacapture.jpg")) {
                    cell.imageLabel.isHidden = false
                }
                
                cell.postID.text = self.postID[indexPath.row - 1]
                cell.postID.isHidden = true
                cell.postText.text =  self.text[indexPath.row - 1]
                cell.postScore.text = String(self.score[indexPath.row - 1])
                cell.postLocation.text = "  " + self.place[indexPath.row - 1]
                
                cell.upVote.tag = indexPath.row
                cell.downVote.tag = indexPath.row
                
            }
            
            return cell
        }
    }
    
    func longPress(longPressGestureRecognizer: UILongPressGestureRecognizer) {
        
        if longPressGestureRecognizer.state == UIGestureRecognizerState.began {
            
            let longPress = longPressGestureRecognizer as UILongPressGestureRecognizer
            let locationInView = longPress.location(in: tableView)
            var indexPath = tableView.indexPathForRow(at: locationInView)!
            
            if (indexPath.row == 0) {
                if (imageFile.name.contains("aaaaupload.jpg") || imageFile.name.contains("aaaacapture.jpg")) {
                    if (imageFile.name.contains("aaaaupload.jpg")) {
                        UniversalVariables.type = "upload"
                        UniversalVariables.imageFile = imageFile
                        performSegue(withIdentifier: "segueTwo", sender: self)
                    }
                    if (imageFile.name.contains("aaaacapture.jpg")) {
                        UniversalVariables.type = "capture"
                        UniversalVariables.imageFile = imageFile
                        performSegue(withIdentifier: "segueTwo", sender: self)
                    }
                    else {
                    }
                }
                else {
                }
            }
            else {
                if (imageName[indexPath.row - 1].name.contains("aaaaupload.jpg") || imageName[indexPath.row - 1].name.contains("aaaacapture.jpg")) {
                    if (imageName[indexPath.row - 1].name.contains("aaaaupload.jpg")) {
                        UniversalVariables.type = "upload"
                        UniversalVariables.imageFile = imageName[indexPath.row - 1]
                        performSegue(withIdentifier: "segueTwo", sender: self)
                    }
                    if (imageName[indexPath.row - 1].name.contains("aaaacapture.jpg")) {
                        UniversalVariables.type = "capture"
                        UniversalVariables.imageFile = imageName[indexPath.row - 1]
                        performSegue(withIdentifier: "segueTwo", sender: self)
                    }
                    else {
                    }
                }
                else {
                }
            }
        }
    }
    
    @IBAction func unwindComment(segue: UIStoryboardSegue) {
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            Database().rowActionPost(userID: mainOriginalPoster, postID: mainID)
        }
            
        else {
            let indexPath = tableView.indexPathForSelectedRow!
            let posterID = self.originalPoster[indexPath.row - 1]
            let postID = self.postID[indexPath.row - 1]
            Database().rowActionComment(userID: posterID, postID: postID)
            tableView.reloadData()
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return time.count + 1
    }
    
    func pushVotes(type: String, num: Int, user: String, message: String) {
        
        let score = [5,10,25,50,100]
        
        if score.contains(num) {
            
            let text = "Your " + type + " '" + message + "' has received " +  "\(num)" + " upvotes!"
            
            let data = [
                "badge" : "Increment",
                "alert" : text,
                ]
            let request = [
                "someKey" : user,
                "data" : data
                ] as [String : Any]
            
            PFCloud.callFunction(inBackground: "push", withParameters: request)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "segueTwo") {
            self.transition.animationChild = self.animationTarget
            self.transition.animationColor = UIColor.black
            let toViewController = segue.destination as! Image
            self.transition.fromViewController = self
            self.transition.toViewController = toViewController
            toViewController.transitioningDelegate = transition
        }
    }
    
    @IBAction func unwindToRoot(segue: UIStoryboardSegue) {
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func mainUpVotePressed(_ sender: AnyObject) {
        
        let currentPostID = mainID
        let indexPath = IndexPath(row: 0, section: 0)
        let cell = tableView.cellForRow(at: indexPath)! as! PostTableViewCell
        Database().postUpVoteToDatabase(postId: currentPostID!, userId: mainOriginalPoster)
        let scoreOne = Int(mainScore)
        let scoreTwo = scoreOne! + 1
        cell.postScore.text = String(scoreTwo)
        cell.upVote.isEnabled = false
        cell.upVote.alpha = 0.75
        cell.downVote.isEnabled = false
        cell.downVote.alpha = 0.25
        
        pushVotes(type: "post", num: scoreTwo, user: mainOriginalPoster, message: mainText)
    }
    
    @IBAction func mainDownVotePressed(_ sender: AnyObject) {
        let currentPostID = mainID
        let indexPath = IndexPath(row: 0, section: 0)
        let cell = tableView.cellForRow(at: indexPath)! as! PostTableViewCell
        Database().postDownVoteToDatabase(postId: currentPostID!, userId: mainOriginalPoster)
        let scoreOne = Int(mainScore)
        let scoreTwo = scoreOne! - 1
        cell.postScore.text = String(scoreTwo)
        cell.upVote.isEnabled = false
        cell.upVote.alpha = 0.25
        cell.downVote.isEnabled = false
        cell.downVote.alpha = 0.75
    }
    
    
    @IBAction func upVotePressed(_ sender: AnyObject) {
        
        let buttonTag = sender.tag
        let indexPath = IndexPath(row: buttonTag!, section: 0)
        let currentCell = tableView.cellForRow(at: indexPath)! as! CommentTableViewCell
        let currentPostID = currentCell.postID.text
        Database().commentUpVoteToDatabase(postId: currentPostID!, userId: originalPoster[indexPath.row - 1])
        let scoreOne = Int(currentCell.postScore.text!)
        let scoreTwo = scoreOne! + 1
        currentCell.postScore.text = String(scoreTwo)
        currentCell.upVote.isEnabled = false
        currentCell.upVote.alpha = 0.75
        currentCell.downVote.isEnabled = false
        currentCell.downVote.alpha = 0.25
        
        pushVotes(type: "comment", num: scoreTwo, user: originalPoster[indexPath.row - 1], message: text[indexPath.row - 1])
        
    }
    
    @IBAction func downVotePressed(_ sender: AnyObject) {
        
        let buttonTag = sender.tag
        let indexPath = IndexPath(row: buttonTag!, section: 0)
        let currentCell = tableView.cellForRow(at: indexPath)! as! CommentTableViewCell
        let currentPostID = currentCell.postID.text
        Database().commentDownVoteToDatabase(postId: currentPostID!, userId: originalPoster[indexPath.row - 1])
        let scoreOne = Int(currentCell.postScore.text!)
        let scoreTwo = scoreOne! - 1
        currentCell.postScore.text = String(scoreTwo)
        currentCell.upVote.isEnabled = false
        currentCell.upVote.alpha = 0.25
        currentCell.downVote.isEnabled = false
        currentCell.downVote.alpha = 0.75
        
    }
}

class PostTableViewCell : UITableViewCell {
    
    @IBOutlet weak var imageLabel: UILabel!
    @IBOutlet weak var postID: UILabel!
    @IBOutlet weak var postView: UIView!
    @IBOutlet weak var postText: UILabel!
    @IBOutlet weak var postLocation: UILabel!
    @IBOutlet weak var timeSince: UILabel!
    @IBOutlet weak var postScore: UILabel!
    @IBOutlet weak var upVote: UIButton!
    @IBOutlet weak var downVote: UIButton!
    
}

class CommentTableViewCell : UITableViewCell {
    
    @IBOutlet weak var imageLabel: UILabel!
    @IBOutlet weak var postID: UILabel!
    @IBOutlet weak var postText: UILabel!
    @IBOutlet weak var postLocation: UILabel!
    @IBOutlet weak var timeSince: UILabel!
    @IBOutlet weak var postScore: UILabel!
    @IBOutlet weak var upVote: UIButton!
    @IBOutlet weak var downVote: UIButton!
    @IBOutlet weak var originalPoster: UILabel!
    
}
