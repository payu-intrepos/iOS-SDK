//
//  PayUModelEnach.h
//  PayUBizCoreKit
//
//  Created by Shubham Garg on 04/02/21.
//  Copyright © 2021 PayU. All rights reserved.
//

/*!
 * This class declares the properties that holds Enach information.
 */
#import <Foundation/Foundation.h>
#import "PayUConstants.h"
#import "PayUBasePaymentModel.h"

@interface PayUModelEnach : PayUBasePaymentModel

@property (strong, nonatomic) NSString * enachTitle;

/*!
 * This method returns model objects array.
 * @return [obj array] [NSArray type]
 * @param  [Json]      [NSDictionary type]
 */
+ (NSArray *)prepareEnachArrayFromDict:(id)JSON;

@end
/*
 "enach" : {
   "KKBKENCC" : {
     "show_form" : "0",
     "title" : "Kotak Mahindra Bank",
     "pgId" : "266",
     "pt_priority" : "5",
     "bank_id" : null
   },
   "ICICENCC" : {
     "show_form" : "0",
     "title" : "ICICI Bank",
     "pgId" : "266",
     "pt_priority" : "3",
     "bank_id" : null
   }
 }
*/
