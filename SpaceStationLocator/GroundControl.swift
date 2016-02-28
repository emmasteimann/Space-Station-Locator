//
//  GroundControl.swift
//  SpaceStationLocator
//
//  Created by Emma Steimann on 2/27/16.
//  Copyright © 2016 Emma Steimann. All rights reserved.
//

import UIKit
import CoreLocation

protocol GroundControlProtocol {
  func didUpdateSpaceStationLocation(coordinates:CLLocationCoordinate2D)
  func didUpdateNextPass(date:NSDate)
}

class GroundControl {
  var delegate:GroundControlProtocol?
  let notificationManager = NotificationManager()
  
  let OpenNotifyNowURLString:String = "http://api.open-notify.org/iss-now.json"
  let OpenNotifyPassURLString:String = "http://api.open-notify.org/iss-pass.json"
  
  private var q = dispatch_queue_create("timer",nil)
  private var timer : dispatch_source_t!
  
  let config:NSURLSessionConfiguration
  let session:NSURLSession
  
  init() {
    config = NSURLSessionConfiguration.defaultSessionConfiguration()
    session = NSURLSession(configuration: self.config)
  }
  
  func getSpaceStationLocation() {
    let url = NSURL(string: OpenNotifyNowURLString)!
    let request = NSURLRequest(URL: url)
    groundControlToMajorTom(request, completionHandler: {(data:NSDictionary!) in
      if let responseData = data as? [String:AnyObject] {
        if responseData["message"] as? String == "success" {
          if let iss_position = responseData["iss_position"] as? [String:AnyObject] {
            let latitude = iss_position["latitude"]
            let longitude = iss_position["longitude"]
            let currentISSPosition = CLLocationCoordinate2DMake((latitude?.doubleValue)!, (longitude?.doubleValue)!)
            dispatch_async(dispatch_get_main_queue(), {
              self.delegate?.didUpdateSpaceStationLocation(currentISSPosition)
            })
          }
        }
      }
    })
  }
  
  func getNextISSPass(coordinates: CLLocationCoordinate2D) {
    let nextPassString = "\(OpenNotifyPassURLString)?lat=\(coordinates.latitude)&lon=\(coordinates.longitude)"
    let url = NSURL(string: nextPassString)!
    let request = NSURLRequest(URL: url)
    groundControlToMajorTom(request, completionHandler: {(data:NSDictionary!) in
      if let responseData = data as? [String:AnyObject] {
        if responseData["message"] as? String == "success" {
          if let response = responseData["response"] as? [AnyObject] {
            if let nextPass = response.first as? [String:AnyObject] {
              let date = NSDate(timeIntervalSince1970: nextPass["risetime"] as! Double)
              dispatch_async(dispatch_get_main_queue(), {
                self.notificationManager.scheduleNotifications(date)
                self.delegate?.didUpdateNextPass(date)
              })
            }
          }
        }
      }
    })
  }
  
  func groundControlToMajorTom(urlRequest:NSURLRequest, completionHandler: (data: NSDictionary!) -> ()) -> Void {
    let task = session.dataTaskWithRequest(urlRequest, completionHandler: {(data, response, error) in
      guard let _:NSData = data, let _:NSURLResponse = response where error == nil else {
        return
      }
      
      let httpResponse = response as? NSHTTPURLResponse
      if let httpResponse = httpResponse {
        if httpResponse.statusCode == 200 {
          do {
            let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
            completionHandler(data: json as! NSDictionary)
            return
          } catch {
            print("error serializing JSON: \(error)")
          }
        } else {
          print("Bad response...")
        }
      } else {
        print("\(error?.localizedDescription)")
      }
      completionHandler(data: nil)
    })
    
    task.resume()
  }
  
  func pollOpenNotifyAtInterval(interval:Double) {
    cancel()
    timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, self.q)
    
    dispatch_source_set_timer(self.timer, dispatch_walltime(nil, 0), UInt64(interval * Double(NSEC_PER_SEC)), UInt64(0.05 * Double(NSEC_PER_SEC)))
    
    dispatch_source_set_event_handler(self.timer, { () in
      self.getSpaceStationLocation()
    })
      
    dispatch_resume(timer)
  }

  func cancel() {
    if self.timer != nil {
      dispatch_source_cancel(timer)
    }
  }
}
