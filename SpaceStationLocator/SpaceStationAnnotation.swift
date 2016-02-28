//
//  SpaceStationAnnotation.swift
//  SpaceStationLocator
//
//  Created by Emma Steimann on 2/28/16.
//  Copyright © 2016 Emma Steimann. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class SpaceStationAnnotation: NSObject, MKAnnotation {
  var coordinate: CLLocationCoordinate2D
  var identifier: String
  
  init(coordinate: CLLocationCoordinate2D, identifier: String) {
    self.coordinate = coordinate
    self.identifier = identifier
  }
  
}