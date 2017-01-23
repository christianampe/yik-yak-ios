//
//  ImageViewController.swift
//  camera
//
//  Created by Natalia Terlecka on 13/01/15.
//  Copyright (c) 2015 imaginaryCloud. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController {
    
    var image: UIImage?
    @IBOutlet weak var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true

        if let validImage = self.image {
            self.imageView.image = validImage
            self.imageView.clipsToBounds = true
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func sendImage(_ sender: Any) {
        let vc = (storyboard?.instantiateViewController(withIdentifier: "captionimage"))! as! CaptionImage
        let passImage = self.imageView.image
        vc.image = passImage
        present(vc, animated: false, completion: nil)
    }

    @IBAction func dismiss(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }
}
