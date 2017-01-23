//
//  Image.swift
//  MessageBoard
//
//  Created by Ampe on 11/19/16.
//  Copyright © 2016 Ampe. All rights reserved.
//

import UIKit
import Kingfisher
import Parse

class Image : UIViewController {
    
    var imageFile : PFFile!
    var type : String!
    
    @IBOutlet weak var image: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        type = UniversalVariables.type
        imageFile = UniversalVariables.imageFile
        
        if (type == "capture") {
            image.contentMode = .scaleAspectFill
        }
        if (type == "upload") {
            image.contentMode = .scaleAspectFit
        }
        else {
        }
        
        let remoteImageUrlString = self.imageFile.url
        let theURL = URL(string:remoteImageUrlString!)
        image.kf.setImage(with: theURL)

    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    @IBAction func returnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
