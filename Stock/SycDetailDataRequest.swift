//
//  SycDetailDataRequest.swift
//  Stock
//
//  Created by WangZhonghao on 5/2/16.
//  Copyright © 2016 WangZhonghao. All rights reserved.
//

import Foundation


public class SycDetailDataRequest{
    
    
    public class func getJSONData(symbol:String)->AnyObject{
        
        var jsonData:Dictionary<String,AnyObject>=[:]
        // Define server side script URL
        let scriptUrl = "http://tribal-map-127218.appspot.com/"
        
        // Add one parameter
        let urlWithParams = scriptUrl + "?detailSymbol=\(symbol)"
        
        // Create NSURL Ibject
        let myUrl = NSURL(string: urlWithParams);
        
        // Creaste URL Request
        let request = NSMutableURLRequest(URL:myUrl!);
        
        request.HTTPMethod = "GET"
        
        let semaphore = dispatch_semaphore_create(0)
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            
            // Check for error
            if error != nil
            {
                print("error=\(error)")
                return
            }
            
            
            
            // Print out response string
            //            let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            //
            //            print("responseString = \(responseString)")
            
            
            // Convert server json response to NSDictionary
            do {
                if let convertedJsonIntoDict = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? Dictionary<String,AnyObject> {
                    
                    // Print out dictionary
                    jsonData=convertedJsonIntoDict
                    
                    
                    //print(self.jsonData)
                    
                    // Get value by key
                    //                    let firstNameValue = convertedJsonIntoDict["userName"] as? String
                    //                    print(firstNameValue!)
                    dispatch_semaphore_signal(semaphore)
                }
                
                
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            
        }
        
        
        task.resume()
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        
        return jsonData
        
    }
}
