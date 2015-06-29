//
//  MapViewController.swift
//  MockMap
//
//  Created by IvanLe on 6/25/15.
//  Copyright (c) 2015 SiliconstraitsSaigon. All rights reserved.
//

import Foundation


class MapViewController : UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {
    

    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var lblInfo: UILabel!

    let locationManager = CLLocationManager()
    let googleDataProvider = GoogleDataProvider()
    var currentLocation: CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        
        self.mapView.delegate = self
        self.mapView.camera = GMSCameraPosition(target: CLLocationCoordinate2D(latitude: 10.723059, longitude: 106.7158508), zoom: 17, bearing: 0, viewingAngle: 0)
    
    }

    // MARK: Location Delegate
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if (status == CLAuthorizationStatus.AuthorizedWhenInUse){
            self.mapView.myLocationEnabled = true
            self.mapView.settings.myLocationButton = true
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!) {
        self.currentLocation = newLocation.coordinate
        locationManager.stopUpdatingLocation()
    }
    
    // MARK: MapView delegate
    
    func mapView(mapView: GMSMapView!, didLongPressAtCoordinate coordinate: CLLocationCoordinate2D) {
        // Clear map when set pin
        self.mapView.clear()
        
        // Add a marker
        let marker = GMSMarker(position: coordinate)
        marker.title = "Destination"
        marker.map = self.mapView

        // Draw Routes
        if let currentLocation = self.currentLocation{
            self.googleDataProvider.directionFromLatLng(self.currentLocation!, destination: coordinate) { (status, success) -> Void in
                let polyline = GMSPolyline(path: GMSPath(fromEncodedPath: self.googleDataProvider.lookupData["points"] as! String))
                polyline.map = self.mapView
            }
        }
    }
    
    func didTapMyLocationButtonForMapView(mapView: GMSMapView!) -> Bool {
        locationManager.startUpdatingLocation()
        return false
    }
    
    // MARK: Button Touch
    @IBAction func mapTypeButtonDidTouch(sender: UIBarButtonItem) {
        let actionSheet = UIAlertController(title: "Map Types", message: "Select map type:", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let normalMapTypeAction = UIAlertAction(title: "Normal", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
            self.mapView.mapType = kGMSTypeNormal
        }
        
        let terrainMapTypeAction = UIAlertAction(title: "Terrain", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
            self.mapView.mapType = kGMSTypeTerrain
        }
        
        let hybridMapTypeAction = UIAlertAction(title: "Hybrid", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
            self.mapView.mapType = kGMSTypeHybrid
        }
        
        let cancelAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.Cancel) { (alertAction) -> Void in
            
        }
        
        actionSheet.addAction(normalMapTypeAction)
        actionSheet.addAction(terrainMapTypeAction)
        actionSheet.addAction(hybridMapTypeAction)
        actionSheet.addAction(cancelAction)
        
        presentViewController(actionSheet, animated: true, completion: nil)
    }
    @IBAction func directionButtonDidTouch(sender: UIBarButtonItem) {
        
        var alertController = UIAlertController(title: "Enter place and destination", message: "", preferredStyle: UIAlertControllerStyle.Alert)
        
        var tfPlace: UITextField?
        var tfDestination: UITextField?

        alertController.addTextFieldWithConfigurationHandler { (place) -> Void in
            place.placeholder = "Origin"
            tfPlace = place
        }
        
        alertController.addTextFieldWithConfigurationHandler { (destination) -> Void in
            destination.placeholder = "Destination"
            tfDestination = destination
            
        }
        
        // Create the actions.
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { action in
            
        }
        
        let okAction = UIAlertAction(title: "OK", style: .Default) { action in

            let from_address = tfPlace?.text
            let to_address = tfDestination?.text
            
            self.googleDataProvider.geocodeAddress(from_address!, completionHander: { (status, success) -> Void in
                
                println("GeoAddress \(status)")
                
                let lat = self.googleDataProvider.lookupData["lat"] as! Double
                let lng = self.googleDataProvider.lookupData["lng"] as! Double
                
                let location = CLLocationCoordinate2D(latitude: lat, longitude: lng)
                self.mapView.camera = GMSCameraPosition(target: location, zoom: 15, bearing: 0, viewingAngle: 0)
            })

            self.googleDataProvider.directionFromAddresses(from_address!, to_address: to_address!, completionHander: { (status, success) -> Void in
                
                println("Direction \(status)")
                
                if (!success){
                    return
                }
                
                self.mapView.clear()
                
                let distance: AnyObject?  = self.googleDataProvider.lookupData["distance"] as! String
                let duration: AnyObject?  = self.googleDataProvider.lookupData["duration"] as! String
                let points  = self.googleDataProvider.lookupData["points"] as! String
                
                self.lblInfo.text = "Distance: \(distance as! String), Duration: \(duration as! String)"
                
                var line = GMSPolyline(path: GMSPath(fromEncodedPath: points))
                line.map = self.mapView

            })
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        
        
        presentViewController(alertController, animated: true, completion: nil)

    }
}