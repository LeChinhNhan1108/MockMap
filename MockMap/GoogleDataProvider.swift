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
    var lookupAddressResults: Dictionary<NSObject, AnyObject>!
    
    override init(){
        super.init()
    }
    
    func geocodeLatLng(lat: Double, lng: Double, completionHander: ((status: String, success: Bool) -> Void)){
        
        var lookUpUrlString = baseURLGeocode + "latlng=" + lat.description + "," + lng.description + "&key=" + googleMapsServerKey
        
        var lookUpUrl = NSURL(string: lookUpUrlString)
        
        dispatch_async(dispatch_get_main_queue(), {()->Void in
            let geocodingResult = NSData(contentsOfURL:  lookUpUrl!)
            
            if (geocodingResult == nil){
                completionHander(status: "", success: false)
                return
            }
            
            let string1 = NSString(data: geocodingResult!, encoding: NSUTF8StringEncoding)
            
            var error: NSError?
            
            let dictionary: Dictionary<NSObject, AnyObject> = NSJSONSerialization.JSONObjectWithData(geocodingResult!, options: NSJSONReadingOptions.MutableContainers, error: &error) as Dictionary<NSObject, AnyObject>
            
            if (error != nil){
                println(error)
                completionHander(status: "", success: false)
                
            }else{
                
                // Get the response status.
                let status = dictionary["status"] as String
                
                if status == "OK" {
                    
                    let allResults = dictionary["results"] as Array<Dictionary<NSObject, AnyObject>>
                    let lookUpResult = allResults[0] as Dictionary<NSObject, AnyObject>
                    
                
                    let geometry = lookUpResult["geometry"] as Dictionary<NSObject, AnyObject>

                    let lat = ((geometry["location"] as Dictionary<NSObject, AnyObject>)["lat"] as NSNumber).doubleValue

                    let lng = ((geometry["location"] as Dictionary<NSObject, AnyObject>)["lng"] as NSNumber).doubleValue
                    
                    let formatted_address = lookUpResult["formatted_address"] as String
                    if (formatted_address.isEmpty){
                        self.lookupAddressResults.updateValue(formatted_address, forKey: "formatted_address")
                    }

                    completionHander(status: status, success: true)
                }
                else {
                    completionHander(status: status, success: false)
                }
            }
        })
        
    }
    
}