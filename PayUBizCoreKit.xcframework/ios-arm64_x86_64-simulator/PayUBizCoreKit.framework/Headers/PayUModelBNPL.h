//
//  PayUModelBNPL.h
//  PayUBizCoreKit
//
//  Created by Amit Salaria on 16/12/22.
//  Copyright © 2022 PayU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PayUBasePaymentModel.h"
#import "PayUEligibilityStatus.h"

@interface PayUModelBNPL : PayUBasePaymentModel

@property (strong, nonatomic) NSString * minAmount;
@property (strong, nonatomic) NSString * maxAmount;
@property (strong, nonatomic) PayUEligibilityStatus * eligibility;

+ (NSArray *)prepareBNPLArrayForCFFromDict:(NSDictionary *)JSON withDownStaus:(NSDictionary *)downJSON;
+ (NSArray *)prepareBNPLArrayForCFDynamicFromDict:(NSDictionary *)JSON withDownStaus:(NSDictionary *)downJSON;

@end

