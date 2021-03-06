//
//  MapViewController.swift
//  MockMap
//
//  Created by IvanLe on 6/25/15.
//  Copyright (c) 2015 SiliconstraitsSaigon. All rights reserved.
//

import Foundation


class MapViewController : UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate, UITextFieldDelegate, IBarButtonItemDidTouch {
    
    
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
        
        // Show action sheet to ask for travel mode
        let actionSheet = UIAlertController(title: "Travel mode", message: "Please choose your transportation mean", preferredStyle: UIAlertControllerStyle.ActionSheet)
        var travelMode = ""
        
        actionSheet.addAction(UIAlertAction(title: "Driving", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            travelMode = "driving"
            self.drawRoutesByTravelMode(coordinate, travelMode: travelMode)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Walking", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            travelMode = "walking"
            self.drawRoutesByTravelMode(coordinate, travelMode: travelMode)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Bicycling", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            travelMode = "bicycling"
            self.drawRoutesByTravelMode(coordinate, travelMode: travelMode)
        }))
        
        presentViewController(actionSheet, animated: true, completion: nil)
        
    }
    
    func drawRoutesByTravelMode(coordinate: CLLocationCoordinate2D, travelMode: String){
        // Draw Routes
        if let currentLocation = self.currentLocation{
            self.googleDataProvider.directionFromLatLng(self.currentLocation!, destination: coordinate, travelMode: travelMode) { (status, success) -> Void in
                // Show Duration and Distance
                let distance = self.googleDataProvider.lookupData["distance"] as! String
                let duration = self.googleDataProvider.lookupData["duration"] as! String
                
                self.lblInfo.text = "Distance \(distance), Duration \(duration)"
                // Drawing
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
            tfPlace?.delegate = self
        }
        
        alertController.addTextFieldWithConfigurationHandler { (destination) -> Void in
            destination.placeholder = "Destination"
            tfDestination = destination
            tfDestination?.delegate = self
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
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "GetDirectionFromAddress" {
            var vc = segue.destinationViewController as! DirectionSearchViewController
            vc.iBarButtonItemDidTouch = self
            
        }
    }
    
    func barButtonItemOKDidTouch(origin: String, destination: String) {

        // Clear the map before drawing routes
        self.mapView.clear()
        
        // Create a marker at the original address
        self.googleDataProvider.geocodeAddress(origin, completionHander: { (status, success) -> Void in
            
            if success {
                let lat = self.googleDataProvider.lookupData["lat"] as! Double
                let lng = self.googleDataProvider.lookupData["lng"] as! Double
                
                let location = CLLocationCoordinate2D(latitude: lat, longitude: lng)
                self.mapView.camera = GMSCameraPosition(target: location, zoom: 15, bearing: 0, viewingAngle: 0)
                
                let marker = GMSMarker(position: location)
                marker.title = origin
                marker.map = self.mapView
            }
            
        })
        
        // Draw direction path from origin to destination
        self.googleDataProvider.directionFromAddresses(origin, to_address: destination) { (status, success) -> Void in
            if success {
                
                let distance: AnyObject?  = self.googleDataProvider.lookupData["distance"] as! String
                let duration: AnyObject?  = self.googleDataProvider.lookupData["duration"] as! String
                let points  = self.googleDataProvider.lookupData["points"] as! String
                
                self.lblInfo.text = "Distance: \(distance as! String), Duration: \(duration as! String)"
                
                var line = GMSPolyline(path: GMSPath(fromEncodedPath: points))
                line.map = self.mapView
            }
        }
    }
    
}