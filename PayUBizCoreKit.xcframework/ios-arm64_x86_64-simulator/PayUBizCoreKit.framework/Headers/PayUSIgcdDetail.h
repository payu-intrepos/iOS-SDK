//
//  PayUSIgcdDetail.h
//  PayUBizCoreKit
//
//  Created by amrendra.roy on 29/10/25.
//  Copyright © 2025 PayU. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PayUSIgcdDetail : NSObject
@property (nonatomic, strong) NSString *paymentStartDate;
@property (nonatomic, strong) NSString *paymentEndDate;
@property (nonatomic, strong) NSString *billingAmount;
@property (nonatomic, strong) NSString *billingCurrency;
@property (nonatomic, strong) NSString *billingCycle;
@property (nonatomic, strong) NSString *billingInterval;
@property (nonatomic, strong) NSArray *freeTrailAmounts;
@property (nonatomic) double bufferAmount;

+ (PayUSIgcdDetail *)prepareSIDetailsFromDict:(NSDictionary *)JSON;

@end

NS_ASSUME_NONNULL_END
