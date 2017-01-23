//
//  ImagePicked.swift
//  MessageBoard
//
//  Created by Ampe on 11/25/16.
//  Copyright © 2016 Ampe. All rights reserved.
//

import UIKit

class ImagePicked: UIViewController {
    
    var image: UIImage?
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        
        if let validImage = self.image {
            self.imageView.image = validImage
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func sendImage(_ sender: Any) {
        let vc = (storyboard?.instantiateViewController(withIdentifier: "captionselected"))! as! CaptionSelected
        let passImage = self.imageView.image
        vc.image = passImage
        present(vc, animated: false, completion: nil)
    }
    
    @IBAction func dismiss(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }
}

