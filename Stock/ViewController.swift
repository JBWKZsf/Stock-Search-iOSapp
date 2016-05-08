//
//  ViewController.swift
//  Stocksearch
//
//  Created by WangZhonghao on 4/11/16.
//  Copyright © 2016 WangZhonghao. All rights reserved.
//

import UIKit
import CCAutocomplete
import CoreData
import Foundation
import FBSDKCoreKit
import FBSDKLoginKit
import FBSDKShareKit



class ViewController: UIViewController, detailDataDelegate, UITableViewDataSource, UITableViewDelegate{

    @IBOutlet weak var textInput: UITextField!
   
    @IBOutlet weak var favouriteTable: UITableView!
    
    @IBOutlet weak var autoRefreshSwitch: UISwitch!
    
    var favouriteListData:Array<Dictionary<String,String>> = []
    
    var isFirstLoad: Bool = true
   
    var symbolToBeSend:String = ""
    
    var autoCompleteOptionNum:Int = 0
    
    var autoRefreshTimer:NSTimer = NSTimer()
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        //self.favouriteTable.layoutMargins = UIEdgeInsetsZero
        //self.favouriteTable.cellLayoutMarginsFollowReadableWidth = false
        // Do any additional setup after loading the view, typically from a nib.
        self.textInput.backgroundColor=UIColor.whiteColor()
        self.textInput.borderStyle=UITextBorderStyle.None
        activityIndicatorView.hidden = true
        getFavouriteListData()
        showActivityIndicatory(self.view)
    //        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboard))
//        view.addGestureRecognizer(tap)
    }
    //When tap the screen outside the textfield
    //Calls this function when the tap is recognized.
//    func dismissKeyboard() {
//        //Causes the view (or one of its embedded text fields) to resign the first responder status.
//        view.endEditing(true)
//    }

    func showActivityIndicatory(uiView: UIView) {
        uiView.addSubview(activityIndicatorView)
    }
    
    func addOrRemoveFavouriteList(object:Dictionary<String,String>) {
        if object.count>1 {
            favouriteListData.append(object)
        }
        else{
            let symbolToBeRemoved = object["Symbol"]!
            removeFromFLData(symbolToBeRemoved)
        }
     
         self.favouriteTable.reloadData()
    }
    
    func removeFromFLData(symbolToBeRemoved:String) {
        //print(favouriteListData.count)
        for i in 0 ..< favouriteListData.count {
            if favouriteListData[i]["Symbol"]==symbolToBeRemoved {
                favouriteListData.removeAtIndex(i)
                break
            }
        }
    }
    
    @IBAction func getQuote(sender: UIButton) {
        
        if textInput.text=="" {
            let emptyAlert = UIAlertController(title: "Please Enter a Stock Name or Symbol", message: "", preferredStyle:UIAlertControllerStyle.Alert)
            emptyAlert.addAction(UIAlertAction(title:"OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(emptyAlert,animated:true,completion:nil)
            return
        }
       
        
        let JSONDataForLookup=AutoCompleteDataRequest.getJSONData(textInput.text!)
        var options:Array<String>=[]
        for anItem in JSONDataForLookup as! [Dictionary<String, AnyObject>] {
            let Symbol = anItem["Symbol"] as! String
            let anOption = Symbol
            options.append(anOption)
        }
        if !options.contains(textInput.text!.uppercaseString) {
            let invalidAlert = UIAlertController(title: "Invalid Symbol", message: "", preferredStyle:UIAlertControllerStyle.Alert)
            invalidAlert.addAction(UIAlertAction(title:"OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(invalidAlert,animated:true,completion:nil)
            return

        }

        
        let JSONDataForValidation=SycDetailDataRequest.getJSONData(textInput!.text!)
        //print(JSONDataForValidation)
        if JSONDataForValidation.count<=1||JSONDataForValidation["Status"] as! String != "SUCCESS"  {
            
            let noDataAlert = UIAlertController(title: "No detail stock data of this company", message: "", preferredStyle:UIAlertControllerStyle.Alert)
            noDataAlert.addAction(UIAlertAction(title:"OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(noDataAlert,animated:true,completion:nil)
            return
        }
        
        
        
//        let dataRequest = AsycDetailTableDataRequest(symbol: textInput.text!)
//        dataRequest.getData({data,error-> Void in
//            if(data != nil){
//                if data.count>1 && data["Status"] as! String == "SUCCESS" {
//                    
//                }
//                if data.count <= 1{
//                    let noDataAlert = UIAlertController(title: "No detail stock data of this company", message: "", preferredStyle:UIAlertControllerStyle.Alert)
//                    noDataAlert.addAction(UIAlertAction(title:"OK", style: UIAlertActionStyle.Default, handler: nil))
//                    self.presentViewController(noDataAlert,animated:true,completion:nil)
//                    //self.presentViewController(self,animated:false,completion: nil)
//                    return
//                }
//            }
//        })

        self.symbolToBeSend = self.textInput.text!
        performSegueWithIdentifier("showDetailView", sender: self)

        
        
    }
    
    
    @IBAction func autoRefreshTapped(sender: AnyObject) {
        if autoRefreshSwitch.on {
            autoRefreshTimer = NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: #selector(ViewController.updateTheFLData), userInfo: nil, repeats: true)
        }
        else{
            autoRefreshTimer.invalidate()
        }
        
    }
    
    func updateTheFLData(){
        activityIndicatorView.hidden = false
        activityIndicatorView.startAnimating()
        for i in 0..<favouriteListData.count{
            let symbol = favouriteListData[i]["Symbol"]!
            
            let dataRequest = AsycDetailTableDataRequest(symbol: symbol)
            dataRequest.getData({data,error-> Void in
                if(data != nil){
                    let ORIGTableData = data
                    let oneCompanyData = self.sharpAndPickTheData(ORIGTableData)
                    //print(oneCompanyData)
                    self.favouriteListData[i]["Change"] = oneCompanyData["Change"]
                    self.favouriteListData[i]["Last Price"] = oneCompanyData["Last Price"]
                    self.favouriteListData[i]["Market Cap"] = oneCompanyData["Market Cap"]
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        
                        self.favouriteTable.reloadData()
                        if i == self.favouriteListData.count-1 {
                            sleep(1)
                            self.activityIndicatorView.stopAnimating()
                            self.activityIndicatorView.hidden=true
                        }
                        
                    }
                    
                    
                }
            })
        }
    }
    
    @IBAction func refresh(sender: UIButton) {
        
        updateTheFLData()
    }
    
    func removeFromCoreData(symbolToBeDelete:String)  {
        let moc = DataController().managedObjectContext
        
        do{
            let favouriteFetch = NSFetchRequest(entityName:"FavouriteList")
            let fetchedData = try moc.executeFetchRequest(favouriteFetch)
            
            if fetchedData.count > 0{
                for item in fetchedData as! [NSManagedObject]{
                    let symbolObject = item.valueForKey("companySymbol")
                    if symbolObject != nil {
                        let symbolInCoreData = symbolObject as! String
                        if symbolInCoreData == symbolToBeDelete {
                            
                            moc.deleteObject(item as NSManagedObject)
                            //print("delete the "+symbolInCoreData)
                            
                          do{
                                try moc.save()
                            }catch{
                                fatalError("failure to save context:\(error)")
                            }
                        }
                  }
                }
            }
            
        }catch{
            print("There was an error.")
        }

    
    
        //print the coredata when delete from favourite list
//        do{
//            let favouriteFetch = NSFetchRequest(entityName:"FavouriteList")
//            let fetchedData = try moc.executeFetchRequest(favouriteFetch)
//            
//            if fetchedData.count > 0{
//                for item in fetchedData as! [NSManagedObject]{
//                    let symbol2 = item.valueForKey("companySymbol")
//                    if symbol2 == nil {
//
//                    }
//                    print("core data now contains:\(symbol2)")
//                }
//            }
//            
//        }catch{
//            print("There was an error.")
//        }


    }
    
    
    
    
    func getFavouriteListData() {
        
        let moc = DataController().managedObjectContext
        
        do{
            let favouriteFetch = NSFetchRequest(entityName:"FavouriteList")
            let fetchedData = try moc.executeFetchRequest(favouriteFetch)
            
            if fetchedData.count > 0{
                for item in fetchedData as! [NSManagedObject]{
                    let symbolObject = item.valueForKey("companySymbol")
                    if symbolObject != nil {
                 
                     let symbol = symbolObject as! String
                    
                        
                        //asychronous to get the favourite list data
//                        let dataRequest = AsycDetailTableDataRequest(symbol: symbol)
//                        dataRequest.getData({data,error-> Void in
//                            if(data != nil){
//                                let ORIGTableData = data
//                                print(ORIGTableData)
//                                let oneCompanyData = self.sharpAndPickTheData(ORIGTableData)
//                                print(oneCompanyData)
//                                self.favouriteListData.append(oneCompanyData)
//                                dispatch_async(dispatch_get_main_queue()) { [unowned self] in
//                                    self.favouriteTable.reloadData()
//                                }
//                            }
//                        })

                    
                    
                    //fell like synchronous is better for the order of favourite list
                   
                    let ORIGTableData = DetailTableDataRequest.getJSONData(symbol) as! Dictionary<String, AnyObject>
                        
                        
                    //print(ORIGTableData)
                    //print("favouritelist now contains:\(symbol)")
                     let oneCompanyData = sharpAndPickTheData(ORIGTableData)
                     favouriteListData.append(oneCompanyData)
                    //print(favouriteListData)
                 }
                }
            }
            
        }catch{
            print("There was an error.")
        }

        
    }
    
    
    func sharpAndPickTheData(orignalData:Dictionary<String,AnyObject>) -> Dictionary<String,String> {
        var result:Dictionary<String, String> = [:]
        let Symbol = orignalData["Symbol"] as? String
        result["Symbol"]=Symbol
        
        var  tmpDouble:Double = orignalData["LastPrice"] as! Double
        var LastPrice:String = String(format:"%.2f", tmpDouble)
        LastPrice = "$ "+LastPrice
        result["Last Price"] = LastPrice
        
        tmpDouble = orignalData["Change"] as! Double
        var flag1:String=""
        if tmpDouble>0 {
            flag1 = "+"
        }
        let Change:String = flag1+String(format:"%.2f", tmpDouble)
        tmpDouble = orignalData["ChangePercent"] as! Double
        let ChangePercent:String=String(format:"%.2f", tmpDouble)
        let ChangeCombine=Change+"("+ChangePercent+"%)"
        result["Change"] = ChangeCombine

        let Name = orignalData["Name"] as? String
        result["Name"] = Name
        
        var MktmpDouble:Double=orignalData["MarketCap"] as! Double
        var MarketCap:String=""
        if MktmpDouble > 1000000000000.0 {
            MktmpDouble=MktmpDouble/1000000000000.0
            MarketCap=String(format:"%.2f", MktmpDouble)+" Trilliion"
        }
        else if MktmpDouble>1000000000.0 {
            MktmpDouble=MktmpDouble/1000000000.0
            MarketCap=String(format:"%.2f", MktmpDouble)+" Billiion"
        }
        else if MktmpDouble>1000000.0 {
            MktmpDouble=MktmpDouble/1000000.0
            MarketCap=String(format:"%.2f", MktmpDouble)+" Milliion"
        }
        else{
            MarketCap=String(format:"%.2f",MktmpDouble)
        }
        result["Market Cap"] = MarketCap

        
        return result
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.1
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if self.isFirstLoad {
            self.isFirstLoad = false
            Autocomplete.setupAutocompleteForViewcontroller(self)
        }
    }
    
    
    override func viewWillAppear(animated: Bool)
    {
        self.navigationController?.navigationBarHidden = true
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier=="showDetailView"{
            let detailView:StatisticViewController=segue.destinationViewController as! StatisticViewController
            

            detailView.delegate = self
            detailView.symbol=symbolToBeSend.uppercaseString
         }
        
        
        //regular expression
//        do{
//          let regex = try NSRegularExpression(pattern: "(?:[A-Z]+)", options: [])
//          let companyWholeName=self.textInput.text!
//          let result=regex.matchesInString(companyWholeName, options: [], range: NSRange(location: 0, length: companyWholeName.characters.count))
//          symbol.text = result
//        }
//        catch let error as NSError{
//            print("error")
//        }
//        var result=""
        
    }
    
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("favouriteTableCell", forIndexPath: indexPath) as! CustomFavouriteTableCell
        
        let symbol = self.favouriteListData[indexPath.row]["Symbol"]
        cell.symbol.text = symbol

        let stockValue=self.favouriteListData[indexPath.row]["Last Price"]
        cell.stockValue.text = stockValue

        let change = self.favouriteListData[indexPath.row]["Change"]
        cell.change.text = change

        let name = self.favouriteListData[indexPath.row]["Name"]
        cell.name.text = name

        let marketCap = "Market Cap: "+self.favouriteListData[indexPath.row]["Market Cap"]!
        cell.MarketCap.text=marketCap
        
        if change!.rangeOfString("-") != nil{
            cell.change.backgroundColor=UIColor(red: 230/255, green:68/255, blue: 60/255, alpha:1)
        }
        else{
            cell.change.backgroundColor=UIColor(red: 44/255, green:164/255, blue: 90/255, alpha:1)
        }

        cell.layoutMargins = UIEdgeInsetsZero
        cell.preservesSuperviewLayoutMargins = false
        
        return cell
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favouriteListData.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        symbolToBeSend = self.favouriteListData[indexPath.row]["Symbol"]!
        
        performSegueWithIdentifier("showDetailView", sender: self)
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete{
            removeFromCoreData(self.favouriteListData[indexPath.row]["Symbol"]!)
            favouriteListData.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
    }


}

extension ViewController:AutocompleteDelegate{
    func autoCompleteTextField() -> UITextField {
        return self.textInput
    }
    func autoCompleteThreshold(textField: UITextField) -> Int {
        return 2
    }
    
    func autoCompleteHeight() -> CGFloat {
        return CGRectGetHeight(self.view.frame) / 3.0
    }
    
    
    func didSelectItem(item: AutocompletableOption) {
        var outPut=""
        for char in item.text.characters {
            if (char >= "A" && char <= "z"){
                outPut.append(char)
            }
            else{
                break
            }
        }

        self.textInput.text = outPut
    }
    
}

