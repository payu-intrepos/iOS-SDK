//
//  PayUModelMerchantInfo.h
//  PayUBizCoreKit
//
//  Created by Amit Salaria on 04/04/22.
//  Copyright © 2022 PayU. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PayUModelMerchantInfo: NSObject

@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, strong) NSString *logo;
@property (nonatomic, strong) NSString *opgspMerchant;
@property (nonatomic) NSInteger retryCount;
@property (nonatomic) BOOL isAdsEnabled;
@property (nonatomic) BOOL isQuickPayEnabled;
@property (nonatomic) BOOL isOfferEnabled;
@property (nonatomic) BOOL isQuickPayBottomSheetEnabled;
@property (nonatomic) BOOL customerRevenueEnabled;
@property (nonatomic, strong) NSString *walletIdentifier;
@property (nonatomic, strong) NSDictionary *ifscBankNameMapping;

+(PayUModelMerchantInfo *)prepareMerchantInfo:(NSDictionary *)JSON;

@end
