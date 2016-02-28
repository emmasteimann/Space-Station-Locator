//
//  NotificationManager.swift
//  SpaceStationLocator
//
//  Created by Emma Steimann on 2/28/16.
//  Copyright © 2016 Emma Steimann. All rights reserved.
//

import UIKit

class NotificationManager {
  func scheduleNotifications(date:NSDate) {
    
    for localNotification in UIApplication.sharedApplication().scheduledLocalNotifications! {
      let oldDate = localNotification.fireDate?.compare(date)
      if oldDate == NSComparisonResult.OrderedSame {
        return
      }
    }
    
    let newNotification = UILocalNotification()
    newNotification.fireDate = date
    newNotification.alertBody = "Space Station is Overhead!"
    newNotification.timeZone = NSTimeZone.defaultTimeZone()
    newNotification.applicationIconBadgeNumber = UIApplication.sharedApplication().applicationIconBadgeNumber + 1
    UIApplication.sharedApplication().scheduleLocalNotification(newNotification)
    
  }
}