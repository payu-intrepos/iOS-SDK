//
//  PayUModelCCDC.h
//  PayUBizCoreKit
//
//  Created by Shubham Garg on 24/03/21.
//  Copyright © 2021 PayU. All rights reserved.
//

/*!
 * This class declares the properties that holds CCDC information.
 */
#import <Foundation/Foundation.h>
#import "PayUBasePaymentModel.h"

@interface PayUModelCCDC : PayUBasePaymentModel


+ (NSArray *)prepareDCArrayForCFFromDict:(id)JSON withDownStaus:(NSDictionary *)downJSON;
+ (NSArray *)prepareCCArrayForCFFromDict:(id)JSON withDownStaus:(NSDictionary *)downJSON;
+ (NSArray *)prepareDCArrayForCFDynamicFromDict:(id)JSON withDownStaus:(NSDictionary *)downJSON;
+ (NSArray *)prepareCCArrayForCFDynamicFromDict:(id)JSON withDownStaus:(NSDictionary *)downJSON;

@end

