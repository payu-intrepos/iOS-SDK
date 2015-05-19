//
//  CBConnectionHandler.h
//  iOSCustomBrowser
//
//  Created by Suryakant Sharma on 20/04/15.
//  Copyright (c) 2015 PayU, India. All rights reserved.
//
//   Version 
#import <Foundation/Foundation.h>

@import UIKit;
@import JavaScriptCore;
@class CBApproveView;
@class RegenerateOTPView;
@class CBAllPaymentOption;
@class CBBankPageLoading;

@protocol JSCallBackToObjC <JSExport>

- (void) bankFound:(NSString *)BankName;
- (void) convertToNative:(NSString *)paymentOption :(NSString *)otherPaymentOptipon;

@end

@protocol  CBConnectionHandlerDelegate <NSObject>

- (void) bankSpecificJSDownloded;
- (void) bankNameFound:(NSString *) bankName;
- (void) adjustWebViewHeight:(BOOL) upOrDown;
- (void) addViewInResultView:(UIView *) aView;
@end


@interface CBConnectionHandler : NSObject<JSCallBackToObjC>

@property (nonatomic,copy)   NSString *initializejs;
@property (nonatomic,strong) NSMutableDictionary *initializeJavascriptDict;
@property (nonatomic,strong) NSMutableDictionary *bankSpecificJavaScriptDict;
@property (nonatomic,assign) BOOL isBankFound;
@property (nonatomic,weak)   UIView *resultView;
@property (nonatomic,weak)   UIWebView *resultWebView;
@property (nonatomic,weak)   id resultViewController;
@property (nonatomic,copy)   NSString *bankName;

@property (nonatomic,strong) CBApproveView  *approveOTP;
@property (nonatomic,strong) RegenerateOTPView *regenOTPView;
@property (nonatomic,strong) CBAllPaymentOption *choose;
@property (nonatomic,strong) CBBankPageLoading  *loader;

@property (nonatomic,weak) id <CBConnectionHandlerDelegate> connectionHandlerDelegate;

- (void) populateRegenerateOption:(UIView *)aView;
- (void) runBankSpecificJSOnWebView;
- (void) downloadInitializeJS;
- (void) downloadBankSpecificJS:(NSString *)bankName;
- (void) runIntializeJSOnWebView;
- (void) runJavaScript:(NSString *)js toWebView:(UIWebView *) webView;
- (void) closeCB;
- (void) addBankLoader;

@end
