//
//  PayUModelMealCard.h
//  PayUBizCoreKit
//
//  Created by Amit Salaria on 18/10/21.
//  Copyright © 2021 PayU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PayUConstants.h"
#import "PayUBasePaymentModel.h"

@interface PayUModelMealCard : PayUBasePaymentModel
/*!
 * This method returns model objects array.
 * @return [obj array] [NSArray type]
 * @param  [Json]      [NSDictionary type]
 */
+ (NSArray *)prepareMealCardArrayFromDict:(id)JSON;
+ (NSArray *)prepareMealCardArrayForCFFromDict:(NSDictionary *)JSON withDownStaus:(NSDictionary *)downJSON;
+ (NSArray *)prepareMealCardArrayForCFDynamicFromDict:(NSDictionary *)JSON withDownStaus:(NSDictionary *)downJSON;
@end

