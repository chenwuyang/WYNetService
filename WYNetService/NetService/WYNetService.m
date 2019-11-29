//
//  WYNetService.m
//  Test
//
//  Created by 陈午阳 on 2019/11/28.
//  Copyright © 2019 陈午阳. All rights reserved.
//

#import "WYNetService.h"
#import <SVProgressHUD.h>
#import <AFNetworking.h>
#import "NSError+KXError.h"

const NSInteger successCode        = 1;//请求成功
const NSInteger clientInvalidCode  = 0;//请求失败
const NSInteger tokenInvalidCode   = -2;//token过期


@implementation WYNetService


+ (AFHTTPSessionManager *)configPublicManager
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //已登录状态请求头里面添加token
//    NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:@"TOKEN_KEY"];
//    [manager.requestSerializer setValue:token forHTTPHeaderField:@"Token"];
    [manager.requestSerializer setStringEncoding:NSUTF8StringEncoding];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"text/plain",@"application/json", nil];
    [manager.requestSerializer setTimeoutInterval:10];
    return manager;
}

+ (void)dealResponse:(id)response task:(NSURLSessionDataTask *)task info:(void (^)(id _Nullable obj))infoBlock error:(void (^)(NSError *_Nullable))errorBlock
{
    // 请求成功，解析数据
    NSDictionary *dicInfo = nil;
    NSError *error;
    if ([response isKindOfClass:[NSDictionary class]])
    {
        dicInfo = (NSDictionary *)response;
    }
    else
    {
        dicInfo = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingAllowFragments error:&error];
    }
    if ([dicInfo[@"code"] integerValue] == successCode)
    {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
        NSDictionary *allHeaders = response.allHeaderFields;
        //token即将过期，用新token替换旧token
        if ([[allHeaders allKeys] containsObject:@"Token"]) {
            NSString *newToken = [allHeaders objectForKey:@"Token"];
            [[NSUserDefaults standardUserDefaults] setObject:newToken forKey:@"TOKEN_KEY"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        if (infoBlock)
        {
            infoBlock(dicInfo[@"data"]);
        }
    }
    else
    {
        if ([dicInfo[@"code"] integerValue] == clientInvalidCode) {
            [SVProgressHUD showErrorWithStatus:dicInfo[@"msg"]];
        }
        else if([dicInfo[@"code"] integerValue] == tokenInvalidCode)
        {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"TOKEN_KEY"];
            [[NSUserDefaults standardUserDefaults] synchronize];
#pragma warn token过期进入登录页面重新登录
        }
        NSError *error;
        NSString *message;
        if(dicInfo[@"msg"])
        {
            message = dicInfo[@"msg"];
        }
        else
        {
            message = @"后台返回信息无法解析";
        }
        error = [[NSError alloc] initWithDomain:@"errorDomain"
                                           code:[dicInfo[@"code"] integerValue]
                                       userInfo:@{NSLocalizedDescriptionKey:message}];
        if(errorBlock)
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                errorBlock(error);
            });
        }
    }
}

+ (void)requestPostWithInfoblock:(void (^)(id _Nullable))infoBlock error:(void (^)(NSError * _Nullable))errorBlock serverUrl:(NSString * _Nullable)serverurl url:(NSString * _Nullable)url param:(NSDictionary * _Nullable)param;
{
    AFHTTPSessionManager *manager = [self configPublicManager];

    NSString *strUrl = [NSString stringWithFormat:@"%@%@",serverurl,url];

    [manager POST:strUrl parameters:param progress:^(NSProgress * _Nonnull uploadProgress) {

    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {

        [self dealResponse:responseObject task:task info:infoBlock error:errorBlock];

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {

        NSError *newError = [NSError returnErrorWithError:error];
        [SVProgressHUD showErrorWithStatus:newError.userInfo[NSLocalizedDescriptionKey]];
        if(errorBlock)
        {
            errorBlock(error);
        }

    }];
}

+ (void)requestGetWithInfoblock:(void (^)(id _Nullable))infoBlock error:(void (^)(NSError * _Nullable))errorBlock serverUrl:(NSString * _Nullable)serverurl url:(NSString * _Nullable)url param:(NSDictionary * _Nullable)param;
{
    AFHTTPSessionManager *manager = [self configPublicManager];
    NSString *strUrl = [NSString stringWithFormat:@"%@%@",serverurl,url];

    [manager GET:strUrl parameters:param progress:^(NSProgress * _Nonnull downloadProgress) {

    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {

        [self dealResponse:responseObject task:task info:infoBlock error:errorBlock];

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {

        NSError *newError = [NSError returnErrorWithError:error];
        [SVProgressHUD showErrorWithStatus:newError.userInfo[NSLocalizedDescriptionKey]];
        if(errorBlock)
        {
            errorBlock(error);
        }
    }];
}

+ (void)requestPostUpLoadImageWithInfoBlock:(void (^)(id _Nullable))infoBlock errorBlock:(void (^)(NSError * _Nullable))errorBlock image:(UIImage * _Nullable)image serverUrl:(NSString * _Nullable)serverUrl url:(NSString * _Nullable)url param:(NSDictionary * _Nullable)param key:(NSString * _Nullable)key;
{
    AFHTTPSessionManager *manager = [self configPublicManager];

    NSString *strUrl = [NSString stringWithFormat:@"%@%@",serverUrl,url];

    [manager POST:strUrl parameters:param constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        // 上传图片
        NSData *imageData = UIImagePNGRepresentation(image);
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyyMMddHHmmss";
        NSString *str = [formatter stringFromDate:[NSDate date]];
        NSString *fileName = [NSString stringWithFormat:@"%@.png", str];
        [formData appendPartWithFileData:imageData name:key fileName:fileName mimeType:@"image/png"];
    } progress:^(NSProgress * _Nonnull uploadProgress) {

    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self dealResponse:responseObject task:task info:infoBlock error:errorBlock];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSError *newError = [NSError returnErrorWithError:error];
        [SVProgressHUD showErrorWithStatus:newError.userInfo[NSLocalizedDescriptionKey]];
        if(errorBlock)
        {
            errorBlock(newError);
        }
    }];
    
}

+ (void)requestPostUpLoadAudioWithInfoBlock:(void (^)(id _Nullable))infoBlock errorBlock:(void (^)(NSError * _Nullable))errorBlock data:(NSData * _Nullable)data serverUrl:(NSString * _Nullable)serverUrl url:(NSString * _Nullable)url param:(NSDictionary * _Nullable)param key:(NSString * _Nullable)key;
{
    AFHTTPSessionManager *manager = [self configPublicManager];
    NSString *strUrl = [NSString stringWithFormat:@"%@%@",serverUrl,url];
    [manager POST:strUrl parameters:param constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        // 上传文件
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyyMMddHHmmss";
        NSString *str = [formatter stringFromDate:[NSDate date]];
        NSString *fileName = [NSString stringWithFormat:@"%@.mp3", str];
        [formData appendPartWithFileData:data name:key fileName:fileName mimeType:@"audio/mpeg"];
    } progress:^(NSProgress * _Nonnull uploadProgress) {

    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self dealResponse:responseObject task:task info:infoBlock error:errorBlock];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSError *newError = [NSError returnErrorWithError:error];
        [SVProgressHUD showErrorWithStatus:newError.userInfo[NSLocalizedDescriptionKey]];
        if(errorBlock)
        {
            errorBlock(newError);
        }
    }];
}


+ (void)requestPostUpLoadFileWithInfoBlock:(void (^)(id _Nullable))infoBlock errorBlock:(void (^)(NSError * _Nullable))errorBlock progressBlock:(void (^)(NSProgress * _Nullable))progressBlock data:(NSData * _Nullable)data serverUrl:(NSString * _Nullable)serverUrl url:(NSString * _Nullable)url param:(NSDictionary *_Nullable)param key:(NSString * _Nullable)key
{
    AFHTTPSessionManager *manager = [self configPublicManager];
    NSString *strUrl = [NSString stringWithFormat:@"%@%@",serverUrl,url];
    [manager POST:strUrl parameters:param constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyyMMddHHmmss";
        NSString *str = [formatter stringFromDate:[NSDate date]];
        NSString *fileName = [NSString stringWithFormat:@"%@.mp4", str];
        [formData appendPartWithFileData:data name:key fileName:fileName mimeType:@"video/mp4"];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        progressBlock(uploadProgress);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {

        [self dealResponse:responseObject task:task info:infoBlock error:errorBlock];

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSError *newError = [NSError returnErrorWithError:error];
        [SVProgressHUD showErrorWithStatus:newError.userInfo[NSLocalizedDescriptionKey]];
        if(errorBlock)
        {
            errorBlock(newError);
        }
    }];
}



@end
