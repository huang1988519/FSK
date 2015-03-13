//
//  IndexTableController.swift
//  FSK
//
//  Created by 黄伟华 on 15/3/11.
//  Copyright (c) 2015年 黄伟华. All rights reserved.
//

import UIKit
import GoogleMobileAds
class IndexTableController: UITableViewController ,GADInterstitialDelegate{

    var listArray:NSMutableArray!
    var op:AFHTTPRequestOperation!
    
    var reviewCount = 0

    
    @IBOutlet var bannerView: GADBannerView!
    @IBOutlet var bottomBannerView:GADBannerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        listArray = NSMutableArray()
        self.bannerView.adUnitID = "ca-app-pub-9740809110396658/5834852722"
        self.bannerView.rootViewController = self
        var deviceRequest:GADRequest = GADRequest()
        self.bannerView.loadRequest(deviceRequest)
        
        self.bottomBannerView.adUnitID = "ca-app-pub-9740809110396658/5878551923"
        self.bottomBannerView.rootViewController = self
        var bottomRequest:GADRequest = GADRequest()
        self.bottomBannerView.loadRequest(bottomRequest)
        
        self.navigationItem.title = "首页"
        
        var refreshBtn:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: "refresh")
        self.navigationItem.rightBarButtonItem = refreshBtn
        
        request()
    }
    
    func refresh(){
        request()
    }
    
    func request(){
        var url:NSURL! = NSURL(string: "http://104.224.139.177/fsk.php")
        var request:NSURLRequest = NSURLRequest(URL: url, cachePolicy: NSURLRequestCachePolicy.UseProtocolCachePolicy, timeoutInterval: 5)
        
        op = AFHTTPRequestOperation(request: request)
        op.responseSerializer = AFJSONResponseSerializer()
        op.responseSerializer.acceptableContentTypes = NSSet(object: "text/html")

        op.setCompletionBlockWithSuccess({ (opation, respondObject) -> Void in
            
            var result:NSDictionary? = respondObject as NSDictionary?
            println(result)
            if (result == nil || result?["result"]==nil){
                return
            }
            var data:NSArray! = result!["result"] as NSArray!
            self.listArray.removeAllObjects()
            self.listArray.addObjectsFromArray(data)
            
            self.tableView.reloadData()
            
        }, failure: { (opation, error) -> Void in
            println("网络错误\n\n \(error)")
        })
        NSOperationQueue.mainQueue().addOperation(op)
    }

    func interstitialDidReceiveAd(ad: GADInterstitial!) {
        ad.presentFromRootViewController(self)
    }
    func interstitial(ad: GADInterstitial!, didFailToReceiveAdWithError error: GADRequestError!) {
        println("GAD \(error)")
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        reviewCount++
        super.prepareForSegue(segue, sender: sender)

        
        var toCtrl:UIViewController! = segue.destinationViewController as UIViewController
        if toCtrl is ViewController{
            
            var indexPath: NSIndexPath = self.tableView.indexPathForSelectedRow()!
            
            var dic:NSDictionary! = listArray[indexPath.row] as NSDictionary
            
            
            var ctrl:ViewController! = segue.destinationViewController as ViewController
            ctrl.inputDic = dic
            ctrl.viewCount=reviewCount
        }

        
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return listArray.count
    }
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 150
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("author", forIndexPath: indexPath) as AuthorCell
        
        var dic:NSDictionary! = listArray[indexPath.row] as NSDictionary
        if dic==nil{
            cell.cus_imageView.sd_setImageWithURL(NSURL(string: "http://file3.u148.net/2012/9/images/1347177504805.jpg"))
        }else{
            cell.cus_imageView.sd_setImageWithURL(NSURL(string: dic["cover"] as String))
        }
        cell.cus_titleLabel.text = dic["title"] as String!
        
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
