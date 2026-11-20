//
//  PayUModelTokenizedPaymentDetails.h
//  PayUBizCoreKit
//
//  Created by Amit Salaria on 24/12/21.
//  Copyright © 2021 PayU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PayUModelTokenDetails.h"

@interface PayUModelTokenizedPaymentDetails : NSObject

@property (nonatomic, strong) NSString * cardNo;
@property (nonatomic, strong) NSString * cardToken;
@property (nonatomic, strong) NSString * cardType;
@property (nonatomic, strong) NSString * cardMode;
@property (nonatomic, strong) NSString * cardName;
@property (nonatomic, strong) NSString * cardPAR;
@property (nonatomic, strong) NSString * cryptogram;
@property (nonatomic, strong) NSString * trid;
@property (nonatomic, strong) NSString * tokenReferenceId;
@property (nonatomic, strong) NSString * oneClickFlow;
@property (nonatomic, strong) NSString * oneClickStatus;
@property (nonatomic, strong) NSString * oneClickCardAlias;
@property (nonatomic, strong) PayUModelTokenDetails * networkToken;

+(instancetype)prepareTokenizedPaymentDetailsFromResponse:(NSDictionary *) JSON;

@end
