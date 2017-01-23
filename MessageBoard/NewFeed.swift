//
//  NewPost.swift
//  MessageBoard
//
//  Created by Ampe on 10/11/16.
//  Copyright © 2016 Ampe. All rights reserved.


import UIKit
import ReachabilitySwift
import Parse

class NewPost : UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var nameTextView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var keyboardView: UIView!
    @IBOutlet weak var cameraButton: UIButton!
    
    let PLACEHOLDER_TEXT = "Send a message"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Database().updateLocation()
        self.view.backgroundColor = UniversalVariables.blue
        nameTextView.tintColor = UIColor.white
        
        nameTextView.inputAccessoryView = keyboardView
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        nameTextView.becomeFirstResponder()
        nameTextView.text = ""
        applyPlaceholderStyle(aTextview: nameTextView!, placeholderText: PLACEHOLDER_TEXT)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
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
            PostVariables.postCity = PostVariables.postAddress?.addressDictionary!["City"] as? String
            PostVariables.postState = PostVariables.postAddress?.addressDictionary!["State"] as? String
            PostVariables.postCountry = PostVariables.postAddress?.addressDictionary!["Country"] as? String
            
            Database().postToDatabase(image : image!, imageName: "aaaaempty.png", text: nameTextView.text, location: PostVariables.postLocation!, city: PostVariables.postCity!, state: PostVariables.postState!, country: PostVariables.postCountry!)
            
            nameTextView.resignFirstResponder()
            dismiss(animated: true, completion: nil)
            
            var pushId = [String]()
            let query = PFQuery(className: "_User")
            query.limit = 100
            query.whereKey("city", equalTo: PostVariables.postCity!)
            
            query.findObjectsInBackground (block: { (objects:[PFObject]?, error: Error?) -> Void in
                
                pushId.removeAll(keepingCapacity: false)
                
                for object in objects! {
                    
                    pushId.append(object.value(forKey: "objectId") as! String)
                    
                }
                
                let unique = Array(Set(pushId))
                
                for i in unique {
                    
                    if i != PFUser.current()?.objectId {
                        
                        let text = "Someone posted near you!"
                        
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
            })
        }
    }
    
    @IBAction func goToCamera(_ sender: Any) {
        let camera = self.storyboard?.instantiateViewController(withIdentifier: "camera") as? Camera
        present(camera!, animated: true, completion: nil)
    }
}
