//
//  Utils.m
//  PayU_iOS_SDK
//
//  Created by Suryakant Sharma on 16/12/14.
//  Copyright (c) 2014 PayU, India. All rights reserved.
//

#import "Utils.h"
#import "PayUConstant.h"
#import <CommonCrypto/CommonDigest.h>

@implementation Utils

+ (NSString *) createCheckSumString:(NSString *)input
{
    const char *cstr = [input cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:input.length];
    uint8_t digest[CC_SHA512_DIGEST_LENGTH];
    
    // This is an iOS5-specific method.
    // It takes in the data, how much data, and then output format, which in this case is an int array.
    CC_SHA512(data.bytes, (int)data.length, digest);
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA512_DIGEST_LENGTH * 2];
    
    // Parse through the CC_SHA256 results (stored inside of digest[]).
    for(int i = 0; i < CC_SHA512_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    return output;
}

+ (void) startPayUNotificationForKey:(NSString *)key value:(id)value {
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:value forKey:key];
    [[NSNotificationCenter defaultCenter] postNotificationName:PAYU_NOTIFICATION  object:nil userInfo:userInfo];
}

+ (void) startPayUNotificationForKey:(NSString *)key intValue:(int)value object:(id)object {
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:value] forKey:key];
    [[NSNotificationCenter defaultCenter] postNotificationName:PAYU_NOTIFICATION  object:object userInfo:userInfo];
}


@end
