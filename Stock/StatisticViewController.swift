//
//  StatisticViewController.swift
//  Stock
//
//  Created by WangZhonghao on 4/16/16.
//  Copyright © 2016 WangZhonghao. All rights reserved.
//

import UIKit
import CoreData
import FBSDKShareKit
import FBSDKCoreKit
import FBSDKLoginKit

protocol detailDataDelegate {
    func addOrRemoveFavouriteList(object:Dictionary<String,String>)
}


class StatisticViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, FBSDKSharingDelegate{
    
    @IBOutlet weak var currentButton: UIButton!

    @IBOutlet weak var favouriteButton: UIButton!
    @IBOutlet weak var ScrollView: UIScrollView!
    //@IBOutlet weak var naviBar: UINavigationBar!
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var dailyChart: UIImageView!
    
    var symbol:String = ""
    var ORIGTableData:Dictionary<String, AnyObject>=[:]
    var detailTableData:Array<Dictionary<String, String>> = []
    
    var delegate:detailDataDelegate? = nil
    
    var viewFlag:Int = 0
  
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        myTableView.cellLayoutMarginsFollowReadableWidth = false
//        myTableView.layoutMargins = UIEdgeInsetsZero
        ScrollView.contentSize.height=1100
        self.title = symbol
        
      
        currentButton.backgroundColor = UIColor(red: 13/255, green:102/255, blue: 255/255, alpha:1)
        currentButton.layer.cornerRadius=5

        if isInCoreData(symbol) == true {
            favouriteButton.setImage(UIImage(named: "Star Filled-100"), forState: UIControlState.Normal)
        }
        else{
             favouriteButton.setImage(UIImage(named: "Star-100"), forState: UIControlState.Normal)
        }
        
        
        //asyc
        
           // self.tableView.reloadData()
        
        let dataRequest = AsycDetailTableDataRequest(symbol: symbol)
        dataRequest.getData({data,error-> Void in
                        if(data != nil){
                            self.ORIGTableData = data
                            //print(self.ORIGTableData)
                            self.detailTableData = self.sharpenData(self.ORIGTableData)
                            //print(self.detailTableData)
                        dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                            self.myTableView.reloadData()
                        }
                        }
                    })

        
        //syc
     //DetailTableDataRequest.getJSONData(symbol)
//        ORIGTableData = DetailTableDataRequest.getJSONData(symbol) as! Dictionary<String, AnyObject>
//        
//        detailTableData = sharpenData(ORIGTableData)
//        print(detailTableData)
//        print(detailTableData.count)
       
        let url = NSURL(string: "http://chart.finance.yahoo.com/t?s=\(symbol)&lang=en-US&width=400&height=300")
        let data = NSData(contentsOfURL: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check
        dailyChart.image = UIImage(data: data!)
        
        viewFlag=0
        
               //tableView.reloadData()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func fbShareButtonTapped(sender: AnyObject) {
        
        
        let symbol = Array(self.detailTableData[1].values)[0]
        let stockValue = Array(self.detailTableData[2].values)[0]
        let name = Array(self.detailTableData[0].values)[0]
        
        let content:FBSDKShareLinkContent = FBSDKShareLinkContent()
        content.contentURL = NSURL(string: "http://finance.yahoo.com/q?s=\(symbol)")
        content.contentTitle = "Current Stock Price of \(name) is \(stockValue)"
        content.contentDescription = "Stock Information of \(name) (\(symbol))"
        content.imageURL = NSURL(string: "http://chart.finance.yahoo.com/t?s=\(symbol)&lang=en-US&width=220&height=240")
        
        let shareDialog = FBSDKShareDialog()
        shareDialog.mode = FBSDKShareDialogMode.FeedBrowser
        shareDialog.shareContent = content
        shareDialog.delegate = self
        shareDialog.fromViewController=self
        if !shareDialog.canShow() {
            print("cannot show native share dialog")
        }
        
        do{
            try shareDialog.validate()
        }catch{
            print(error)
        }
        viewFlag = 1
        shareDialog.show()
     
    }
   
    
    func sharer(sharer: FBSDKSharing!, didCompleteWithResults results: [NSObject : AnyObject]!) {
        //print(results)
        if results["postId"] != nil {
            
        
        let didShareAlert = UIAlertController(title: "You've shared the Stock information!", message: "", preferredStyle:UIAlertControllerStyle.Alert)
        didShareAlert.addAction(UIAlertAction(title:"OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(didShareAlert,animated:true,completion:nil)
        }
        else{
            let cancelShareAlert = UIAlertController(title: "Did not share!", message: "", preferredStyle:UIAlertControllerStyle.Alert)
            cancelShareAlert.addAction(UIAlertAction(title:"OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(cancelShareAlert,animated:true,completion:nil)
        }
    }
    
    func sharer(sharer: FBSDKSharing!, didFailWithError error: NSError!) {
        let failedToShareAlert = UIAlertController(title: "Error", message: "", preferredStyle:UIAlertControllerStyle.Alert)
        failedToShareAlert.addAction(UIAlertAction(title:"OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(failedToShareAlert,animated:true,completion:nil)
    }
    
    func sharerDidCancel(sharer: FBSDKSharing!) {
        let cancelShareAlert = UIAlertController(title: "Did not share!", message: "", preferredStyle:UIAlertControllerStyle.Alert)
        cancelShareAlert.addAction(UIAlertAction(title:"OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(cancelShareAlert,animated:true,completion:nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        
    }

    func isInCoreData(symbol:String) -> Bool {
        let moc = DataController().managedObjectContext
        
        do{
            let favouriteFetch = NSFetchRequest(entityName:"FavouriteList")
            let fetchedData = try moc.executeFetchRequest(favouriteFetch)
                      if fetchedData.count > 0{
                        for item in fetchedData as! [NSManagedObject]{
                            let symbolObject = item.valueForKey("companySymbol")
                            if symbolObject != nil{
                            let symbolInCoreData = symbolObject as! String
                            if symbol == symbolInCoreData {
                                return true
                             }
                        }
                      }
            }
            
        }catch{
            print("There was an error.")
        }
        
        return false
        
    }
    
    func pickUpData() -> Dictionary<String,String> {
        var result:Dictionary<String,String>=[:]
        
        result["Symbol"] = Array(self.detailTableData[1].values)[0]
        result["Last Price"] = Array(self.detailTableData[2].values)[0]
        result["Change"]=Array(self.detailTableData[3].values)[0]
        result["Name"] = Array(self.detailTableData[0].values)[0]
        result["Market Cap"]=Array(self.detailTableData[5].values)[0]
        
        return result

    }
    
    @IBAction func saveToFavourite(sender: UIButton) {
      
        
        
        let moc = DataController().managedObjectContext
        
        let entity = NSEntityDescription.insertNewObjectForEntityForName("FavouriteList", inManagedObjectContext: moc) as! FavouriteList
        
     
        
        do{
            let favouriteFetch = NSFetchRequest(entityName:"FavouriteList")
            let fetchedData = try moc.executeFetchRequest(favouriteFetch) as! [FavouriteList]
            
//            if fetchedData.count > 0{
//                for item in fetchedData as! [NSManagedObject]{
//                    let symbolObject = item.valueForKey("companySymbol")
//                    
//                        moc.deleteObject(item)
//                        print("delete the nil object")
//                        do{
//                            try moc.save()
//                            
//                        }catch{
//                            fatalError("failure to save context:\(error)")
//                        }
//                    
//                    print("core data now contains:\(symbol)")
//                }
//            }

            
            let symbolToBeAdd = Array(detailTableData[1].values)[0]
            
            if fetchedData.count > 0 {
                //mark the symbol is delete or not
                var tmp=0
                for item in fetchedData {
                    let symbolObject = item.valueForKey("companySymbol")
                    if symbolObject != nil {
                        let symbol = symbolObject as! String
                        if symbol == symbolToBeAdd {
                        
                        moc.deleteObject(item as NSManagedObject)
                        //print("delete the "+symbol)
                        
                        //把delegate改成传symbol 然后用symbol在favouritedata里改数据，然后reload去改table
                        if (delegate != nil) {
                            let symbol = self.symbol
                            let justSymbol:Dictionary<String, String> = ["Symbol":symbol]
                            //print(justSymbol)
                            delegate!.addOrRemoveFavouriteList(justSymbol)
                        }

                        
                        //symbol has beem deleted
                        favouriteButton.setImage(UIImage(named: "Star-100"), forState: UIControlState.Normal)
                        tmp=1
                        do{
                            try moc.save()
                        }catch{
                            fatalError("failure to save context:\(error)")
                        }
                     }
                    }
                }
                
                if tmp == 0 {

                        entity.setValue(symbolToBeAdd, forKey: "companySymbol")
                        favouriteButton.setImage(UIImage(named: "Star Filled-100"), forState: UIControlState.Normal)
                        if (delegate != nil) {
                            let dataToFavouriteList = pickUpData()
                            //print(dataToFavouriteList)
                            delegate!.addOrRemoveFavouriteList(dataToFavouriteList)
                        }

                        do{
                            try moc.save()
                           // print("add new symbol:\(symbolToBeAdd)")
                        }catch{
                            fatalError("failure to save context:\(error)")
                        }

                }
                
                   // print(symbol)
               
            }
            else{
                
                entity.setValue(symbolToBeAdd, forKey: "companySymbol")
                favouriteButton.setImage(UIImage(named: "Star Filled-100"), forState: UIControlState.Normal)
                do{
                    try moc.save()
                }catch{
                    fatalError("failure to save context:\(error)")
                }

            }
            
        }catch{
            print("There was an error.")
        }

        
        
        
    
        
       
        
        do{
            let favouriteFetch = NSFetchRequest(entityName:"FavouriteList")
            let fetchedData = try moc.executeFetchRequest(favouriteFetch)
           //print(fetchedData.first!.symbol!)
//            for res in fetchedData {
//                print(res.valueForKey("symbol"))
//            }
           if fetchedData.count > 0{
                for item in fetchedData as! [NSManagedObject]{
                    let symbol2 = item.valueForKey("companySymbol")
                    if symbol2 == nil {
                        moc.deleteObject(item)
                        try moc.save()
                    }
                    
//                       moc.deleteObject(item)
////
//                       try moc.save()

                    //print("core data now contains:\(symbol2)")
                }
            }
            
        }catch{
             print("There was an error.")
        }
        
        
        
        
    }
    
    
   
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewWillAppear(animated: Bool)
    {
        self.navigationController?.navigationBarHidden = false
    }
    
    func sharpenData(JSONData:Dictionary<String, AnyObject>) -> Array<Dictionary<String, String>> {
        var result:Array<Dictionary<String, String>>=[]
        let Name = JSONData["Name"] as? String
        result.append(["Name":Name!])
        let Symbol = JSONData["Symbol"] as? String
        result.append(["Symbol":Symbol!])
        
        var  tmpDouble:Double = JSONData["LastPrice"] as! Double
        var LastPrice:String = String(format:"%.2f", tmpDouble)
        LastPrice = "$ "+LastPrice
        result.append(["Last Price":LastPrice])
        
        tmpDouble = JSONData["Change"] as! Double
        var flag1:String=""
        if tmpDouble>0 {
            flag1 = "+"
        }
        let Change:String = flag1+String(format:"%.2f", tmpDouble)
        tmpDouble = JSONData["ChangePercent"] as! Double
        let ChangePercent:String=String(format:"%.2f", tmpDouble)
        let ChangeCombine=Change+"("+ChangePercent+"%)"
        result.append(["Change":ChangeCombine])
        
        
        
        let tmpString = JSONData["Timestamp"] as! String

        let dateFormatter1 = NSDateFormatter()
       // dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter1.dateFormat="EEE MMM d HH:mm:ss zzz yyyy"
        let origDate=dateFormatter1.dateFromString(tmpString)
        let dateFormatter2 = NSDateFormatter()
        
        dateFormatter2.dateFormat = "MMM d yyyy HH:mm"
        let dateSTRING:String = dateFormatter2.stringFromDate(origDate!)
       
        let Time=dateSTRING
        result.append(["Time and Date":Time])

        
        var MktmpDouble:Double=JSONData["MarketCap"] as! Double
        var MarketCap:String=""
        if MktmpDouble > 1000000000000.0 {
            MktmpDouble=MktmpDouble/1000000000000.0
            MarketCap=String(format:"%.2f", MktmpDouble)+" Trilliion"
            //print(MarketCap)
        }
        else if MktmpDouble>1000000000.0 {
            MktmpDouble=MktmpDouble/1000000000.0
            MarketCap=String(format:"%.2f", MktmpDouble)+" Billiion"
            //print(MarketCap)
        }
        else if MktmpDouble>1000000.0 {
            MktmpDouble=MktmpDouble/1000000.0
            MarketCap=String(format:"%.2f", MktmpDouble)+" Milliion"
            //print(MarketCap)
        }
        else{
            MarketCap=String(format:"%.2f",MktmpDouble)
            // print(MarketCap)
        }
         result.append(["Market Cap":MarketCap])
        
        let tmpInt=JSONData["Volume"] as! Int
        let Volume=String(tmpInt)
        result.append(["Volume":Volume])
        
        tmpDouble = JSONData["ChangeYTD"] as! Double
        var flag2:String=""
        if tmpDouble>0 {
            flag2 = "+"
        }
        let ChangeYTD:String = flag2+String(format:"%.2f", tmpDouble)
        tmpDouble = JSONData["ChangePercentYTD"] as! Double
        let ChangePercentYTD:String=String(format:"%.2f", tmpDouble)
        let ChangeYTDCombine=ChangeYTD+"("+ChangePercentYTD+"%)"
        result.append(["Change YTD":ChangeYTDCombine])
        
        tmpDouble = JSONData["High"] as! Double
        var HighPrice:String = String(format:"%.2f", tmpDouble)
        HighPrice = "$ "+HighPrice
        result.append(["High Price":HighPrice])
        
        tmpDouble = JSONData["Low"] as! Double
        var LowPrice:String = String(format:"%.2f", tmpDouble)
        LowPrice = "$ "+LowPrice
        result.append(["Low Price":LowPrice])
        
        tmpDouble = JSONData["Open"] as! Double
        var OpenPrice:String = String(format:"%.2f", tmpDouble)
        OpenPrice = "$ "+OpenPrice
        result.append(["Opening Price":OpenPrice])
        
        
        return result
        //var LP:String = String(format:"%.2f", JSONData["LastPrice"])
    }
    
    

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
       
            let cell = tableView.dequeueReusableCellWithIdentifier("detailCell", forIndexPath: indexPath) as! CustomDetailTableCell
        
            let Name=Array(self.detailTableData[indexPath.row].keys)[0]
            cell.itemName.text=Name
           // print(cell.itemName.text)
            let Value=Array(self.detailTableData[indexPath.row].values)[0]
            cell.itemValue.text=Value
          // follow is get the the value from the dictionary
           // cell.itemValue.text=Array(self.detailTableData.values)[indexPath.row]
         if Name.rangeOfString("Change") != nil {
            //print(Name.rangeOfString("Change"))
            //let firstCharacter=String(Value.characters.suffix(4))
//            let firstCharacter=Array(:Name)[0]
//            print(firstCharacter)
            if Value.rangeOfString("-") != nil{
                cell.arrow.image=UIImage(named:"Down-104")
            }
            else{
                 cell.arrow.image=UIImage(named:"Up-104")
            }
         }
           // print(cell.itemValue.text)
            //cell.label.text = detailTabledata[indexPath.row]
        cell.layoutMargins = UIEdgeInsetsZero
        return cell
    }
//
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
              //print(detailTableData.count)
              return self.detailTableData.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier=="CurrentToHist"{
            let historicalChart:HistoricalChartViewController=segue.destinationViewController as! HistoricalChartViewController
            historicalChart.symbol=self.symbol
            let backItem = UIBarButtonItem()
            backItem.title = "Back"
            navigationItem.backBarButtonItem = backItem
            
        }
        
        if segue.identifier=="CurrentToNews"{
            let newsFeed:NewsViewController=segue.destinationViewController as! NewsViewController
            newsFeed.symbol=self.symbol
            let backItem = UIBarButtonItem()
            backItem.title = "Back"
            navigationItem.backBarButtonItem = backItem
        }
        
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        let indexOfSelf = self.navigationController?.viewControllers.indexOf(self)
        if indexOfSelf != nil && viewFlag == 0 {
        self.navigationController?.viewControllers.removeAtIndex(indexOfSelf!)
        }
        viewFlag = 0
    }
    
//    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
//       
//        cell.layoutMargins = UIEdgeInsetsZero
//      
//    }
    
//    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        if section == 0{
//            return "DATA 0"
//        }
//        return "Data 1"
//    }
//    
//    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        print("selected \(indexPath.section) section and \(indexPath.row )")
//    }

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
