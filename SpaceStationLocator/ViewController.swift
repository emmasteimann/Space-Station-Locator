//
//  ViewController.swift
//  SpaceStationLocator
//
//  Created by Emma Steimann on 2/27/16.
//  Copyright © 2016 Emma Steimann. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    let gc = GroundControl()
    gc.getSpaceStationLocation()
    gc.pollOpenNotifyAtInterval(1)
  }

}

