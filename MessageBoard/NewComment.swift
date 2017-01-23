//
//  NewComment.swift
//  MessageBoard
//
//  Created by Ampe on 10/12/16.
//  Copyright © 2016 Ampe. All rights reserved.


import UIKit
import ReachabilitySwift
import Parse

class NewComment : UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var nameTextView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet var keyboardView: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    
    let PLACEHOLDER_TEXT = "Respond to the message"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Database().updateLocation()
        self.view.backgroundColor = UniversalVariables.blue
        applyPlaceholderStyle(aTextview: nameTextView!, placeholderText: PLACEHOLDER_TEXT)
        nameTextView.tintColor = UIColor.white
        nameTextView.inputAccessoryView = keyboardView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        nameTextView.becomeFirstResponder()
        nameTextView.text = ""
        applyPlaceholderStyle(aTextview: nameTextView!, placeholderText: PLACEHOLDER_TEXT)
    }
    
    func applyPlaceholderStyle(aTextview: UITextView, placeholderText: String) {
        
        aTextview.textColor = UIColor.lightText
        aTextview.text = placeholderText
    }
    
    func applyNonPlaceholderStyle(aTextview: UITextView) {
        
        aTextview.textColor = UIColor.white
        aTextview.tintColor = UIColor.white
        aTextview.alpha = 1.0
    }
    
    func moveCursorToStart(aTextView: UITextView) {
        DispatchQueue.main.async {
            aTextView.selectedRange = NSMakeRange(0, 0);
        }
    }
    
    func textViewShouldBeginEditing(_ aTextView: UITextView) -> Bool {
        if aTextView == nameTextView && aTextView.text == PLACEHOLDER_TEXT {
            
            moveCursorToStart(aTextView: aTextView)
        }
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let newLength = textView.text.utf16.count + text.utf16.count - range.length
        if newLength > 0 {
            
            if textView == nameTextView && textView.text == PLACEHOLDER_TEXT {
                if text.utf16.count == 0 {
                    return false
                }
                applyNonPlaceholderStyle(aTextview: textView)
                textView.text = ""
            }
            
            return true
        }
        else {
            applyPlaceholderStyle(aTextview: textView, placeholderText: PLACEHOLDER_TEXT)
            moveCursorToStart(aTextView: textView)
            return false
        }
    }
    
    @IBAction func cancelPost(_ sender: AnyObject) {
        nameTextView.resignFirstResponder()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sendPost(_ sender: AnyObject) {
        let reachability = Reachability()!
        let image = UIImage(named: "empty.png")
        if reachability.currentReachabilityStatus == .notReachable {
            Warning().noConnection()
        }
        else {
            
            CommentVariables.commentCity = PostVariables.postAddress?.addressDictionary!["City"] as? String
            CommentVariables.commentState = PostVariables.postAddress?.addressDictionary!["State"] as? String
            CommentVariables.commentCountry = PostVariables.postAddress?.addressDictionary!["Country"] as? String
            
            Database().commentToDatabase(image: image!, imageName: "aaaaempty.png", parent: CommentVariables.commentParent!, text: nameTextView.text, location: CommentVariables.commentLocation!, city: CommentVariables.commentCity!, state: CommentVariables.commentState!, country: CommentVariables.commentCountry!)
            
            nameTextView.resignFirstResponder()
            dismiss(animated: true, completion: nil)
            
            let originalPosterId = UniversalVariables.originalPosterId
            let originalText = UniversalVariables.originalText
            
            if originalPosterId != PFUser.current()?.objectId {
                
                let text = "Your post '" + originalText! +  "' received a new comment!"
                
                let data = [
                    "badge" : "Increment",
                    "alert" : text,
                    ]
                let request = [
                    "someKey" : originalPosterId!,
                    "data" : data
                    ] as [String : Any]
                
                PFCloud.callFunction(inBackground: "push", withParameters: request)
                
                let commentId = UniversalVariables.allCommentId
                let filteredId = commentId?.filter{$0 != originalPosterId}
                let unique = Array(Set(filteredId!))
                
                for i in unique {
                    
                    if (i != PFUser.current()?.objectId || i != originalPosterId) {
                        
                        let text = "Someone else replied to the post '" + originalText! + "'!"
                        
                        let data = [
                            "badge" : "Increment",
                            "alert" : text,
                            ]
                        let request = [
                            "someKey" : i,
                            "data" : data
                            ] as [String : Any]
                        
                        PFCloud.callFunction(inBackground: "push", withParameters: request)
                    }
                }
            }
        }
    }
    
    @IBAction func goToCamera(_ sender: Any) {
        let camera = self.storyboard?.instantiateViewController(withIdentifier: "camera") as? Camera
        present(camera!, animated: true, completion: nil)
    }
}

