//
//  AppDelegate.swift
//  LogSampleApp
//
//  Created by Josh Rooke-Ley on 5/8/15. All rights reserved.
//

import UIKit
import Log

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        log.echoToConsole = true
        log.persistToStore = true
        
        let vc = LogController(filters: LogFilter.values())
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window?.rootViewController = UINavigationController(rootViewController: vc)
        window?.makeKeyAndVisible()
        
        MockDataGenerator.generate()
        
        return true
    }


}

