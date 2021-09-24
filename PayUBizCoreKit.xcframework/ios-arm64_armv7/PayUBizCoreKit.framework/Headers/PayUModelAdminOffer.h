//
//  PayUModelAdminOffers.h
//  PayUBizCoreKit
//
//  Created by Shubham Garg on 19/04/21.
//  Copyright © 2021 PayU. All rights reserved.
//


#import <Foundation/Foundation.h>



@interface PayUModelAdminOffer : NSObject

@property (nonatomic, strong) NSString * offerId;
@property (nonatomic, strong) NSString * discount;
@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) NSString * offerDescription;
@property (nonatomic, strong) NSString * minAmount;
@property (nonatomic, strong) NSString * discountUnit;
@property (nonatomic, strong) NSString * validOnDays;
@property (nonatomic, strong) NSString * OfferType;
@property (nonatomic, strong) NSString * OfferKey;
+ (NSArray *)prepareOffersInfoFromDict:(NSDictionary *)JSON;
+ (PayUModelAdminOffer*)prepareOfferFromDict:(NSDictionary *)offer;

@end


