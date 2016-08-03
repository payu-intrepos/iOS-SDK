//
//  PayUWebViewResponse.h
//  PayU_iOS_CoreSDK
//
//  Created by Umang Arya on 20/11/15.
//  Copyright © 2015 PayU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PayUConstants.h"
@import JavaScriptCore;
@import WebKit;

/*!
 * This protocol declares the methods which we get from JS callbacks.
 */
@protocol JSCallBackToObjCSDK <JSExport>

/*!
 * This method is called from JS when transaction is success.
 * @param [response]                                    [id type]
 * @see   [payUTransactionStatusSuccess - CBConnection]
 */
-(void)onPayuSuccess:(id)response;

/*!
 * This method is called from JS when transaction fails.
 * @param [response]                                    [id type]
 * @see   [payUTransactionStatusFailure - CBConnection]
 */
-(void)onPayuFailure:(id)response;

@end

/*!
 * This protocol declares the methods which give callback to merchant's app.
 */
@protocol  PayUSDKWebViewResponseDelegate <NSObject>

/*!
 * This method is gives callback for transaction success.
 * @param [response]   [id type]
 */
-(void)PayUSuccessResponse:(id)response;

/*!
 * This method is gives callback for transaction fail.
 * @param [response]   [id type]
 */
-(void)PayUFailureResponse:(id)response;

@end

/*!
 * This class gives helper method to get PayU success and failure response
 */
@interface PayUWebViewResponse : NSObject <JSCallBackToObjCSDK>

-(void)initialSetupForWebView:(UIWebView *) webview;

@property (nonatomic,weak) id <PayUSDKWebViewResponseDelegate> delegate;
@property (weak,nonatomic) JSContext *js;

@end
