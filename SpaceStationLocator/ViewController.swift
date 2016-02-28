//
//  ViewController.swift
//  SpaceStationLocator
//
//  Created by Emma Steimann on 2/27/16.
//  Copyright © 2016 Emma Steimann. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, GroundControlProtocol {
  let locationManager = CLLocationManager()
  let gc = GroundControl()
  var spaceStation:SpaceStationAnnotation?
  
  var spaceStationCoordinates = CLLocationCoordinate2D()
  
  @IBOutlet weak var mapView: MKMapView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    gc.delegate = self
    
    title = "Loading next pass information..."
    
    if (CLLocationManager.locationServicesEnabled()) {
      locationManager.delegate = self
      locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
      locationManager.requestAlwaysAuthorization()
      locationManager.startUpdatingLocation()
    }
    
  }
  
  func loadMapView() {
    spaceStation = SpaceStationAnnotation(coordinate: spaceStationCoordinates, identifier: "ISS")
    mapView.addAnnotation(spaceStation!)
    setMapRegionForCoordinates((locationManager.location?.coordinate)!)
    
    mapView.delegate = self
    gc.getSpaceStationLocation()
    gc.pollOpenNotifyAtInterval(3)
  }
  
  func setMapRegionForCoordinates(coordinates:CLLocationCoordinate2D) {
    let locObj:CLLocation = CLLocation(coordinate: coordinates, altitude: 0, horizontalAccuracy: 0, verticalAccuracy: 0, timestamp: NSDate())
    
    let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    let region = MKCoordinateRegion(center: locObj.coordinate, span: span)
    
    mapView.setRegion(region, animated: true)
  }
  
  func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    gc.getNextISSPass((locations.first?.coordinate)!)
  }
  
  func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
    if (status == .AuthorizedAlways) {
      gc.getNextISSPass((locationManager.location?.coordinate)!)
      loadMapView()
      mapView.showsUserLocation = true
    }
  }
  
  func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
    let identifier = "issIdentifier"
    if annotation is SpaceStationAnnotation {
      var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
      if annotationView == nil {
        annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        annotationView!.enabled = true
        annotationView!.image = UIImage(named: "deathstar.png")
        
      } else {
        annotationView!.annotation = annotation
      }
      return annotationView
    }
    return nil
  }
  
  func didUpdateSpaceStationLocation(coordinates:CLLocationCoordinate2D) {
    mapView.removeAnnotation(self.spaceStation!)
    self.spaceStation!.coordinate = coordinates
    mapView.addAnnotation(self.spaceStation!)
    mapView.setCenterCoordinate(coordinates, animated: true)
  }
  
  func didUpdateNextPass(date: NSDate) {
    let dateFormatter = NSDateFormatter()
    let theDateFormat = NSDateFormatterStyle.ShortStyle
    let theTimeFormat = NSDateFormatterStyle.ShortStyle
    
    dateFormatter.dateStyle = theDateFormat
    dateFormatter.timeStyle = theTimeFormat
    self.title = "Next Pass Over You: \(dateFormatter.stringFromDate(date))"
  }
  
  func coordinate() -> CLLocationCoordinate2D {
    return spaceStationCoordinates
  }
}

