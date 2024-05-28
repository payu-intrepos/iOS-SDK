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
@property (nonatomic) NSInteger retryCount;
@property (nonatomic) BOOL isAdsEnabled;
@property (nonatomic) BOOL isQuickPayEnabled;
@property (nonatomic) BOOL isOfferEnabled;
@property (nonatomic) BOOL isQuickPayBottomSheetEnabled;
@property (nonatomic, strong) NSString *walletIdentifier;

+(PayUModelMerchantInfo *)prepareMerchantInfo:(NSDictionary *)JSON;

@end
