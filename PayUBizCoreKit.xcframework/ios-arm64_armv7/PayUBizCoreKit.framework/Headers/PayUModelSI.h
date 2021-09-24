//
//  PayUModelSI.h
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

@interface PayUModelSI : PayUBasePaymentModel

@property (strong, nonatomic) NSString * siTitle;

/*!
 * This method returns model objects array.
 * @return [obj array] [NSArray type]
 * @param  [Json]      [NSDictionary type]
 */
+ (NSArray *)prepareSIArrayFromDict:(id)JSON;
+ (NSArray *)prepareSIArrayForCFFromDict:(id)JSON;
+ (BOOL) checkDCSI:(id)JSON;
+ (BOOL) checkCCSI:(id)JSON;

@end
/*
 
 "standinginstruction" : {
   "KKBKENCR" : {
     "show_form" : "0",
     "title" : "KOTAK MAHINDRA BANK LTD Recurring",
     "pgId" : "266",
     "pt_priority" : "5",
     "bank_id" : null
   },
   "ICICENCR" : {
     "show_form" : "0",
     "title" : "ICICI BANK LTD Recurring",
     "pgId" : "266",
     "pt_priority" : "3",
     "bank_id" : null
   },
   "DCSI" : {
     "show_form" : "1",
     "title" : "Standing Instruction DC",
     "pgId" : "310",
     "pt_priority" : "100",
     "bank_id" : null
   },
   "HDFCDCSI" : {
     "show_form" : "1",
     "title" : "Standing Instruction DC",
     "pgId" : "310",
     "pt_priority" : "100",
     "bank_id" : null
   },
   "CCSI" : {
     "show_form" : "1",
     "title" : "Standing Instruction CC",
     "pgId" : "310",
     "pt_priority" : "100",
     "bank_id" : null
   }
 }
*/
