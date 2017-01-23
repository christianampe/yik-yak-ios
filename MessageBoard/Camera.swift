//
//  Camera.swift
//  Scoop
//
//  Created by Ampe on 1/23/17.
//  Copyright © 2017 Ampe. All rights reserved.
//

import UIKit
import CameraManager

class Camera : UIViewController , UIImagePickerControllerDelegate , UINavigationControllerDelegate {
    
    @IBOutlet weak var cameraView: UIImageView!
    let cameraManager = CameraManager()
    
    @IBOutlet weak var cameraPreview: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cameraManager.showAccessPermissionPopupAutomatically = true
        cameraManager.cameraDevice = .front
        cameraManager.cameraOutputMode = .stillImage
        cameraManager.cameraOutputQuality = .high
        cameraManager.writeFilesToPhoneLibrary = false
        cameraManager.addPreviewLayerToView(cameraPreview)
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        dismiss(animated:true, completion: nil)
        let vc: ImagePicked? = self.storyboard?.instantiateViewController(withIdentifier: "imagepicked") as? ImagePicked
        vc?.image = chosenImage
        present(vc!, animated: false, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func captureImage(_ sender: Any) {
        
        cameraManager.capturePictureWithCompletion({ (image, error) -> Void in
            
            let vc: ImageViewController? = self.storyboard?.instantiateViewController(withIdentifier: "ImageVC") as? ImageViewController
            if let validVC: ImageViewController = vc {
                if image != nil {
                    if (self.cameraManager.cameraDevice == .front) {
                        let flippedImage = UIImage(cgImage: (image?.cgImage)!, scale: 1.0, orientation: .leftMirrored)
                        validVC.image = flippedImage
                        self.present(validVC, animated: false, completion: nil)
                    }
                    else if (self.cameraManager.cameraDevice == .back) {
                        let flippedImage = image
                        validVC.image = flippedImage
                        self.present(validVC, animated: false, completion: nil)
                    }
                }
            }
        })
    }
    
    @IBAction func toggleFlash(_ sender: Any) {
        switch (cameraManager.changeFlashMode()) {
        case .off: break
        case .on: break
        case .auto: break
        }
    }
    
    @IBAction func FRToggle(_ sender: Any) {
        cameraManager.cameraDevice = cameraManager.cameraDevice == CameraDevice.front ? CameraDevice.back : CameraDevice.front
        switch (cameraManager.cameraDevice) {
        case .front: break
        case .back: break
        }
    }
    
    @IBAction func uploadPhoto(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary;
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func closeCamera(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
