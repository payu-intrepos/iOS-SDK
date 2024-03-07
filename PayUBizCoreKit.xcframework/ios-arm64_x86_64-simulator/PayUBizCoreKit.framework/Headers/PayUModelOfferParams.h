//
//  PayUModelOfferParams.h
//  PayUBizCoreKit
//
//  Created by Amit Salaria on 21/02/24.
//  Copyright © 2024 PayU. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PayUModelOfferParams : NSObject <NSCopying>

@property (strong, nonatomic) NSString * userToken;
@property (strong, nonatomic) NSString * clientId;
@property (strong, nonatomic) NSString * paymentCode;
@property (strong, nonatomic) NSString * platformId;
@property (strong, nonatomic) NSArray<NSString *>  * offerKeys;
@property (strong, nonatomic) NSString * skuOfferDetails;
@property  BOOL autoApplyOffer;

@end
