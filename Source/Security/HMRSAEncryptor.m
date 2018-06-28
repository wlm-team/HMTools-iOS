//
//  HMRSAEncryptor.m
//  homeApp
//
//  Created by 唐嗣成 on 2018/4/14.
//  Copyright © 2018年 axxt. All rights reserved.
//

#import "HMRSAEncryptor.h"
#import <Security/Security.h>
#import "RSA.h"

@implementation HMRSAEncryptor
//
//static NSString *base64_encode_data(NSData *data){
//    data = [data base64EncodedDataWithOptions:0];
//    NSString *ret = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//    return ret;
//}
//
//static NSData *base64_decode(NSString *str){
//    NSData *data = [[NSData alloc] initWithBase64EncodedString:str options:NSDataBase64DecodingIgnoreUnknownCharacters];
//    return data;
//}
//
////
////+ (NSString *)encryptString:(NSString *)str key:(NSString *)key{
////    if (!str || !key)  return nil;
////    return [self encryptString:str publicKeyRef:[self getPublicKeyRefWithContentsOfFile:key]];
////}
////
//////获取公钥
////+ (SecKeyRef)getPublicKeyRefWithContentsOfFile:(NSString *)pKey{
////    NSData *certData = [pKey dataUsingEncoding:NSUTF8StringEncoding];
////    if (!certData) {
////        return nil;
////    }
////    SecCertificateRef cert = SecCertificateCreateWithData(NULL, (CFDataRef)certData);
////    SecKeyRef key = NULL;
////    SecTrustRef trust = NULL;
////    SecPolicyRef policy = NULL;
////    if (cert != NULL) {
////        policy = SecPolicyCreateBasicX509();
////        if (policy) {
////            if (SecTrustCreateWithCertificates((CFTypeRef)cert, policy, &trust) == noErr) {
////                SecTrustResultType result;
////                if (SecTrustEvaluate(trust, &result) == noErr) {
////                    key = SecTrustCopyPublicKey(trust);
////                }
////            }
////        }
////    }
////    if (policy) CFRelease(policy);
////    if (trust) CFRelease(trust);
////    if (cert) CFRelease(cert);
////    return key;
////}
////
////+ (NSString *)encryptString:(NSString *)str publicKeyRef:(SecKeyRef)publicKeyRef{
////    if(![str dataUsingEncoding:NSUTF8StringEncoding]){
////        return nil;
////    }
////    if(!publicKeyRef){
////        return nil;
////    }
////    NSData *data = [self encryptData:[str dataUsingEncoding:NSUTF8StringEncoding] withKeyRef:publicKeyRef];
////    NSString *ret = base64_encode_data(data);
////    return ret;
////}
//
//
//+ (NSString *)encryptString:(NSString *)str publicKey:(NSString *)pubKey{
//    NSData *data = [self encryptData:[str dataUsingEncoding:NSUTF8StringEncoding] publicKey:pubKey];
//    NSString *ret = base64_encode_data(data);
//    return ret;
//}
//+ (NSData *)encryptData:(NSData *)data publicKey:(NSString *)pubKey{
//    if(!data || !pubKey){
//        return nil;
//    }
//    SecKeyRef keyRef = [self addPublicKey:pubKey];
//    if(!keyRef){
//        return nil;
//    }
//    return [self encryptData:data withKeyRef:keyRef];
//}
//
////+ (NSString *)encryptStringWithData:(NSString *)data key:(NSString *)key{
////    NSString *resultStr = [RSA decryptString:[self ] publicKey:publicKey];
////    return
//}


@end
