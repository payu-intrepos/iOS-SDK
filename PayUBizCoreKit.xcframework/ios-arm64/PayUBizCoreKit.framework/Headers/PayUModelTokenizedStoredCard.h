//
//  PayUModelTokenizedStoredCard.h
//  PayUBizCoreKit
//
//  Created by Amit Salaria on 22/12/21.
//  Copyright © 2021 PayU. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PayUModelTokenizedStoredCard : NSObject

@property (nonatomic, strong) NSString * cardBin;
@property (nonatomic, strong) NSString * cardBrand;
@property (nonatomic, strong) NSString * cardMode;
@property (nonatomic, strong) NSString * cardName;
@property (nonatomic, strong) NSString * cardNo;
@property (nonatomic, strong) NSString * cardToken;
@property (nonatomic, strong) NSString * cardType;
@property (nonatomic, strong) NSString * isDomestic;
@property (nonatomic, strong) NSString * oneClickFlow;
@property (nonatomic, strong) NSString * oneClickStatus;
@property (nonatomic, strong) NSString * oneClickCardAlias;
@property (nonatomic, strong) NSString * cardPAR;

+(NSDictionary *)prepareTokenizedStoredCardFromResponse:(NSDictionary *) JSON;

@end
