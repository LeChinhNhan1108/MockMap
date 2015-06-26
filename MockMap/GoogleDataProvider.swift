//
//  GoogleDataProvider.swift
//  MockMap
//
//  Created by IvanLe on 6/25/15.
//  Copyright (c) 2015 SiliconstraitsSaigon. All rights reserved.
//

import Foundation
import UIKit

class GoogleDataProvider : NSObject {
    
    let googleMapsServerKey = "AIzaSyA6AOLS1ndfN9WfmDNrPcvMPH6jM7Tuvds"
    
    let baseURLGeocode = "https://maps.googleapis.com/maps/api/geocode/json?"
    let baseURLDirection = "https://maps.googleapis.com/maps/api/directions/json?"
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
                let dictionary: Dictionary<NSObject, AnyObject> = NSJSONSerialization.JSONObjectWithData(geocodingResultsData!, options: NSJSONReadingOptions.MutableContainers, error: &error) as Dictionary<NSObject, AnyObject>
                
                if (error != nil) {
                    println(error)
                    completionHander(status: "", success: false)
                }else{
                    let status = dictionary["status"] as String
                    if status == "OK" {
                        let allResults = dictionary["results"] as Array<Dictionary<NSObject, AnyObject>>
                        self.lookupAddressResults = allResults[0]
                        
                        var fetchedFormattedAddress = self.lookupAddressResults["formatted_address"] as String!
                        
                        let geometry = self.lookupAddressResults["geometry"] as Dictionary<NSObject, AnyObject>
                        var fetchedAddressLongitude = ((geometry["location"] as Dictionary<NSObject, AnyObject>)["lng"] as NSNumber).doubleValue
                        var fetchedAddressLatitude = ((geometry["location"] as Dictionary<NSObject, AnyObject>)["lat"] as NSNumber).doubleValue
                        
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
        
        var lookUpUrlString = baseURLGeocode + "address=" + address + "&key=" + googleMapsServerKey
        lookUpUrlString = lookUpUrlString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        var lookUpUrl = NSURL(string: lookUpUrlString)
        
        dispatch_async(dispatch_get_main_queue(), {()->Void in
            let geocodingResultsData = NSData(contentsOfURL:  lookUpUrl!)
            
            if (geocodingResultsData == nil){
                completionHander(status: "", success: false)
            }else{
                
                var error: NSError?
                let dictionary: Dictionary<NSObject, AnyObject> = NSJSONSerialization.JSONObjectWithData(geocodingResultsData!, options: NSJSONReadingOptions.MutableContainers, error: &error) as Dictionary<NSObject, AnyObject>
                
                if (error != nil) {
                    println(error)
                    completionHander(status: "", success: false)
                }else{
                    let status = dictionary["status"] as String
                    if status == "OK" {
                        let allResults = dictionary["results"] as Array<Dictionary<NSObject, AnyObject>>
                        self.lookupAddressResults = allResults[0]
                        
                        var fetchedFormattedAddress = self.lookupAddressResults["formatted_address"] as String!
                        
                        let geometry = self.lookupAddressResults["geometry"] as Dictionary<NSObject, AnyObject>
                        var fetchedAddressLongitude = ((geometry["location"] as Dictionary<NSObject, AnyObject>)["lng"] as NSNumber).doubleValue
                        var fetchedAddressLatitude = ((geometry["location"] as Dictionary<NSObject, AnyObject>)["lat"] as NSNumber).doubleValue
                        
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
    
    func directionFromAddresses(from_address: String, to_address: String, completionHander: ((status: String, success: Bool)-> Void)){
        
        var lookUpUrlString = baseURLDirection + "origin=" + from_address + "&destination=" + to_address + "&key=" + googleMapsServerKey
        lookUpUrlString = lookUpUrlString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        var lookUpUrl = NSURL(string: lookUpUrlString)
        
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            let geocodingResultsData = NSData(contentsOfURL:  lookUpUrl!)
            
            if (geocodingResultsData == nil){
                completionHander(status: "", success: false)
            }else{
                var error: NSError?
                let dictionary: Dictionary<NSObject, AnyObject> = NSJSONSerialization.JSONObjectWithData(geocodingResultsData!, options: NSJSONReadingOptions.MutableContainers, error: &error) as Dictionary<NSObject, AnyObject>
                
                if (error != nil) {
                    println(error)
                    completionHander(status: "", success: false)
                }else{
                    let status = dictionary["status"] as String
                    if status == "OK" {
                        // MARK: Get Popylines to Draw Routes
                        let allResults = dictionary["routes"] as Array<Dictionary<NSObject, AnyObject>>
                        self.lookupAddressResults = allResults[0]
                        
                        let legs = self.lookupAddressResults["legs"] as Array<Dictionary<NSObject, AnyObject>>
                        let distance = ((legs[0] as Dictionary<NSObject, AnyObject>)["distance"] as Dictionary<NSObject, AnyObject>)["text"] as String
                        
                        let duration = ((legs[0] as Dictionary<NSObject, AnyObject>)["duration"] as Dictionary<NSObject, AnyObject>)["text"] as String
                        
                        let overview_polyline = self.lookupAddressResults["overview_polyline"] as Dictionary<NSObject, AnyObject>
                        
                        let points = overview_polyline["points"] as String
                        
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
        })
        
    }
    
}