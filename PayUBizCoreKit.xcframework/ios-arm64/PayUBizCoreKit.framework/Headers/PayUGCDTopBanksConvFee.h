//
//  PayUGCDTopBanksConvFee.h
//  PayUBizCoreKit
//
//  Created by amrendra.roy on 31/08/25.
//  Copyright © 2025 PayU. All rights reserved.
//

#import <Foundation/Foundation.h>
@import PayUParamsKit;

@interface PayUGCDTopBanksConvFee : NSObject

@property (strong, nonatomic) NSString *requestUUID;
@property (strong, nonatomic) NSDictionary<NSString *, NSArray<PayUCharges *> *> *combinations;

+ (PayUGCDTopBanksConvFee *)prepareConvFeeChargesForCFDynamicFromDict:(id)JSON withDownStaus:(NSDictionary *)downJSON;

@end
