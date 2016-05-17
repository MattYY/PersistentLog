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
        
        
        
        log.error("YO")
        
        /*
        App.logStore.echoToConsole = true
        
        //App.logStore.setMinimumLogLevel(.Info)
        //App.logStore.exclude([App.LogFilter.Kiwi.rawValue])
        
        App.log.debug(.Apple, "Eat an apple a day.")
        App.log.info(.Orange, "Oranges are delicious.")
        App.log.warn(.Bannana, "Bannana have potassium.")
        App.log.error(.Kiwi, "Kiwi's are not delicious.")
        
        let vc = FSLLog.LogController(log: App.logStore, filters: App.LogFilter.values())
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window?.rootViewController = UINavigationController(rootViewController: vc)
        window?.makeKeyAndVisible()
        */
 
 
        var counter = 0
        let queue1 = dispatch_queue_create("AppTestQueue", nil)
        //let queue2 = dispatch_queue_create("AppTestQueue", nil)
        dispatch_async(queue1) {
            while true {
                sleep(3)
                counter += 1
                
                log.network("endpoint: http://test.com, data: { id: 876GSADF }", response: "{ token: q03987qwe0q98we7asdfpoi }")
            }
        }
        
//        dispatch_async(queue2) {
//            while true {
//                sleep(1)
//                counter += 1
//                log.info("Ate an orange. Fruit count: \(counter)", filter: LogFilter.Orange.rawValue)
//            }
//        }
        
        return true
    }


}

