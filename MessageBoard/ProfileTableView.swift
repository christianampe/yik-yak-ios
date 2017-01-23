//
//  ProfileTableView.swift
//  MessageBoard
//
//  Created by Ampe on 10/11/16.
//  Copyright © 2016 Ampe. All rights reserved.
//

import UIKit

class ProfileTableView : UIViewController , UITableViewDelegate , UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var items: [String] = ["My Posts" , "My Replies"]
    
    var navController = UINavigationController()
    var parentNavigationController : UINavigationController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "profilecell")! as UITableViewCell
        
        cell.textLabel?.text = self.items[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let indexPath = tableView.indexPathForSelectedRow!
        
        if indexPath.row == 0 {
            performSegue(withIdentifier: "profileToMyPosts", sender: self)
        }
        
        else if indexPath.row == 1 {
            performSegue(withIdentifier: "profileToMyReplies", sender: self)
        }
        
        else {
            
        }
    }
    
    
    @IBAction func profileToSettings(_ sender: AnyObject) {
        present(StoryboardVariables.settings, animated: true, completion: nil)
    }
    
    
    @IBAction func dismissProfile(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
}
