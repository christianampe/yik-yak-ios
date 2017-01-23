//
//  SettingsTableView.swift
//  MessageBoard
//
//  Created by Ampe on 10/23/16.
//  Copyright © 2016 Ampe. All rights reserved.
//

import UIKit

class SettingsTableView : UIViewController , UITableViewDelegate , UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var items: [String] = ["Support" , "Privacy Policy" , "Terms of Service" , "Licenses"]
    
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
        
        let cell : UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "settingscell")! as UITableViewCell
        
        cell.textLabel?.text = self.items[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let indexPath = tableView.indexPathForSelectedRow!
        
        if indexPath.row == 0 {
            performSegue(withIdentifier: "settingsToSupport", sender: self)
        }
        
        else if indexPath.row == 1 {
            performSegue(withIdentifier: "settingsToPrivacy", sender: self)
        }
        
        else if indexPath.row == 2 {
            performSegue(withIdentifier: "settingsToTOS", sender: self)
        }
        
        else if indexPath.row == 3 {
            performSegue(withIdentifier: "settingsToLicenses", sender: self)
        }
            
        else { 
        }
        
    }
    
    @IBAction func dismissSettings(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
}

