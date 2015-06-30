//
//  GoogleDataProvider.swift
//  MockMap
//
//  Created by IvanLe on 6/25/15.
//  Copyright (c) 2015 SiliconstraitsSaigon. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON

class GoogleDataProvider : NSObject {
    
    let googleMapsServerKey = "AIzaSyA6AOLS1ndfN9WfmDNrPcvMPH6jM7Tuvds"
    
    let baseURLGeocode = "https://maps.googleapis.com/maps/api/geocode/json?"
    let baseURLDirection = "https://maps.googleapis.com/maps/api/directions/json?"
    let baseURLPlace = "https://maps.googleapis.com/maps/api/place/autocomplete/json?"
    
    var lookupAddressResults: Dictionary<NSObject, AnyObject>!
    
    var lookupData: Dictionary<String, AnyObject>!
    
    override init(){
        super.init()
        lookupData = Dictionary<String, AnyObject>()
    }
    
    // From LatLng to Address
    func geocodeLatLng(lat: Double, lng: Double, completionHander: ((status: String, success: Bool) -> Void)){
        
        var lookUpUrlString = baseURLGeocode + "latlng=" + lat.description + "," + lng.description + "&key=" + googleMapsServerKey
        
        var lookUpUrl = NSURL(string: lookUpUrlString)
        
        dispatch_async(dispatch_get_main_queue(), {()->Void in
            let geocodingResultsData = NSData(contentsOfURL:  lookUpUrl!)
            
            if (geocodingResultsData == nil){
                completionHander(status: "", success: false)
            }else{
                
                var error: NSError?
                let dictionary: Dictionary<NSObject, AnyObject> = NSJSONSerialization.JSONObjectWithData(geocodingResultsData!, options: NSJSONReadingOptions.MutableContainers, error: &error) as! Dictionary<NSObject, AnyObject>
                
                if (error != nil) {
                    println(error)
                    completionHander(status: "", success: false)
                }else{
                    let status = dictionary["status"] as! String
                    if status == "OK" {
                        let allResults = dictionary["results"] as! Array<Dictionary<NSObject, AnyObject>>
                        self.lookupAddressResults = allResults[0]
                        
                        var fetchedFormattedAddress = self.lookupAddressResults["formatted_address"] as! String!
                        
                        let geometry = self.lookupAddressResults["geometry"] as! Dictionary<NSObject, AnyObject>
                        let fetchedAddressLongitude = ((geometry["location"] as! Dictionary<NSObject, AnyObject>)["lng"] as! NSNumber).doubleValue
                        let fetchedAddressLatitude = ((geometry["location"] as! Dictionary<NSObject, AnyObject>)["lat"] as! NSNumber).doubleValue
                        
                        self.lookupData = Dictionary<String, AnyObject>()
                        self.lookupData["formatted_address"] = fetchedFormattedAddress
                        self.lookupData["lat"] = fetchedAddressLatitude
                        self.lookupData["lng"] = fetchedAddressLongitude
                        
                        completionHander(status: status, success: true)
                    }else{
                        completionHander(status: status, success: false)
                    }
                }
            }
            
        })
    }
    
    // From Address to LatLng
    func geocodeAddress(address: String, completionHander: ((status: String, success: Bool) -> Void)){
        
        println("Geocode enters")
        
        var lookUpUrlString = baseURLGeocode + "address=" + address + "&key=" + googleMapsServerKey
        lookUpUrlString = lookUpUrlString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        let lookUpUrl = NSURL(string: lookUpUrlString)
        
        dispatch_async(dispatch_get_main_queue(), {()->Void in
            let geocodingResultsData = NSData(contentsOfURL:  lookUpUrl!)
            
            if (geocodingResultsData == nil){
                completionHander(status: "", success: false)
            }else{
                
                var error: NSError?
                let dictionary: Dictionary<NSObject, AnyObject> = NSJSONSerialization.JSONObjectWithData(geocodingResultsData!, options: NSJSONReadingOptions.MutableContainers, error: &error) as! Dictionary<NSObject, AnyObject>
                
                if (error != nil) {
                    println(error)
                    completionHander(status: "", success: false)
                }else{
                    let status = dictionary["status"] as! String
                    if status == "OK" {
                        let allResults = dictionary["results"] as! Array<Dictionary<NSObject, AnyObject>>
                        self.lookupAddressResults = allResults[0]
                        
                        let fetchedFormattedAddress = self.lookupAddressResults["formatted_address"] as! String!
                        
                        let geometry = self.lookupAddressResults["geometry"] as! Dictionary<NSObject, AnyObject>
                        let fetchedAddressLongitude = ((geometry["location"] as! Dictionary<NSObject, AnyObject>)["lng"] as! NSNumber).doubleValue
                        let fetchedAddressLatitude = ((geometry["location"] as! Dictionary<NSObject, AnyObject>)["lat"] as! NSNumber).doubleValue
                        
                        self.lookupData = Dictionary<String, AnyObject>()
                        self.lookupData["formatted_address"] = fetchedFormattedAddress
                        self.lookupData["lat"] = fetchedAddressLatitude
                        self.lookupData["lng"] = fetchedAddressLongitude
                        
                        completionHander(status: status, success: true)
                    }else{
                        completionHander(status: status, success: false)
                    }
                }
            }
            println("Geocode ASYNC exits")
            
        })
        println("Geocode exits")
        
    }
    
    func directionFromAddresses(from_address: String, to_address: String, completionHander: ((status: String, success: Bool)-> Void)){
        
        println("Direction from addresses enters")
        
        var lookUpUrlString = baseURLDirection + "origin=" + from_address + "&destination=" + to_address + "&key=" + googleMapsServerKey
        lookUpUrlString = lookUpUrlString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        let lookUpUrl = NSURL(string: lookUpUrlString)
        
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            let geocodingResultsData = NSData(contentsOfURL:  lookUpUrl!)
            
            if (geocodingResultsData == nil){
                completionHander(status: "", success: false)
            }else{
                var error: NSError?
                let dictionary: Dictionary<NSObject, AnyObject> = NSJSONSerialization.JSONObjectWithData(geocodingResultsData!, options: NSJSONReadingOptions.MutableContainers, error: &error) as! Dictionary<NSObject, AnyObject>
                
                if (error != nil) {
                    println(error)
                    completionHander(status: "", success: false)
                }else{
                    let status = dictionary["status"] as! String
                    if status == "OK" {
                        // MARK: Get Popylines to Draw Routes
                        let allResults = dictionary["routes"] as! Array<Dictionary<NSObject, AnyObject>>
                        self.lookupAddressResults = allResults[0]
                        
                        let legs = self.lookupAddressResults["legs"] as! Array<Dictionary<NSObject, AnyObject>>
                        let distance = ((legs[0] as Dictionary<NSObject, AnyObject>)["distance"] as! Dictionary<NSObject, AnyObject>)["text"] as! String
                        
                        let duration = ((legs[0] as Dictionary<NSObject, AnyObject>)["duration"] as! Dictionary<NSObject, AnyObject>)["text"] as! String
                        
                        let overview_polyline = self.lookupAddressResults["overview_polyline"] as! Dictionary<NSObject, AnyObject>
                        
                        let points = overview_polyline["points"] as! String
                        
                        self.lookupData = Dictionary<String, AnyObject>()
                        self.lookupData["distance"] = distance
                        self.lookupData["duration"] = duration
                        self.lookupData["points"] = points
                        
                        completionHander(status: status, success: true)
                        
                    }else{
                        completionHander(status: status, success: false)
                    }
                }
            }
            
            println("Direction from addresses ASYNC exits")
        })
        
        println("Direction from addresses exits")
        
    }
    
    func directionFromLatLng(origin: CLLocationCoordinate2D, destination: CLLocationCoordinate2D, travelMode: String, completionHandler: ((status: String, success: Bool)->Void)){
        
        let paramOrigin = origin.latitude.description + "," + origin.longitude.description
        let paramDestination = destination.latitude.description + "," + destination.longitude.description
        
        Alamofire.request(Alamofire.Method.GET, baseURLDirection, parameters: ["origin": paramOrigin,
            "destination": paramDestination, "key": googleMapsServerKey, "mode": travelMode], encoding: ParameterEncoding.URL)
            .responseJSON(options: NSJSONReadingOptions.MutableLeaves) { (request, response, json, error) -> Void in
                
                if(error == nil){
                    let jsonObject = JSON(json!)
                    let status = jsonObject["status"].string
                    if ( status == "OK"){
                        let routes = jsonObject["routes"][0]
                        let points = routes["overview_polyline"]["points"].string
                        let distance = routes["legs"][0]["distance"]["text"].string
                        let duration = routes["legs"][0]["duration"]["text"].string
                        
                        self.lookupData = Dictionary<String, AnyObject>()
                        self.lookupData["points"] = points
                        self.lookupData["distance"] = distance
                        self.lookupData["duration"] = duration
                        
                        completionHandler(status: status!, success: true)
                    }else{
                        completionHandler(status: status!, success: false)
                    }
                }
        }
        
        
        
    }
    /*
    This function uses NSArray as inout parameter.
    1/ Swift uses pass by copy-restore mechanism for inout param.
    2/ Array is a struct, not an object like NSArray
    
    (1,2) => Using Array as inout param wont work as expected
    
    SOL:
    - Using NSArray instead of Array
    - Using Array with call-back
    */
    
    /*
    func placesAutocomplete(place: String, inout places: NSMutableArray, completionHandler: ((status: String, success: Bool)->Void)){
    Alamofire.request(.GET, baseURLPlace, parameters: ["input": place, "types": "address", "key": googleMapsServerKey], encoding: ParameterEncoding.URL).responseJSON(options: NSJSONReadingOptions.MutableLeaves) { (request, response, json, error) -> Void in
    
    println("Place autocomplete enters")
    
    if (error == nil){
    let jsonObject = JSON(json!)
    let predictions: Array<JSON> = jsonObject["predictions"].arrayValue
    for prediction in predictions {
    var description = prediction["description"].stringValue
    places.addObject(description)
    println("Add places")
    }
    completionHandler(status: "OK", success: true)
    }else{
    completionHandler(status: "", success: false)
    }
    
    println("Place autocomplete returns")
    
    }
    }*/
    
    func placesAutocomplete(place: String, completionHandler: ((status: String, success: Bool, places: [String])->Void)){
        Alamofire.request(.GET, baseURLPlace, parameters: ["input": place, "types": "address", "key": googleMapsServerKey], encoding: ParameterEncoding.URL).responseJSON(options: NSJSONReadingOptions.MutableLeaves) { (request, response, json, error) -> Void in
            
            var places = [String]()
            
            if (error == nil){
                let jsonObject = JSON(json!)
                let predictions: Array<JSON> = jsonObject["predictions"].arrayValue
                for prediction in predictions {
                    var description = prediction["description"].stringValue
                    places.append(description)
                }
                completionHandler(status: "OK", success: true, places: places)
            }else{
                completionHandler(status: "", success: false, places: places)
            }
        }
    }
    
    
    
    
    
    
    
    
    
}