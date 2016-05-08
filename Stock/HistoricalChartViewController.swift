//
//  HistoricalChartViewController.swift
//  Stock
//
//  Created by WangZhonghao on 4/20/16.
//  Copyright © 2016 WangZhonghao. All rights reserved.
//

import UIKit

class HistoricalChartViewController: UIViewController {

    @IBOutlet weak var historicalChartWebView: UIWebView!
    @IBOutlet weak var historicalButton: UIButton!
    
    var symbol:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        historicalButton.backgroundColor = UIColor(red: 13/255, green:102/255, blue: 255/255, alpha:1)
        historicalButton.layer.cornerRadius=5
         self.title = symbol
        
//        let url = NSURL (string: "http://www.kickstarter.com");
//        let requestObj = NSURLRequest(URL: url!);
//        historicalChartWebView.loadRequest(requestObj);
        let localHTML = NSBundle.mainBundle().URLForResource("historicalChart", withExtension: "html")
        let myRequest = NSURLRequest(URL: localHTML!)
          dispatch_async(dispatch_get_main_queue()) { [unowned self] in
      
        self.historicalChartWebView.loadRequest(myRequest)
        self.historicalChartWebView.stringByEvaluatingJavaScriptFromString("var Symbol='\(self.symbol)';")
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier=="HistToCurrent"{
             let detailView:StatisticViewController=segue.destinationViewController as! StatisticViewController
           detailView.symbol=self.symbol
            let backItem = UIBarButtonItem()
            backItem.title = "Back"
            navigationItem.backBarButtonItem = backItem
        }
       
        if segue.identifier=="HistToNews"{
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
