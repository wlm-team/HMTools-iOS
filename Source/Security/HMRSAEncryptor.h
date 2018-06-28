//
//  HMRSAEncryptor.h
//  homeApp
//
//  Created by 唐嗣成 on 2018/4/14.
//  Copyright © 2018年 axxt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HMRSAEncryptor : NSObject

/**
 *  加密方法
 *
 *  @param  str    需要加密的字符串
 *  @param key    后台获取的公钥
 */
+ (NSString *)encryptString:(NSString *)str key:(NSString *)key;



@end
