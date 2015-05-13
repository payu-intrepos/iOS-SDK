//
//  Utils.h
//  PayU_iOS_SDK
//
//  Created by Suryakant Sharma on 16/12/14.
//  Copyright (c) 2014 PayU, India. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


#define ALog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)

@interface Utils : NSObject

+ (NSString *) createCheckSumString:(NSString *)input;

+ (void) startPayUNotificationForKey:(NSString *)key intValue:(int)value object:(id)object;
+ (void) startPayUNotificationForKey:(NSString *)key value:(id)value;
+ (UILabel *) customLabelWithString :(NSString *) message andFrame:(CGRect) frame;
@end
