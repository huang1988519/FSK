//
//  ViewController.swift
//  FSK
//
//  Created by 黄伟华 on 15/3/9.
//  Copyright (c) 2015年 黄伟华. All rights reserved.
//

import UIKit
import MediaPlayer

class ViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,UMUFPHandleViewDelegate,MMUBannerViewDelegate {
    @IBOutlet var tableView: UITableView!

    @IBOutlet var adView: UIView!

    var viewCount : Int = 1

    
    var inputDic:NSDictionary!
    var op:AFHTTPRequestOperation!
    
    
    var listArray:NSMutableArray!
    
    var nodesDic = Dictionary<String,Dictionary<String,AnyObject>>()
    
    var nodeNSDic:NSMutableDictionary!
    var requestDic:NSMutableDictionary!

    
    var handleView:UMUFPHandleView!
    var bottomBanner:MMUBannerView!
    var parser:ResourceParser!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "列表"
        
        nodeNSDic = NSMutableDictionary()
        requestDic = NSMutableDictionary()
        
        listArray = NSMutableArray()
        
        
        bottomBanner = MMUBannerView(frame: CGRectMake(0, 0, 320, 50), slotId: "65065", currentViewController: self)
        bottomBanner.delegate = self
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
        bottomBanner.frame = adView.bounds;

        handleView.frame = CGRectMake(CGRectGetWidth(self.view.frame)-64, CGRectGetHeight(self.tableView.frame)-64, 44, 44)
        handleView.clipsToBounds = true
        handleView.layer.cornerRadius = 44/2
    }
    
    func request(){
        if inputDic==nil {return}
        
        var type:String = inputDic["typeId"] as! String
        
        var url:NSURL! = NSURL(string: "http://104.224.139.177/fsk_mobile.php?type=\(type)")
        var request:NSURLRequest = NSURLRequest(URL: url, cachePolicy: NSURLRequestCachePolicy.UseProtocolCachePolicy, timeoutInterval: 10)
        
        op = AFHTTPRequestOperation(request: request)
        op.responseSerializer = AFJSONResponseSerializer()
        op.responseSerializer.acceptableContentTypes = NSSet(object: "text/html") as Set<NSObject>
        
        op.setCompletionBlockWithSuccess({ (opation, respondObject) -> Void in
            
            var result:NSDictionary? = respondObject as! NSDictionary?
            println(result)
            if (result == nil || result?["result"]==nil){
                return
            }
            var data:[AnyObject] = result!["result"] as! [AnyObject]
            self.listArray.removeAllObjects()
            self.listArray.addObjectsFromArray(data)
            
            self.tableView.reloadData()
            }, failure: { (opation, error) -> Void in
                println("网络错误\n\n \(error)")
        })
        NSOperationQueue.mainQueue().addOperation(op)
    }
    
    func parseAddress(dic:NSDictionary){
        parser = ResourceParser()
        
        var urlString:String = dic["url"] as! String
        self.showHUDWithMessage("加载中...")
        parser.getRealAddressByWeb(urlString, getRealPathBlock: { (realPath) -> Void in

            self.hideHUD()
            var path :String! = realPath as! String!
            println("realPath\n \(path)\n")
            if path == nil{
                return
            }
            
            
            var player:MPMoviePlayerViewController = MPMoviePlayerViewController(contentURL: NSURL(string: path))
           
            self.navigationController?.presentMoviePlayerViewControllerAnimated(player)
            /*
            self.player = PlayerController()
            self.player.urlPath = path
            self.navigationController?.presentMoviePlayerViewControllerAnimated()(self.player, animated: true, completion: nil)
*/
            /*
            var player:PlayerViewController = PlayerViewController()
            player.mediaPath = path
            self.navigationController?.presentViewController(player, animated: true, completion: nil)
*/
        })
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var urlPath:NSDictionary! = listArray[indexPath.row] as! NSDictionary
        self.parseAddress(urlPath)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listArray.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:IndexCell = tableView.dequeueReusableCellWithIdentifier("cell") as! IndexCell
        
        
        var dic:NSDictionary = listArray[indexPath.row] as! NSDictionary
        var urlPath:String = dic["url"] as! String
        
        var node:Dictionary<String,String>!  = nodesDic[String(indexPath.row)] as! Dictionary<String,String>?
        
        if nodeNSDic[String(indexPath.row)] == nil {
            cell.cus_titleLabel?.text = "加载中..."
            
            var parser:ResourceParser = ResourceParser()
            parser.getNodeValue(urlPath, getRealPathBlock: { (nodeDic) -> Void in
                var dic = nodeDic as! NSDictionary
                self.nodeNSDic.setObject(dic, forKey: String(indexPath.row))
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    self.tableView.reloadData()
                })
            })
            requestDic.setObject(parser, forKey: (indexPath.row))
            
        }else{
            var nodeNS:NSDictionary! = nodeNSDic[String(indexPath.row)] as! NSDictionary
            
            cell.cus_titleLabel?.text = nodeNS["t"] as! String!
            cell.cus_detailLabel?.text = nodeNS["desc"] as! String!
            
            var imagePath:String = nodeNS["bigpicpath"] as! String!
            cell.cus_imageView?.sd_setImageWithURL(NSURL(string: imagePath))
        }
        println("node: \(node)")
        return cell
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }
    
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        return UIInterfaceOrientation.Portrait
    }
    


    /*
    func getSid() -> NSTimeInterval{
        var tiemSpace: NSTimeInterval =  NSDate().timeIntervalSince1970
        return tiemSpace
    }
    
    func getFileid(fileId:String,seed:String) ->String {
        var mixed = getMixString(seed)
        var ids:Array = fileId.componentsSeparatedByString("*")
        
        var realId = ""
        for string:String in ids{
            var subString = (mixed as NSString).substringWithRange(NSMakeRange(string.toInt()!,1))
            realId.stringByAppendingString(subString)
            
        }
        
        return realId
    }
    
    func getMixString(seed:String) -> String {
        var mixed = ""
        var source: String = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ/\\:._-1234567890"
        
        var length:Int = source.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
        
        for i in 0...(length-1){
            println(i)
            var number:Int = seed.toInt()!
            number = (number * 211 + 30031)%65536
            number = number/65536 * length
            
            var c = (source as NSString).substringWithRange(NSMakeRange(number,1))
            mixed.stringByAppendingString(c)
            
            source = source.stringByReplacingOccurrencesOfString(source, withString: "")
        }
        return mixed
    }
    */

}

