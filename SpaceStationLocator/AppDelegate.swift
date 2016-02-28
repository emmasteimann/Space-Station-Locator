//
//  AppDelegate.swift
//  SpaceStationLocator
//
//  Created by Emma Steimann on 2/27/16.
//  Copyright © 2016 Emma Steimann. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?


  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [.Sound, .Alert], categories: nil))
    return true
  }

}

