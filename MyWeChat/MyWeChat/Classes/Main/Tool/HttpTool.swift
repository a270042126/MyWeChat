//
//  HttpTool.swift
//  MyWeChat
//
//  Created by GDG on 16/1/5.
//  Copyright © 2016年 MyWeChat. All rights reserved.
//

import UIKit

typealias HttpToolProgressBlock = (_:CGFloat)->Void
typealias HttpToolCompletionBlock = (_:NSError?) -> Void

class HttpTool: NSObject,NSURLSessionDownloadDelegate,NSURLSessionTaskDelegate {
    
    private struct Static{
        static let kTimeOut = 5.0
    }
    
    private var downloadProgressBlock:HttpToolProgressBlock?
    private var downloadCompletionBlock:HttpToolCompletionBlock?
    private var uploadProgressBlock:HttpToolProgressBlock?
    private var uploadCompletionBlock:HttpToolCompletionBlock?
    private var downloadURL:NSURL?

    //上传
    func uploadData(data:NSData?,url:NSURL?,progressBlock:HttpToolProgressBlock?,completionBlock:HttpToolCompletionBlock?){
        assert(data != nil, "上传数据不能为空")
        assert(url != nil, "上传文件路径不能为空")
        let request = NSMutableURLRequest(URL: url!, cachePolicy: .UseProtocolCachePolicy, timeoutInterval: Static.kTimeOut)
        request.HTTPMethod = "PUT"
        
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config, delegate: self, delegateQueue: NSOperationQueue())
        
        //定义下载操作
        let uploadTask = session.uploadTaskWithRequest(request, fromData: data!)
        uploadTask.resume()
        
    }
    
    //下载
    func downLoadFromUrl(url:NSURL?,progressBlock:HttpToolProgressBlock,completionBlock:HttpToolCompletionBlock){
        assert(url != nil, "下载URL不能传空")
        downloadURL = url
        downloadProgressBlock = progressBlock
        downloadCompletionBlock = completionBlock
        
        let request = NSURLRequest(URL: url!, cachePolicy: .UseProtocolCachePolicy, timeoutInterval: Static.kTimeOut)
        
        //发送同步请求
        var session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { (data, response, connectionErr) -> Void in
            
            if response?.expectedContentLength <= 0{
                let error = NSError(domain: "文件不存在", code: 404, userInfo: nil)
                self.downloadCompletionBlock?(error)
                self.downloadCompletionBlock = nil
                self.downloadProgressBlock = nil
                return;
            }
            
        }
        task.resume()
        
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        session = NSURLSession(configuration: config, delegate: self, delegateQueue: NSOperationQueue())
        //定义下载操作
        let downloadTask = session.downloadTaskWithRequest(request)
        downloadTask.resume()
    }
    
    func fileSavePath(fileName:String?) -> String{
        let document = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first
        //图片保存在沙盒的Doucument下
        return (document! as NSString).stringByAppendingPathComponent(fileName!)
    }
    
    //MARK: - 上传代理
    //上传进度
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        
        let progress = totalBytesSent / totalBytesExpectedToSend
        uploadProgressBlock?(CGFloat(progress))
    }
    
    //上传完成
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        uploadCompletionBlock?(error)
        uploadProgressBlock = nil
        uploadCompletionBlock = nil
    }
    
    //MARK: - NSURLSessionDownloadDelegate
    //下载完成
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        //图片保存在沙盒的Doucument下
        let fileSavePath = self.fileSavePath(downloadURL?.lastPathComponent)
        //文件管理
        let fileManager = NSFileManager.defaultManager()
        do{
            try fileManager.copyItemAtURL(location, toURL: NSURL(fileURLWithPath: fileSavePath))
        }catch{}
        //通知下载成功，没有没有错误
        downloadCompletionBlock?(nil)
        downloadCompletionBlock = nil
        downloadProgressBlock = nil
    }
    
    //下载进度
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let progress = totalBytesExpectedToWrite / totalBytesWritten
        downloadProgressBlock?(CGFloat(progress))
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        
    }
    
}
