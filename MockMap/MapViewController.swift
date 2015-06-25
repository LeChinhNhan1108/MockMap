//
//  MapViewController.swift
//  MockMap
//
//  Created by IvanLe on 6/25/15.
//  Copyright (c) 2015 SiliconstraitsSaigon. All rights reserved.
//

import Foundation

class MapViewController : UIViewController, CLLocationManagerDelegate {
    

    @IBOutlet weak var mapView: GMSMapView!

    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if (status == CLAuthorizationStatus.AuthorizedWhenInUse){
            self.mapView.myLocationEnabled = true
            self.mapView.settings.myLocationButton = true
        }
    }
    

    
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
    }
}