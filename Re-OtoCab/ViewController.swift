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

class ViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate , UISearchBarDelegate ,GMSAutocompleteResultsViewControllerDelegate {
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
    
    // MARK: Define the source latitude and longitude
       var sourceLat : Double = 0.0
       var sourceLng : Double = 0.0
    // MARK: Define the destination latitude and longitude
       var destinationLat : Double = 0.0
       var destinationLng : Double = 0.0
       var selectedDestination : Bool = false
    //search result
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    var resultView: UITextView?
    
    
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
        
        
        // searching
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        // Put the search bar in the navigation bar.
        searchController?.searchBar.sizeToFit()
        navigationItem.titleView = searchController?.searchBar
        // When UISearchController presents the results view, present it in
        // this view controller, not one further up the chain.
        definesPresentationContext = true
        // Prevent the navigation bar from being hidden when searching.
        searchController?.hidesNavigationBarDuringPresentation = false
    }

    @IBAction func showDirection(_ sender: Any) {
        if selectedDestination == true{
           // drawRoute(sourceLat: sourceLat, sourceLng: sourceLng, destinationLat: destinationLat, destinationLng: destinationLng)
          //  let alert = UIAlertController(title: "urgent !!😱😱", message: "Your Soure Location is \(sourceLat) , \(sourceLng).\n Your destination Location is \(destinationLat) , \(destinationLng).\n but , You must  Billing on the Google to drawRoute 😉", preferredStyle: .alert)
         //   alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
         //   }))

         //   self.present(alert, animated: true, completion: nil)
            
            drawPath()
        }else{
            let alert = UIAlertController(title: "Sorry !!😱😱", message: "please🙏 , select your distination 😉", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            }))

            self.present(alert, animated: true, completion: nil)
        }
                drawPath()
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
      sourceLat = location.coordinate.latitude
      sourceLng = location.coordinate.longitude
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
    // MARK: function for create a marker pin on map
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D){
       print("You tapped at \(coordinate.latitude), \(coordinate.longitude)")
      // destination = "\(coordinate.latitude),\(coordinate.longitude)"
       destinationLat =  coordinate.latitude
       destinationLng =  coordinate.longitude
       mapView.clear() // clearing Pin before adding new
       let marker = GMSMarker(position: coordinate)
       marker.title = "Your Destination"
       marker.map = mapView
       selectedDestination = true
    }
}
// Ddraw Route
extension ViewController{
    func drawPath() {
        let origin = "\(sourceLat),\(sourceLng)"
        let destination = "\(destinationLat),\(destinationLng)"
       let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=driving"
       AF.request(url).responseJSON { (reseponse) in
                    guard let data = reseponse.data else {
                        return
                    }
                    do {
                        let jsonData = try JSON(data: data)
                        print(jsonData)
                        let routes = jsonData["routes"].arrayValue

                        for route in routes {
                            let overview_polyline = route["overview_polyline"].dictionary
                            let points = overview_polyline?["points"]?.string
                            let path = GMSPath.init(fromEncodedPath: points ?? "")
                            let polyline = GMSPolyline.init(path: path)
                            polyline.strokeColor = .systemBlue
                            polyline.strokeWidth = 5
                            polyline.map = self.mapView
                        }
                    }
                     catch let error {
                        print(error.localizedDescription)
                    }
            }
    }
    
}
// search on place
extension ViewController{
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                            didAutocompleteWith place: GMSPlace) {
       searchController?.isActive = false
       // Do something with the selected place.
       print("Place name: \(place.name)")
       print("Place address: \(place.formattedAddress)")
       print("Place latitude: \(place.coordinate.latitude)")
       print("Place longitude: \(place.coordinate.longitude)")
        let location = GMSCameraPosition.camera(withLatitude: place.coordinate.latitude, longitude: place.coordinate.longitude, zoom: 17.0)
      //  let location = GMSCameraPosition.camera(withLatitude: 30.128611, longitude: 31.242222, zoom: 17.0)
        let marker = GMSMarker(position: CLLocationCoordinate2DMake(30.128611, 31.242222))
        marker.title = "Your place selected :)"
        marker.map = mapView
        mapView.camera = location
        mapView.animate(to: location)

       
       
   //    let alert = UIAlertController(title: "Irjent !!😱😱", message: "Place name: \(place.name!).\n Place address: \(place.formattedAddress!).\n  Place latitude: \(place.coordinate.latitude) .\n Place longitude: \(place.coordinate.longitude) ", preferredStyle: .alert)
    //   alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
    //   }))
       
   //    self.present(alert, animated: true, completion: nil)
     }

     func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                            didFailAutocompleteWithError error: Error){
       // TODO: handle the error.
       print("Error: ", error.localizedDescription)
     }

     // Turn the network activity indicator on and off again.
     func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
       UIApplication.shared.isNetworkActivityIndicatorVisible = true
     }

     func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
       UIApplication.shared.isNetworkActivityIndicatorVisible = false
     }
}
