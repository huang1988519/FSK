//
//  IndexTableController.swift
//  FSK
//
//  Created by 黄伟华 on 15/3/11.
//  Copyright (c) 2015年 黄伟华. All rights reserved.
//

import UIKit
class IndexTableController: UIViewController ,MMUBannerViewDelegate,UMUFPHandleViewDelegate,UITableViewDelegate,UITableViewDataSource{

    var listArray:NSMutableArray!
    var op:AFHTTPRequestOperation!
    
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var adView: UIView!
    @IBOutlet var bottomBanner: MMUBannerView!
    
    var handleView:UMUFPHandleView!
    
    var reviewCount = 0


    //反馈
    @IBAction func feedback(sender: AnyObject) {
        self.navigationController?.pushViewController(UMFeedback.feedbackViewController(), animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        listArray = NSMutableArray()

        
        self.navigationItem.title = "首页"
        
        var refreshBtn:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: "refresh")
        self.navigationItem.rightBarButtonItem = refreshBtn

        var feedBackBtn:UIBarButtonItem = UIBarButtonItem(title: "反馈", style: UIBarButtonItemStyle.Plain, target: self, action: "feedback:")
        self.navigationItem.leftBarButtonItem = feedBackBtn
        
        MMUBannerView.setAppChannel("Appstore");
        
        bottomBanner = MMUBannerView(frame: CGRectMake(0, 0, 320, 50), slotId: "65065", currentViewController: self)
        bottomBanner.delegate = self
        bottomBanner.frame = adView.bounds;
        adView.addSubview(bottomBanner)
        bottomBanner.requestPromoterDataInBackground()
        
        
        //
        handleView = UMUFPHandleView(frame: CGRectMake(CGRectGetWidth(self.view.frame)-64, CGRectGetHeight(self.tableView.frame)-64, 44, 44), appKey: nil
            , slotId: "65066", currentViewController: self)
        handleView.delegate = self

        self.view.addSubview(handleView);
        handleView.requestPromoterDataInBackground()
        
        
        request()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        bottomBanner.frame = adView.bounds
        handleView.frame = CGRectMake(CGRectGetWidth(self.view.frame)-64, CGRectGetHeight(self.tableView.frame)-64, 44, 44)
        handleView.clipsToBounds = true
        handleView.layer.cornerRadius = 44/2
    }
    func refresh(){
        request()
    }
    
    func request(){
        var url:NSURL! = NSURL(string: "http://104.224.139.177/fsk_mobile.php")
        var request:NSURLRequest = NSURLRequest(URL: url, cachePolicy: NSURLRequestCachePolicy.UseProtocolCachePolicy, timeoutInterval: 5)
        
        op = AFHTTPRequestOperation(request: request)
        op.responseSerializer = AFJSONResponseSerializer()
        op.responseSerializer.acceptableContentTypes = NSSet(object: "text/html")

        op.setCompletionBlockWithSuccess({ (opation, respondObject) -> Void in
            self.hideHUD()
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
            self.hideHUD()
            println("网络错误\n\n \(error)")
        })
        self.showHUDWithMessage("加载中...")
        NSOperationQueue.mainQueue().addOperation(op)
    }



    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
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
     func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return listArray.count
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 150
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
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
    
    
    
    func bannerView(banner: MMUBannerView!, didLoadPromoterFailedWithError error: NSError!) {
        println("加载banner 失败  \(error)")
    }
    func bannerDidAppear(banner: MMUBannerView!) {
        println("banner 出现")
    }
    
    func didLoadDataFailWithError(handleView: UMUFPHandleView!, error: NSError!) {
        println("获取handle失败 \(error)")
    }
    func didLoadDataFinished(handleView: UMUFPHandleView!) {
        println("加载handle成功")
    }
}
