//
//  Utility.swift
//  MessageBoard
//
//  Created by Ampe on 10/20/16.
//  Copyright © 2016 Ampe. All rights reserved.
//


import SwiftMessages

class Warning {
    
    func noConnection() {
        let status = MessageView.viewFromNib(layout: .StatusLine)
        status.backgroundView.backgroundColor = UIColor.red
        status.bodyLabel?.textColor = UIColor.white
        status.configureContent(body: "no internet connection")
        var statusConfig = SwiftMessages.Config()
        statusConfig.duration = .seconds(seconds: 3.0)
        statusConfig.presentationContext = .window(windowLevel: UIWindowLevelStatusBar)
        SwiftMessages.show(config: statusConfig, view: status)
    }
    
    func newPost(message : String) {
        let status = MessageView.viewFromNib(layout: .CardView)
        var config = SwiftMessages.Config()
        config.presentationStyle = .bottom
        config.dimMode = .gray(interactive: true)
        config.duration = .seconds(seconds: 3.0)
        
        status.configureTheme(.success)
        status.button?.isHidden = true
        status.backgroundView.backgroundColor = UniversalVariables.blue
        status.bodyLabel?.textColor = UIColor.white
        
        let iconText = ["🤔", "😳", "😎", "😶", "🤗", "❤️"].sm_random()!
        status.configureContent(title: "Awesome!", body: message, iconImage: nil, iconText: iconText, buttonImage: nil, buttonTitle: nil, buttonTapHandler: nil)
        
        SwiftMessages.show(config: config, view: status)
    }
}
