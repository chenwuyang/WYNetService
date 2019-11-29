//
//  WYNetService.h
//  Test
//
//  Created by 陈午阳 on 2019/11/28.
//  Copyright © 2019 陈午阳. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WYNetService : NSObject


/// 通用post请求
/// @param infoBlock 请求成功返回的block
/// @param errorBlock 请求失败返回的error
/// @param serverurl 请求域名
/// @param url 请求接口名
/// @param param 请求参数
+ (void)requestPostWithInfoblock:(void (^)(id _Nullable))infoBlock error:(void (^)(NSError * _Nullable))errorBlock serverUrl:(NSString * _Nullable)serverurl url:(NSString * _Nullable)url param:(NSDictionary * _Nullable)param;



/// 通用get请求
/// @param infoBlock 请求成功返回的block
/// @param errorBlock 请求失败返回的error
/// @param serverurl 请求域名
/// @param url 请求接口名
/// @param param 请求参数
+ (void)requestGetWithInfoblock:(void (^)(id _Nullable))infoBlock error:(void (^)(NSError * _Nullable))errorBlock serverUrl:(NSString * _Nullable)serverurl url:(NSString * _Nullable)url param:(NSDictionary * _Nullable)param;


/// 图片上传接口
/// @param infoBlock 请求成功返回的block
/// @param errorBlock 请求失败返回的error
/// @param image 将要上传的图片
/// @param serverUrl 请求域名
/// @param url 请求接口名
/// @param param 请求参数
/// @param key 参数标识
+ (void)requestPostUpLoadImageWithInfoBlock:(void (^)(id _Nullable))infoBlock errorBlock:(void (^)(NSError * _Nullable))errorBlock image:(UIImage * _Nullable)image serverUrl:(NSString * _Nullable)serverUrl url:(NSString * _Nullable)url param:(NSDictionary * _Nullable)param key:(NSString * _Nullable)key;


/// 音频文件上传接口
/// @param infoBlock 请求成功返回的block
/// @param errorBlock 请求失败返回的error
/// @param data 将要上传的音频二进制文件
/// @param serverUrl 请求域名
/// @param url 请求接口名
/// @param param 请求参数
/// @param key 参数标识
+ (void)requestPostUpLoadAudioWithInfoBlock:(void (^)(id _Nullable))infoBlock errorBlock:(void (^)(NSError * _Nullable))errorBlock data:(NSData * _Nullable)data serverUrl:(NSString * _Nullable)serverUrl url:(NSString * _Nullable)url param:(NSDictionary * _Nullable)param key:(NSString * _Nullable)key;



/// 视频上传接口
/// @param infoBlock 请求成功返回的block
/// @param errorBlock 请求失败返回的error
/// @param progressBlock 上传进度返回block
/// @param data 将要上传的视频二进制文件
/// @param serverUrl 请求域名
/// @param url 请求接口名
/// @param param 请求参数
/// @param key 参数标识
+ (void)requestPostUpLoadFileWithInfoBlock:(void (^)(id _Nullable))infoBlock errorBlock:(void (^)(NSError * _Nullable))errorBlock progressBlock:(void (^)(NSProgress * _Nullable))progressBlock data:(NSData * _Nullable)data serverUrl:(NSString * _Nullable)serverUrl url:(NSString * _Nullable)url param:(NSDictionary *_Nullable)param key:(NSString * _Nullable)key;

@end

NS_ASSUME_NONNULL_END
