//
//  PayUPaymentResultViewController.h
//  PayU_iOS_SDK
//
//  Created by Suryakant Sharma on 17/12/14.
//  Copyright (c) 2014 PayU, India. All rights reserved.
//

#import <UIKit/UIKit.h>
//@import JavaScriptCore;
//
//@protocol JSCallBackToObjC <JSExport>
//
//- (void) bankFound:(NSString *)BankName;
//- (void) convertToNative:(NSString *)paymentOption andOtherOption:(NSString *)otherPaymentOptipon;
//
//@end

@interface PayUPaymentResultViewController : UIViewController //<JSCallBackToObjC>

@property (nonatomic,strong) NSURLRequest *request;
@property (assign, nonatomic) BOOL flag;
@property (assign, nonatomic) BOOL isBackOrDoneNeeded;

-(void) loadJavascript;


@end
