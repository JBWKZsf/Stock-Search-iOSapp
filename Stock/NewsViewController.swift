//
//  NewsViewController.swift
//  Stock
//
//  Created by WangZhonghao on 4/20/16.
//  Copyright © 2016 WangZhonghao. All rights reserved.
//

import UIKit

class NewsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var newsButton: UIButton!
    
    @IBOutlet weak var newsTable: UITableView!
    var symbol = ""
    
    var newsData:Array<Dictionary<String, AnyObject>> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        newsButton.backgroundColor = UIColor(red: 13/255, green:102/255, blue: 255/255, alpha:1)
        newsButton.layer.cornerRadius=5
        self.title = symbol
        
        
        let dataRequest = AsycNewsDataRequest(symbol: symbol)
        dataRequest.getData({data,error-> Void in
            if(data != nil){
                //print(data)
                let orignalData = data["d"]!
//
                self.newsData=orignalData["results"] as! Array<Dictionary<String,AnyObject>>
                //print(self.newsData)
                dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                    self.newsTable.reloadData()
                }
             
            }
        })

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("newsTableCell", forIndexPath: indexPath) as! CustomNewsTableCell
        cell.newsTitle.text=newsData[indexPath.row]["Title"] as? String
        cell.newsContent.text=newsData[indexPath.row]["Description"] as? String
        cell.newsSource.text=newsData[indexPath.row]["Source"] as? String
        
        let tmpString = newsData[indexPath.row]["Date"] as? String
        
        let dateFormatter1 = NSDateFormatter()
        // dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter1.dateFormat="yyyy-MM-dd'T'HH:mm:sszzz"
        let origDate=dateFormatter1.dateFromString(tmpString!)
        let dateFormatter2 = NSDateFormatter()
        
        dateFormatter2.dateFormat = "yyyy-MM-dd HH:mm"
        let dateSTRING:String = dateFormatter2.stringFromDate(origDate!)
        cell.newsDate.text=dateSTRING
//        let Name=Array(self.detailTableData[indexPath.row].keys)[0]
//        cell.itemName.text=Name
//        // print(cell.itemName.text)
//        let Value=Array(self.detailTableData[indexPath.row].values)[0]
//        cell.itemValue.text=Value
//        // follow is get the the value from the dictionary
//        // cell.itemValue.text=Array(self.detailTableData.values)[indexPath.row]
//        if Name.rangeOfString("Change") != nil {
//            //print(Name.rangeOfString("Change"))
//            //let firstCharacter=String(Value.characters.suffix(4))
//            //            let firstCharacter=Array(:Name)[0]
//            //            print(firstCharacter)
//            if Value.rangeOfString("-") != nil{
//                cell.arrow.image=UIImage(named:"Down-104")
//            }
//            else{
//                cell.arrow.image=UIImage(named:"Up-104")
//            }
//        }
//        // print(cell.itemValue.text)
//        //cell.label.text = detailTabledata[indexPath.row]
        cell.layoutMargins = UIEdgeInsetsZero
        return cell
    }
    //
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print(detailTableData.count)
        return self.newsData.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
       // print("You selected cell \(indexPath.row)")
        
        let linkString = self.newsData[indexPath.row]["Url"] as! String
        //print(linkString)
        if let url = NSURL(string: linkString){
            UIApplication.sharedApplication().openURL(url)
        }
    }

    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier=="NewsToCurrent"{
            let detailView:StatisticViewController=segue.destinationViewController as! StatisticViewController
            detailView.symbol=self.symbol
            let backItem = UIBarButtonItem()
            backItem.title = "Back"
            navigationItem.backBarButtonItem = backItem
            
            
        }
        
        if segue.identifier=="NewsToHist"{
            let historicalChart:HistoricalChartViewController=segue.destinationViewController as! HistoricalChartViewController
            historicalChart.symbol=self.symbol
            let backItem = UIBarButtonItem()
            backItem.title = "Back"
            navigationItem.backBarButtonItem = backItem
        }
        
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        let indexOfSelf = self.navigationController?.viewControllers.indexOf(self)
        if indexOfSelf != nil{
            self.navigationController?.viewControllers.removeAtIndex(indexOfSelf!)
        }

    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
