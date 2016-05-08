//
//  AsycAutoCompeleteDataRequest.swift
//  Stock
//
//  Created by WangZhonghao on 4/18/16.
//  Copyright © 2016 WangZhonghao. All rights reserved.
//

import Foundation

 class AsycAutoCompleteDataRequest {
    var symbol:String=""
    
    init(symbol:String){
        self.symbol=symbol
    }
    
    func getData(completionHandler: ((Array<AnyObject>!, NSError!) -> Void)!) -> Void {
        
        let scriptUrl = "http://tribal-map-127218.appspot.com/"
        
        // Add one parameter
        let urlWithParams = scriptUrl + "?symbol=\(symbol)"
        
        
        // Create NSURL Ibject
        let myUrl = NSURL(string: urlWithParams)!;
        
        
        let ses = NSURLSession.sharedSession()
        let task = ses.dataTaskWithURL(myUrl, completionHandler: {data, response, error -> Void in
            if (error != nil) {
                return completionHandler(nil, error)
            }
            
            
            
            do {
                if let convertedJsonIntoDict = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? Array<AnyObject>
                {
                    
                     //print(convertedJsonIntoDict)
                    return completionHandler(convertedJsonIntoDict,nil)
                    
                }
                
                
            } catch let error as NSError {
                print(error.localizedDescription)
            }

            
            
            
            
            
            
//            
//            var error: NSError?
//            let json = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &error) as NSDictionary
//            
//            if (error != nil) {
//                return completionHandler(nil, error)
//            } else {
//                return completionHandler(json["results"] as [NSDictionary], nil)
//            }
        })
        task.resume()
    }
    
}