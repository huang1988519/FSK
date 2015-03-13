//
//  ResourceParser.swift
//  FSK
//
//  Created by 黄伟华 on 15/3/10.
//  Copyright (c) 2015年 黄伟华. All rights reserved.
//

import UIKit

typealias FuncBlock = (AnyObject?)-> Void

class ResourceParser: NSObject,UIWebViewDelegate{
    
    var operates = Dictionary<String,String>()
    
    var _getRealPathBlock : FuncBlock?
    
    var webView:UIWebView!
    
    
    func getRealPath(url:String,getRealPathBlock:FuncBlock?){
        _getRealPathBlock = getRealPathBlock
        
        
        var path = ResourceParser.getPathForURL(NSURL(string: url))
        
        if path == nil{
            _getRealPathBlock!(nil)
        }
        var manager:AFHTTPRequestOperationManager = AFHTTPRequestOperationManager()
        manager.responseSerializer.acceptableContentTypes = NSSet(object: "text/html")
        manager.GET(path, parameters: nil, success: { (operation, respond) -> Void in
            
            
            var result:NSDictionary? = respond as NSDictionary?
                println(result)
            if (result == nil || result?["data"]==nil){
                self._getRealPathBlock!(nil)
                return
            }
            var data:NSDictionary! = result!["data"] as NSDictionary!
            var file:String!  = data["f"] as String
            self._getRealPathBlock!(String(file))
            
            }) { (operation, error) -> Void in
                println(error)
        }
    }
    func getRealAddressByWeb(path:String,getRealPathBlock:FuncBlock){
        var url:NSURL! = NSURL(string: path)
        if url==nil{
            getRealPathBlock(nil)
        }
        println("解析web地址")
        
        if webView == nil{
            webView = UIWebView(frame: CGRectZero)
        }
        _getRealPathBlock = getRealPathBlock
        
        var delegate :AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        var windown:UIWindow! = delegate.window
        webView.delegate = self
        windown.addSubview(webView)
        var request:NSURLRequest = NSURLRequest(URL: url)
        webView.loadRequest(request)
    }
    
    
    func getNodeValue(url:String,getRealPathBlock:FuncBlock?){
        
        
        var path = ResourceParser.getPathForURL(NSURL(string: url))
        
        if path == nil{
            getRealPathBlock!(nil)
        }
        var manager:AFHTTPRequestOperationManager = AFHTTPRequestOperationManager()
        manager.responseSerializer.acceptableContentTypes = NSSet(object: "text/html")
        manager.GET(path, parameters: nil, success: { (operation, respond) -> Void in
            
            
            var result:NSDictionary? = respond as NSDictionary?
            println(result)
            if (result == nil || result?["data"]==nil){
                getRealPathBlock!(nil)
                return
            }
            var data:NSDictionary! = result!["data"] as NSDictionary!
            getRealPathBlock!(data)
            
            }) { (operation, error) -> Void in
                println(error)
        }
    }
    
    
    
    
    class func getPathForURL(url:NSURL!) -> String!{
        if url == nil{
            return nil
        }
        var host:String = url.host!
        
        if host == "v.youku.com"{
            println("解析优酷地址...")
            
            var video = url.lastPathComponent?.stringByReplacingOccurrencesOfString("id_", withString: "")
            
            var videoId = video!.componentsSeparatedByString(".").first
            
            var timeStamp = NSDate().timeIntervalSince1970
            var videoPath = "http://pl.youku.com/playlist/m3u8?ts=\(timeStamp)&keyframe=0&vid=\(String(videoId!))&type=mp4"

            return videoPath
        }else if(host == "v.ku6.com"){
            println("解析酷六地址...")

            
            var lastComponent:String! = url.lastPathComponent
            
            if  lastComponent == nil{
                return nil
            }
            
            return "http://v.ku6.com/fetchVideo4Player/\(lastComponent)"
        }
        
        return nil
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        println("请求:\(webView.request)")
    }
    func webViewDidFinishLoad(webView: UIWebView) {

        
        println("web解析成功")
        
        webView.removeFromSuperview()
        var resultPath:String! = webView.stringByEvaluatingJavaScriptFromString("var videoNode =document.getElementById(\"video\");videoNode.firstChild.src")
        if (_getRealPathBlock==nil || resultPath==nil || resultPath.isEmpty || resultPath.hasSuffix("m3u8")==false){
            println("未找到m3u8，继续请求")
        }else{
            _getRealPathBlock!(resultPath)

            webView.delegate = nil
            _getRealPathBlock = nil
        }
    }
    func webView(webView: UIWebView, didFailLoadWithError error: NSError) {

        webView.removeFromSuperview()
        
        if error.code == -999 //由于url跳转，所有这个不是错误
        {
            return
        }
        
        var alert:UIAlertView = UIAlertView(title: "提示", message: "地址解析失败", delegate: nil, cancelButtonTitle: "确定")
        alert.show()
        
        println("web解析失败 \(error)")
        if (_getRealPathBlock==nil){
        }else{
            _getRealPathBlock!(nil)
        }
    }
}
