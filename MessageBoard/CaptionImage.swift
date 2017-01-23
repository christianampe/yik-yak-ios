//
//  CaptionImage.swift
//  MessageBoard
//
//  Created by Ampe on 11/26/16.
//  Copyright © 2016 Ampe. All rights reserved.


import UIKit
import ReachabilitySwift
import Parse

class CaptionImage : UIViewController, UITextFieldDelegate {
    
    var image : UIImage?
    
    @IBOutlet var keyboardView: UIView!
    @IBOutlet weak var captionImage: UIImageView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var post: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var glitch: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Database().updateLocation()
        self.view.backgroundColor = UIColor.black
        glitch.isHidden = true
        glitch.inputAccessoryView = keyboardView
        glitch.becomeFirstResponder()
        captionImage.image = image
        textField.keyboardAppearance = .dark
        glitch.keyboardAppearance = .dark
    }
    
    override func viewWillAppear(_ animated: Bool) {
        glitch.becomeFirstResponder()
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func cancelPost(_ sender: AnyObject) {
        textField.resignFirstResponder()
        dismiss(animated: false, completion: nil)
    }
    
    @IBAction func sendPost(_ sender: AnyObject) {
        let reachability = Reachability()!
        if reachability.currentReachabilityStatus == .notReachable {
            Warning().noConnection()
        }
        else
        if (UniversalVariables.type == "post") {
            PostVariables.postCity = PostVariables.postAddress?.addressDictionary!["City"] as? String
            PostVariables.postState = PostVariables.postAddress?.addressDictionary!["State"] as? String
            PostVariables.postCountry = PostVariables.postAddress?.addressDictionary!["Country"] as? String
            
            Database().postToDatabase(image: image!, imageName: "aaaacapture.jpg", text: textField.text!, location: PostVariables.postLocation!, city: PostVariables.postCity!, state: PostVariables.postState!, country: PostVariables.postCountry!)
            textField.resignFirstResponder()
            self.performSegue(withIdentifier: "unwindcaptured", sender: self)
        }
        else if (UniversalVariables.type == "comment") {
            CommentVariables.commentCity = PostVariables.postAddress?.addressDictionary!["City"] as? String
            CommentVariables.commentState = PostVariables.postAddress?.addressDictionary!["State"] as? String
            CommentVariables.commentCountry = PostVariables.postAddress?.addressDictionary!["Country"] as? String
            
            Database().commentToDatabase(image: image!, imageName: "aaaacapture.jpg", parent: CommentVariables.commentParent!, text: textField.text!, location: CommentVariables.commentLocation!, city: CommentVariables.commentCity!, state: CommentVariables.commentState!, country: CommentVariables.commentCountry!)
            textField.resignFirstResponder()
            self.performSegue(withIdentifier: "unwindcaptured", sender: self)

        }
        else {
        }
    }
}
