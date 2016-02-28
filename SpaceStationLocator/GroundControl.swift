//
//  GroundControl.swift
//  SpaceStationLocator
//
//  Created by Emma Steimann on 2/27/16.
//  Copyright © 2016 Emma Steimann. All rights reserved.
//

import UIKit
import CoreLocation

class GroundControl {
  
  let OpenNotifyURLString:String = "http://api.open-notify.org/iss-now.json"
  
  private var q = dispatch_queue_create("timer",nil)
  private var timer : dispatch_source_t!
  
  func getSpaceStationLocation() -> Void {
    print("getting ISS location")
    let url = NSURL(string: OpenNotifyURLString)
    let request = NSURLRequest(URL: url!)
    let config = NSURLSessionConfiguration.defaultSessionConfiguration()
    let session = NSURLSession(configuration: config)
    
    let task = session.dataTaskWithRequest(request, completionHandler: {(data, response, error) in
      guard let _:NSData = data, let _:NSURLResponse = response where error == nil else {
        print("error")
        return
      }
      
      let httpResponse = response as? NSHTTPURLResponse
      if let httpResponse = httpResponse {
        if httpResponse.statusCode == 200 {
          do {
            let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
            print("\(json)")
          } catch {
            print("error serializing JSON: \(error)")
          }
        } else {
          print("the heck...")
        }
      } else {
        print("\(error?.localizedDescription)")
      }
    });
    
    task.resume()
  }
  
  func pollOpenNotifyAtInterval(interval:Double) {
    self.cancel()
    weak var weakSelf:GroundControl? = self
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, self.q)
    
    dispatch_source_set_timer(self.timer, dispatch_walltime(nil, 0), UInt64(interval * Double(NSEC_PER_SEC)), UInt64(0.05 * Double(NSEC_PER_SEC)))
    
    dispatch_source_set_event_handler(self.timer, {
      self.getSpaceStationLocation()
    })
      
    dispatch_resume(self.timer)
  }
  
  func cancel() {
    if self.timer != nil {
      dispatch_source_cancel(timer)
    }
  }
}
