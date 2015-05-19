//
//  CBConstant.h
//  iOSCustomeBrowser
//
//  Created by Suryakant Sharma on 15/04/15.
//  Copyright (c) 2015 PayU, India. All rights reserved.
//

#ifndef iOSCustomeBrowser_CBConstant_h
#define iOSCustomeBrowser_CBConstant_h


#define CB_PRODUCTION_URL @"https://secure.payu.in/js/sdk_js/v3/"
#define CB_TEST_URL @"https://mobiletest.payu.in/js/sdk_js/v3/"



#define ALog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)

#define SCREEN_WIDTH  [[ UIScreen mainScreen ] bounds ].size.width



#define ENTER_OTP       @"enterOTP"
#define CHOOSE          @"choose"
#define OTP             @"otp"
#define PIN             @"pin"
#define INCORRECT_PIN   @"incorrectPIN"
#define CLOSE           @"close"
#define RETRY_OTP  @"retryOTP"
#define REGERERATE @"regenerate"
#define REGERERATE_OTP @"regenerate_otp"

#define DETECT_BANK_KEY @"detectBank"
#define INIT  @"init"

// logging on/off
#ifdef DEBUG
#   define NSLog(...) NSLog(__VA_ARGS__)
#else
#   define NSLog(...)
#endif


/* 
 
 load custome view
 
*/

#define loadView() \
NSBundle *mainBundle = [NSBundle mainBundle]; \
NSArray *views = [mainBundle loadNibNamed:NSStringFromClass([self class]) owner:self options:nil]; \
[self addSubview:views[0]];

#define loadViewWithName(name) \
NSBundle *mainBundle = [NSBundle mainBundle]; \
NSArray *views = [mainBundle loadNibNamed:name owner:self options:nil]; \
[self addSubview:views[0]];


#define     IPHONE_3_5    480
#define     IPHONE_4     568
#define     IPHONE_4_7   667
#define     IPHONE_5_5   736

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)


#endif
