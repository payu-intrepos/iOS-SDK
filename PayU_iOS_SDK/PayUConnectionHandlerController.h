//
//  PayUConnectionHandlerController.h
//  PayU_iOS_SDK
//
//  Created by Suryakant Sharma on 14/02/15.
//  Copyright (c) 2015 PayU, India. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PayUErrorConstant.h"
#import "PayUNotificationConstant.h"


@protocol PayUConnectionHandlerControllerDelegate <NSObject>

@optional

- (void) successResponse:(NSDictionary *) responseDict;
- (void) failureResponse:(NSDictionary *) errorDict;

@end


@interface PayUConnectionHandlerController : NSObject

typedef void (^urlRequestCompletionBlock)(NSURLResponse *response, NSData *data, NSError *connectionError);


@property(nonatomic,weak) id <PayUConnectionHandlerControllerDelegate> delegate;

- (instancetype) init:(NSDictionary *) requiredParam;

- (void) listOfStoredCardWithCallback:(urlRequestCompletionBlock) completionBlock;
- (void) listOfInternetBankingOptionCallback:(urlRequestCompletionBlock) completionBlock;
- (void) deleteStoredCardWithCardToken:(NSNumber*)cardToken withCompletionBlock:(urlRequestCompletionBlock) completionBlock;


- (NSMutableURLRequest *) URLRequestForInternetBankingWithBankCode:(NSString *)bankCode andTransactionID:(NSString *)txtId;
- (NSURLRequest *) URLRequestForPaymentWithStoredCard:(NSDictionary *)selectedStoredCardDict andTransactionID:(NSString *)txtId;
- (NSURLRequest *) URLRequestForCardPayment:(NSDictionary *) detailsDict andTransactionID:(NSString *)txtId;
- (NSURLRequest *) URLRequestForPayWithPayUMoney;



//-----------------******-------------------------

+(void) generateHashFromServer:(NSDictionary *) paramDict withCompletionBlock:(urlRequestCompletionBlock) completionBlock;

@end
