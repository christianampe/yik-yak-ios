//
//  TableView.swift
//  MessageBoard
//
//  Created by Ampe on 10/10/16.
//  Copyright © 2016 Ampe. All rights reserved.


import UIKit
import Parse
import HidingNavigationBar
import BTNavigationDropdownMenu
import ReachabilitySwift

class FeedTableView : UIViewController , UITableViewDelegate , UITableViewDataSource {
    
    @IBOutlet weak var animationTarget: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var selectedCellLabel: UILabel!
    @IBOutlet weak var customSC: UISegmentedControl!
    @IBOutlet weak var scoreLabel: UILabel!
    
    var transition = QZCircleSegue()
    var hidingNavBarManager: HidingNavigationBarManager?
    var menuView: BTNavigationDropdownMenu!
    var parentNavigationController : UINavigationController?
    
    var location = CLLocation()
    var refresher = UIRefreshControl()
    
    var imageFile : PFFile!
    var category : String!
    var mainText : String!
    var mainLocation : String!
    var mainTime : String!
    var mainScore : String!
    var mainColor : String!
    var mainUpVote : CGFloat!
    var mainDownVote : CGFloat!
    var mainID : String!
    var mainOriginalPoster : String!
    var isImage : Bool!
    
    var blocked = [String]()
    var postID = [String]()
    var text = [String]()
    var place = [String]()
    var comments = [Int]()
    var score = [Int]()
    var color = [Int]()
    var time = [Date]()
    var userLike = [NSArray]()
    var userDislike = [NSArray]()
    var originalPoster = [String]()
    var imageName = [PFFile]()
    
    var direction = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.backgroundColor = UniversalVariables.blue
        self.refresher.tintColor = UIColor.white
        
        let radius = ["City", "State", "Country", "World"]
        
        category = "world"
        
        self.selectedCellLabel.text = radius.first
        menuView = BTNavigationDropdownMenu(navigationController: self.navigationController, containerView: self.navigationController!.view, title: radius[3], items: radius as [AnyObject])
        menuView.cellHeight = 50
        menuView.arrowTintColor = UIColor.black
        menuView.cellSeparatorColor = UIColor.lightGray
        menuView.cellBackgroundColor = UIColor.black
        menuView.cellSelectionColor = UIColor.white
        menuView.shouldKeepSelectedCellColor = true
        menuView.cellTextLabelColor = UIColor.gray
        menuView.selectedCellTextLabelColor = UIColor.black
        menuView.cellTextLabelFont = UIFont(name: "Avenir-Heavy", size: 17)
        menuView.cellTextLabelAlignment = .center
        menuView.arrowPadding = 15
        menuView.animationDuration = 0.5
        menuView.maskBackgroundColor = UIColor.black
        menuView.maskBackgroundOpacity = 0.3
        menuView.didSelectItemAtIndexHandler = {(indexPath: Int) -> () in
            if (indexPath == 0) {
                self.category = "city"
                self.loadPosts()
            }
            if (indexPath == 1) {
                self.category = "state"
                self.loadPosts()
            }
            if (indexPath == 2) {
                self.category = "country"
                self.loadPosts()
            }
            if (indexPath == 3) {
                self.category = "world"
                self.loadPosts()
            }
            self.selectedCellLabel.text = radius[indexPath]
            self.loadPosts()
        }
        
        self.navigationItem.titleView = menuView
        
        self.tableView.estimatedRowHeight = 60
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        let width = view.frame.size.width
        let height = view.frame.size.height
        
        let extensionView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: 40))
        extensionView.backgroundColor = UIColor.white
        
        let attr = NSDictionary(object: UIFont(name: "FontAwesome", size: 12.0)!, forKey: NSFontAttributeName as NSCopying)
        UISegmentedControl.appearance().setTitleTextAttributes(attr as? [AnyHashable : Any], for: .normal)
        customSC.frame = CGRect(x: width/4, y: 6.0, width: width/2, height: 28.0)
        customSC.tintColor = UIColor.black
        customSC.selectedSegmentIndex = 0
        extensionView.addSubview(customSC)
        
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: height - 40, width: width, height: 40))
        toolbar.isTranslucent = false
        toolbar.clipsToBounds = true
        view.addSubview(toolbar)
        
        let postButton = UIButton(frame: CGRect(x: 0, y: 0, width: width, height: 40))
        postButton.titleLabel!.font =  UIFont(name: "FontAwesome", size: 20)
        postButton.setTitle("", for: .normal)
        postButton.setTitleColor(UIColor.black, for: .normal)
        postButton.backgroundColor = UIColor.white
        postButton.addTarget(self, action: #selector(makePost), for: .touchUpInside)
        toolbar.addSubview(postButton)
        
        hidingNavBarManager = HidingNavigationBarManager(viewController: self, scrollView: tableView)
        hidingNavBarManager?.manageBottomBar(toolbar)
        hidingNavBarManager?.addExtensionView(extensionView)
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        
        refresher.addTarget(self, action: #selector(self.loadPosts), for: UIControlEvents.valueChanged)
        tableView.addSubview(refresher)
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.longPress))
        self.view.addGestureRecognizer(longPressRecognizer)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hidingNavBarManager?.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let img = UIImage()
        self.navigationController?.navigationBar.shadowImage = img
        self.navigationController?.navigationBar.setBackgroundImage(img, for: UIBarMetrics.default)
        super.viewDidAppear(true)
        loadPosts()
        loadBlocked()
        loadScore()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        hidingNavBarManager?.viewDidLayoutSubviews()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        hidingNavBarManager?.viewWillDisappear(animated)
    }
    
    @IBAction func sortPosts(_ sender: AnyObject) {
        if customSC.selectedSegmentIndex == 0 {
            self.direction = 0
            loadPosts()
        }
        else if customSC.selectedSegmentIndex == 1 {
            self.direction = 1
            loadPosts()
        }
        else if customSC.selectedSegmentIndex == 2 {
            self.direction = 2
            loadPosts()
        }
    }
    
    func loadScore() {
        
        let current = PFUser.current()?.objectId
        let reachability = Reachability()!
        if reachability.currentReachabilityStatus == .notReachable {
            Warning().noConnection()
        }
        else {
            let score = PFQuery(className: "Points")
            score.whereKey("userId", equalTo: current!)
            score.getFirstObjectInBackground { (object: PFObject?, error: Error?) in
                let score = object?.object(forKey: "score")
                self.scoreLabel.text = String(describing: score!)
            }
        }
    }
    
    func loadPosts() {
        
        let reachability = Reachability()!
        if reachability.currentReachabilityStatus == .notReachable {
            Warning().noConnection()
            self.refresher.endRefreshing()
        }
        else {
        
            Database().updateLocation()
            let user = PFUser.current()!
            let equalTo = user.object(forKey: category)!
            let query = PFQuery(className: "Posts")
            query.limit = 100
            query.whereKey(category, equalTo: equalTo)
            
            if self.direction == 0 {
                query.addDescendingOrder("createdAt")
            }
            else if self.direction == 1 {
                query.addDescendingOrder("comments")
            }
            else if self.direction == 2 {
                query.addDescendingOrder("score")
            }
            
            query.findObjectsInBackground (block: { (objects:[PFObject]?, error: Error?) -> Void in
                
                self.imageName.removeAll(keepingCapacity: false)
                self.postID.removeAll(keepingCapacity: false)
                self.text.removeAll(keepingCapacity: false)
                self.place.removeAll(keepingCapacity: false)
                self.comments.removeAll(keepingCapacity:false)
                self.score.removeAll(keepingCapacity: false)
                self.color.removeAll(keepingCapacity: false)
                self.time.removeAll(keepingCapacity: false)
                self.userLike.removeAll(keepingCapacity: false)
                self.userDislike.removeAll(keepingCapacity: false)
                self.originalPoster.removeAll(keepingCapacity: false)
                
                for object in objects! {
                    self.imageName.append(object.value(forKey: "image") as! PFFile)
                    self.postID.append(object.value(forKey: "objectId") as! String)
                    self.text.append(object.value(forKey: "text") as! String)
                    self.place.append(object.value(forKey: "city") as! String)
                    self.comments.append(object.value(forKey: "comments") as! Int)
                    self.score.append(object.value(forKey: "score") as! Int)
                    self.color.append(object.value(forKey: "color") as! Int)
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
    
    func loadBlocked() {
        
        let reachability = Reachability()!
        if reachability.currentReachabilityStatus == .notReachable {
            Warning().noConnection()
            self.refresher.endRefreshing()
        }
        else {
            let query = PFUser.query()
            let currentUser = PFUser.current()?.objectId
            query?.whereKey("objectId", equalTo: currentUser!)
            query?.getFirstObjectInBackground (block: { (objects: PFObject?, error: Error?) -> Void in
                
                self.blocked = objects?.value(forKey: "blocked") as! [String]
                
            })
        }
    }
    
    func longPress(longPressGestureRecognizer: UILongPressGestureRecognizer) {
        
        if longPressGestureRecognizer.state == UIGestureRecognizerState.began {
            
            let longPress = longPressGestureRecognizer as UILongPressGestureRecognizer
            let locationInView = longPress.location(in: tableView)
            var indexPath = tableView.indexPathForRow(at: locationInView)!
            
            if (imageName[indexPath.row].name.contains("aaaaupload.jpg") || imageName[indexPath.row].name.contains("aaaacapture.jpg")) {
                if (imageName[indexPath.row].name.contains("aaaaupload.jpg")) {
                    UniversalVariables.type = "upload"
                    UniversalVariables.imageFile = imageName[indexPath.row]
                    performSegue(withIdentifier: "segueOne", sender: self)
                }
                if (imageName[indexPath.row].name.contains("aaaacapture.jpg")) {
                    UniversalVariables.type = "capture"
                    UniversalVariables.imageFile = imageName[indexPath.row]
                    performSegue(withIdentifier: "segueOne", sender: self)
                }
                else {
                }
            }
            else {
            }
        }
    }
    
    func makePost(sender : UIButton!) {
        UniversalVariables.type = "post"
        present(StoryboardVariables.newpost, animated: true, completion: nil)
    }
    
    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        hidingNavBarManager?.shouldScrollToTop()
        
        return true
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "feedcell", for: indexPath) as! FeedTableViewCell
        let userObjectId = PFUser.current()?.objectId as String?
        let likeContained = self.userLike[indexPath.row].contains(userObjectId!)
        let dislikeContained = self.userDislike[indexPath.row].contains(userObjectId!)
        
        cell.imageLabel.isHidden = true
        
        if blocked.contains(originalPoster[indexPath.row]) {
            
        }
        else {
        }
        
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
        
        if color[indexPath.row] == 1 {
            cell.mainView.backgroundColor = UniversalVariables.blue
        }
        if color[indexPath.row] == 2 {
            cell.mainView.backgroundColor = UniversalVariables.green
        }
        if color[indexPath.row] == 3 {
            cell.mainView.backgroundColor = UniversalVariables.purple
        }
        if color[indexPath.row] == 4 {
            cell.mainView.backgroundColor = UniversalVariables.orange
        }
        if (imageName[indexPath.row].name.contains("aaaaupload.jpg") || imageName[indexPath.row].name.contains("aaaacapture.jpg")) {
            cell.imageLabel.isHidden = false
        }
        else {
        }
        
        let date = time[indexPath.row]
        let now = Date()
        let unitFlags = Set<Calendar.Component>([.second, .minute, .hour, .day])
        let difference = Calendar.current.dateComponents(unitFlags, from: date, to: now)
        
        if (difference.second! <= 0) {
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
        
        cell.downVote.tag = indexPath.row
        cell.originalPoster.text = self.originalPoster[indexPath.row]
        cell.originalPoster.isHidden = true
        cell.postID.text = self.postID[indexPath.row]
        cell.postID.isHidden = true
        cell.postText.text = self.text[indexPath.row]
        cell.postLocation.text = "  " + self.place[indexPath.row]
        cell.commentNumber.text = "  " + "\(self.comments[indexPath.row])"
        cell.postScore.text = String(self.score[indexPath.row])
        
        cell.upVote.tag = indexPath.row
        cell.downVote.tag = indexPath.row
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if blocked.contains(originalPoster[indexPath.row]) {
            return 0
        }
        else {
            return UITableViewAutomaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.text.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let indexPath = tableView.indexPathForSelectedRow!
        let currentCell = tableView.cellForRow(at: indexPath)! as! FeedTableViewCell
        CommentVariables.commentParent = currentCell.postID.text
        
        imageFile = imageName[indexPath.row]
        mainOriginalPoster = currentCell.originalPoster.text
        mainID = currentCell.postID.text
        mainUpVote = currentCell.upVote.alpha
        mainDownVote = currentCell.downVote.alpha
        mainText = currentCell.postText.text
        mainLocation = currentCell.postLocation.text
        mainTime = currentCell.timeSince.text
        mainScore = currentCell.postScore.text
        
        PostVariables.postColor = currentCell.mainView.backgroundColor
        
        performSegue(withIdentifier: "feedToComment", sender: self)
        
    }
    
    func pushVotes(num: Int, user: String, message: String){
        
        let score = [5,10,25,50,100]
        
        if score.contains(num) {
            
            let text = "Your message '" + message + "' has received " +  "\(num)" + " upvotes!"
            
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
        if (segue.identifier == "feedToComment") {
            let viewController = segue.destination as! CommentTableView
            
            viewController.imageFile = imageFile
            viewController.mainOriginalPoster = mainOriginalPoster
            viewController.mainID = mainID
            viewController.mainUpVote = mainUpVote
            viewController.mainDownVote = mainDownVote
            viewController.mainText = mainText
            viewController.mainTime = mainTime
            viewController.mainLocation = mainLocation
            viewController.mainScore = mainScore
            
            if (imageFile.name.contains("aaaaupload.jpg") || imageFile.name.contains("aaaacapture.jpg")) {
                viewController.isImage = true
            }
                
            else {
                viewController.isImage = false
            }
        }
        else if (segue.identifier == "segueOne") {
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
    
    @IBAction func unwind(segue: UIStoryboardSegue) {
    }
    
    @IBAction func feedToProfile(_ sender: AnyObject) {
        present(StoryboardVariables.profile, animated: true, completion: nil)
    }
    
    @IBAction func upVotePressed(sender: AnyObject) {
        
        let buttonTag = sender.tag
        let indexPath = IndexPath(row: buttonTag!, section: 0)
        let currentCell = tableView.cellForRow(at: indexPath)! as! FeedTableViewCell
        let currentPostID = currentCell.postID.text
        let currentPostUserId = currentCell.originalPoster.text
        Database().postUpVoteToDatabase(postId: currentPostID!, userId: currentPostUserId!)
        let scoreOne = Int(currentCell.postScore.text!)
        let scoreTwo = scoreOne! + 1
        currentCell.postScore.text = String(scoreTwo)
        currentCell.upVote.isEnabled = false
        currentCell.upVote.alpha = 0.75
        currentCell.downVote.isEnabled = false
        currentCell.downVote.alpha = 0.25
        
        pushVotes(num: scoreTwo, user: originalPoster[indexPath.row], message: text[indexPath.row])
        
    }
    
    @IBAction func downVotePressed(sender: AnyObject) {
        
        let buttonTag = sender.tag
        let indexPath = IndexPath(row: buttonTag!, section: 0)
        let currentCell = tableView.cellForRow(at: indexPath)! as! FeedTableViewCell
        let currentPostID = currentCell.postID.text
        let currentPostUserId = currentCell.originalPoster.text
        Database().postDownVoteToDatabase(postId: currentPostID!, userId: currentPostUserId!)
        let scoreOne = Int(currentCell.postScore.text!)
        let scoreTwo = scoreOne! - 1
        currentCell.postScore.text = String(scoreTwo)
        currentCell.upVote.isEnabled = false
        currentCell.upVote.alpha = 0.75
        currentCell.downVote.isEnabled = false
        currentCell.downVote.alpha = 0.25
        
    }
}

class FeedTableViewCell : UITableViewCell {
    
    @IBOutlet weak var imageLabel: UILabel!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var postID: UILabel!
    @IBOutlet weak var postText: UILabel!
    @IBOutlet weak var postLocation: UILabel!
    @IBOutlet weak var commentNumber: UILabel!
    @IBOutlet weak var timeSince: UILabel!
    @IBOutlet weak var postScore: UILabel!
    @IBOutlet weak var upVote: UIButton!
    @IBOutlet weak var downVote: UIButton!
    @IBOutlet weak var originalPoster: UILabel!
    
}
