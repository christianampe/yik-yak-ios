//
//  Agree.swift
//  MessageBoard
//
//  Created by Ampe on 10/15/16.
//  Copyright © 2016 Ampe. All rights reserved.
//

import UIKit
import ReachabilitySwift


class Agree : UIViewController {
    
    @IBOutlet weak var agreeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func agreeButtonPressed(_ sender: AnyObject) {
        let reachability = Reachability()!
        if reachability.currentReachabilityStatus == .notReachable {
            Warning().noConnection()
        }
        else {
            Database().grantAccess()
            let appDelegte : AppDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegte.moveToRoot()
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
