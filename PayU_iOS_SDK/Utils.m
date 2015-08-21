//
//  Utils.m
//  PayU_iOS_SDK
//
//  Created by Suryakant Sharma on 16/12/14.
//  Copyright (c) 2014 PayU, India. All rights reserved.
//

#import "Utils.h"
#import "PayUConstant.h"

@implementation Utils

+ (NSString *) createCheckSumString:(NSString *)input
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"XXXXXX" message:@"createCheckSumString called" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
    [alert show];
    
//    const char *cstr = [input cStringUsingEncoding:NSUTF8StringEncoding];
//    NSData *data = [NSData dataWithBytes:cstr length:input.length];
//    uint8_t digest[CC_SHA512_DIGEST_LENGTH];
//    
//    // This is an iOS5-specific method.
//    // It takes in the data, how much data, and then output format, which in this case is an int array.
//    CC_SHA512(data.bytes, (int)data.length, digest);
    
//    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA512_DIGEST_LENGTH * 2];
    
    // Parse through the CC_SHA256 results (stored inside of digest[]).
//    for(int i = 0; i < CC_SHA512_DIGEST_LENGTH; i++) {
//        [output appendFormat:@"%02x", digest[i]];
//    }
//    return output;
    return @"YUNOGENERATEHASHFROMSERVER";
}

+ (void) startPayUNotificationForKey:(NSString *)key value:(id)value {
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:value forKey:key];
    [[NSNotificationCenter defaultCenter] postNotificationName:PAYU_NOTIFICATION  object:nil userInfo:userInfo];
}

+ (void) startPayUNotificationForKey:(NSString *)key intValue:(int)value object:(id)object {
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:value] forKey:key];
    [[NSNotificationCenter defaultCenter] postNotificationName:PAYU_NOTIFICATION  object:object userInfo:userInfo];
}

+ (UILabel *) customLabelWithString :(NSString *) message andFrame:(CGRect) frame{
    
    UIFont * customFont = [UIFont systemFontOfSize:12.0]; //custom font
    
    UILabel *customLabel = [[UILabel alloc]initWithFrame:frame];
    customLabel.text = message;
    customLabel.font = customFont;
    customLabel.lineBreakMode = NSLineBreakByWordWrapping;
    customLabel.numberOfLines = 0;
    customLabel.baselineAdjustment = UIBaselineAdjustmentAlignBaselines; // or UIBaselineAdjustmentAlignCenters, or UIBaselineAdjustmentNone
    customLabel.adjustsFontSizeToFitWidth = YES;
    //customLabel.adjustsLetterSpacingToFitWidth = YES;
    customLabel.minimumScaleFactor = 10.0f/12.0f;
    customLabel.clipsToBounds = YES;
    customLabel.textColor = [UIColor redColor];
    customLabel.textAlignment = NSTextAlignmentCenter;
    customLabel.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:198.0/255.0 blue:198.0/255.0 alpha:1.0];
    customLabel.layer.borderWidth = 2.0;
    customLabel.layer.borderColor = [UIColor redColor].CGColor ;
    customLabel.layer.cornerRadius = 5.0;
    
    return customLabel;
}


@end
