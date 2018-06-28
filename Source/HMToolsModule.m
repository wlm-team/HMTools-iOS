//
//  HMCustomModule.m
//  WeexEros
//
//  Created by 唐嗣成 on 2018/1/28.
//  Copyright © 2018年 benmu. All rights reserved.
//

#import "HMToolsModule.h"
#import <BMBaseLibrary/BMWebViewRouterModel.h>
#import "HMWebViewController.h"
#import "BMMediatorManager.h"
#import "RSA.h"

#import <WeexPluginLoader/WeexPluginLoader.h>

@implementation HMToolsModule
@synthesize weexInstance;
WX_PlUGIN_EXPORT_MODULE(hmTools, HMToolsModule)
WX_EXPORT_METHOD(@selector(sendMail:))
WX_EXPORT_METHOD(@selector(toWebViewWithNoCache:))
WX_EXPORT_METHOD(@selector(encryptDataByPublicKey:data:callback:))


-(void)sendMail:(NSString *)addressee {
    NSLog(@"%@", [NSString stringWithFormat:@"mailto://%@",addressee]);
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"mailto://%@",addressee]];
    [[UIApplication sharedApplication] openURL:url];
}


- (void)toWebViewWithNoCache:(NSDictionary *)info
{
    [self clearCache];
    BMWebViewRouterModel *model = [BMWebViewRouterModel yy_modelWithJSON:info];
//    [[BMMediatorManager shareInstance] toWebViewWithRouterInfo:model];
    HMWebViewController *webView = [[HMWebViewController alloc] init];
    
    webView.hidesBottomBarWhenPushed = YES;
    webView.routerInfo = model;

    [[BMMediatorManager shareInstance].currentViewController.navigationController pushViewController:webView animated:YES];
}


-(void) clearCache{
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies]){
        [storage deleteCookie:cookie];
    }
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    NSURLCache * cache = [NSURLCache sharedURLCache];
    [cache removeAllCachedResponses];
    [cache setDiskCapacity:0];
    [cache setMemoryCapacity:0];
}
-(void)encryptDataByPublicKey:(NSString *) key data:(NSString *)data callback:(WXModuleCallback)success{
    NSString *pem = [NSString stringWithFormat:@"-----BEGIN PUBLIC KEY-----%@-----END PUBLIC KEY-----",key];
    NSString *encrypted = [RSA encryptString:data publicKey:pem];
    success(encrypted);
}

@end
