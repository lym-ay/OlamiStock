//
//  NetWorkAction.m
//  RemoteControl
//
//  Created by olami on 2017/8/4.
//  Copyright © 2017年 VIA Technologies, Inc. & OLAMI Team. All rights reserved.
//

#import "NetWorkAction.h"
#import "AFNetworking.h"

@implementation NetWorkAction
//+ (NetWorkAction*)shareInstance {
//    static NetWorkAction *instance = nil;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        instance = [[NetWorkAction alloc] init];
//    });
//    
//    return instance;
//}




- (void)getHttp:(NSString *)httpUrl complete:(NetworkCompleteHandler)handler error:(NetworkCompleteError)handleError {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json",@"text/html", @"text/plain",@"application/x-javascript",nil];

    
    [manager GET:httpUrl parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    }
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             NSHTTPURLResponse *r = (NSHTTPURLResponse *)task.response;
             NSLog(@"%@",[r allHeaderFields]);
             handler(responseObject);
             
         }
     
         failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull   error) {
             handleError(error);
             
             
         }];

}



- (void)postHttp:(NSString *)httpUrl postData:(NSDictionary *)data complete:(NetworkCompleteHandler)handler error:(NetworkCompleteError)handleError {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    [manager POST:httpUrl parameters:data progress:^(NSProgress * _Nonnull uploadProgress) {
        
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        handler(responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        handleError(error);
    }];

}

 

- (void)downLoad:(NSString *)httpUrl complete:(NetworkCompleteHandler)handler error:(NetworkCompleteError)handleError {
    //1.创建管理者对象
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //2.确定请求的URL地址
    NSURL *url = [NSURL URLWithString:httpUrl];
    
    //3.创建请求对象
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    //下载任务
    NSURLSessionDownloadTask *task = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        //打印下下载进度
        // WKNSLog(@"%lf",1.0 * downloadProgress.completedUnitCount / downloadProgress.totalUnitCount);
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        //下载地址
        //WKNSLog(@"默认下载地址:%@",targetPath);
        
        //设置下载路径，通过沙盒获取缓存地址，最后返回NSURL对象
        NSString *filePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)lastObject];
        return [NSURL fileURLWithPath:filePath];
        
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        
        //下载完成调用的方法
        //WKNSLog(@"下载完成：");
        //WKNSLog(@"%@--%@",response,filePath);
        //[self.delegate downloadResult:filePath];
        if (error) {
            handleError(error);
        }else {
            handler(filePath);
        }
        
    }];
    
    //开始启动任务
    [task resume];

}
@end
