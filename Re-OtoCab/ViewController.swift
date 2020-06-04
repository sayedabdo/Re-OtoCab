//
//  ViewController.swift
//  Re-OtoCab
//
//  Created by Sayed Abdo on 6/4/20.
//  Copyright © 2020 Sayed Abdo. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps
import Alamofire
import SwiftyJSON

class ViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate , UISearchBarDelegate  {
    // place declare params
     var locationManager: CLLocationManager!
     var currentLocation: CLLocation?
    // var mapView: GMSMapView!
     var placesClient: GMSPlacesClient!
     var zoomLevel: Float = 15.0
     @IBOutlet weak var googleMapsContainer: UIView!
     var mapView: GMSMapView!
    // A default location to use when location permission is not granted.
    let defaultLocation = CLLocation(latitude: -33.869405, longitude: 151.199)
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
       locationManager = CLLocationManager()
       locationManager.desiredAccuracy = kCLLocationAccuracyBest
       locationManager.requestAlwaysAuthorization()
       locationManager.distanceFilter = 50
       locationManager.startUpdatingLocation()
       locationManager.delegate = self as CLLocationManagerDelegate
       placesClient = GMSPlacesClient.shared()
       // Create a map.
       let camera = GMSCameraPosition.camera(withLatitude: defaultLocation.coordinate.latitude,
                                             longitude: defaultLocation.coordinate.longitude,
                                             zoom: zoomLevel)
       mapView = GMSMapView.map(withFrame: self.googleMapsContainer.frame, camera: camera)
       mapView.settings.myLocationButton = true
       mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
       mapView.isMyLocationEnabled = true
       self.view.addSubview(self.mapView)
       mapView.delegate = self
    }


}
// get current location
extension ViewController{
    // Handle incoming location events.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
      let location: CLLocation = locations.last!
      print("Location: \(location)")


      let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                            longitude: location.coordinate.longitude,
                                            zoom: zoomLevel)
      //sourceLat = location.coordinate.latitude
      //sourceLng = location.coordinate.longitude
      if mapView.isHidden {
        mapView.isHidden = false
        mapView.camera = camera
      } else {
        mapView.animate(to: camera)
      }
    }
    // Handle authorization for the location manager.
     func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
       switch status {
       case .restricted:
         print("Location access was restricted.")
       case .denied:
         print("User denied access to location.")
         // Display the map using the default location.
         mapView.isHidden = false
       case .notDetermined:
         print("Location status not determined.")
       case .authorizedAlways: fallthrough
       case .authorizedWhenInUse:
         print("Location status is OK.")
       @unknown default:
         fatalError()
       }
     }
     // Handle location manager errors.
     func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
       locationManager.stopUpdatingLocation()
       print("Error: \(error)")
     }
}
// set pin on map
extension ViewController{
    
}
// Ddraw Route
extension ViewController{
    
}
// search on place
extension ViewController{
    
}
