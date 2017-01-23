//
//  AppDelegate.swift
//  MessageBoard
//
//  Created by Ampe on 10/9/16.
//  Copyright © 2016 Ampe. All rights reserved.
//

import UIKit
import UserNotifications
import Parse

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        let configuration = ParseClientConfiguration {
            $0.applicationId = "Mjr3unPz90EtOSTUy7j4WcJLaXaaF8TJvt9aIHws"
            $0.clientKey = "rleoMOLDHYsTSCzQFVwxcg35lsgH0SlsIIJe17U2"
            $0.server = "https://parseapi.back4app.com"
        }
        Parse.enableLocalDatastore()
        Parse.initialize(with: configuration)
        
        PFUser.current()?.fetchInBackground()
        
        if PFUser.current() == nil {
            PFUser.enableAutomaticUser()
            PFUser.current()?.incrementKey("RunCount")
            PFUser.current()?["accessGranted"] = false
            PFUser.current()?.saveInBackground()
            Database().getLocation()
            self.window = UIWindow(frame: UIScreen.main.bounds)
            self.window?.rootViewController = StoryboardVariables.agree
            self.window?.makeKeyAndVisible()
        }
            
        else {
            let access = PFUser.current()!["accessGranted"] as! Bool
            
            if (access != true) {
                self.window = UIWindow(frame: UIScreen.main.bounds)
                self.window?.rootViewController = StoryboardVariables.agree
                self.window?.makeKeyAndVisible()
                
            }
                
            else {
                Database().updateLocation()
                self.window = UIWindow(frame: UIScreen.main.bounds)
                self.window?.rootViewController = StoryboardVariables.feed
                self.window?.makeKeyAndVisible()
            }
        }
        
        return true
    }
    
    func moveToRoot() {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = StoryboardVariables.feed
        self.window?.makeKeyAndVisible()
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        clearBadges()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options:[.badge, .alert, .sound]) { (granted, error) in
            }
            application.registerForRemoteNotifications()
            
        }
        else {
        }
        
        return true
        
    }
    
    func incrementBadgeNumberBy(badgeNumberIncrement: Int) {
        let currentBadgeNumber = UIApplication.shared.applicationIconBadgeNumber
        let updatedBadgeNumber = currentBadgeNumber + badgeNumberIncrement
        if (updatedBadgeNumber > -1) {
            UIApplication.shared.applicationIconBadgeNumber = updatedBadgeNumber
        }
    }
    
    func clearBadges() {
        let installation = PFInstallation.current()
        installation?.badge = 0
        installation?.saveInBackground { (success, error) -> Void in
            if success {
                UIApplication.shared.applicationIconBadgeNumber = 0
            }
            else {
            }
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        let installation = PFInstallation.current()
        installation?["user"] = PFUser.current()
        installation?.setDeviceTokenFrom(deviceToken)
        installation?.saveInBackground()
        
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if let aps = userInfo["aps"] as? NSDictionary {
            if let message = aps["alert"] as? String {
                Warning().newPost(message: message)
            }
            if let badge = aps["badge"] as? NSInteger {
                incrementBadgeNumberBy(badgeNumberIncrement: badge)
            }
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        
    }
}

