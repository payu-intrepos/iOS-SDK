//
//  PayUModelEMI.h
//  SeamlessTestApp
//
//  Created by Umang Arya on 28/10/15.
//  Copyright © 2015 PayU. All rights reserved.
//

/*!
 * This class declares the properties that holds EMI related information.
 */
#import <Foundation/Foundation.h>
#import "PayUBasePaymentModel.h"
#import "PayUEligibilityStatus.h"
@interface PayUModelEMI : PayUBasePaymentModel

@property (strong, nonatomic) NSString * bankName;
@property (strong, nonatomic) NSString * emiTitle;
@property (strong, nonatomic) NSString * minAmount;
@property (strong, nonatomic) NSString * paymentType;
@property (strong, nonatomic) NSNumber * tenure;
@property (strong, nonatomic) PayUEligibilityStatus * eligibility;
/*!
 * This method returns model objects array.
 * @return [obj array] [NSArray type]
 * @param  [Json]      [NSDictionary type]
 */
+ (NSArray *)prepareEMIArrayFromDict:(id)JSON;


/*!
 * This method returns model objects of No cost EMI.
 * @return [obj array] [NSArray type]
 * @param  [Json]      [NSDictionary type]
 */
+ (NSArray *)prepareNoCostEMIArrayFromDict:(id)JSON;

+(NSArray *)getEMIArrayForCFFromDict:(NSDictionary *) JSON withDownStaus:(NSDictionary *)downJSON;

+(NSDictionary *)getEMIDictionaryForCFFromDict:(NSDictionary *) JSON withDownStaus:(NSDictionary *)downJSON;

+(NSDictionary *)getEMIDictFromEMIModelArray:(NSArray *)emiArray;

+(NSDictionary *)getEligibleNoCostEMIDictFromEMIModelArray:(NSArray *)emiArray WRTToAmount:(NSString *) amount;

@end
