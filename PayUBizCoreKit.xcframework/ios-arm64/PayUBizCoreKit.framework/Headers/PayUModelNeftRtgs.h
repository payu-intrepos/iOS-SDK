//
//  PayUModelNeftRtgs.h
//  PayUBizCoreKit
//
//  Created by Shubham Garg on 02/10/21.
//  Copyright © 2021 PayU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PayUConstants.h"
#import "PayUBasePaymentModel.h"
@interface PayUModelNeftRtgs : PayUBasePaymentModel

@property (strong, nonatomic) NSString * neftTitle;

/*!
 * This method returns model objects array.
 * @return [obj array] [NSArray type]
 * @param  [Json]      [NSDictionary type]
 */
+ (NSArray *)prepareNeftArrayFromDict:(id)JSON;
+ (NSArray *)prepareNeftArrayForCFFromDict:(NSDictionary *)JSON withDownStaus:(NSDictionary *)downJSON;
+ (NSArray *)prepareNeftArrayForCFDynamicFromDict:(NSDictionary *)JSON withDownStaus:(NSDictionary *)downJSON;
@end
