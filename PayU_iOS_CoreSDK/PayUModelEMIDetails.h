//
//  PayUModelEMIDetails.h
//  SeamlessTestApp
//
//  Created by Umang Arya on 4/4/16.
//  Copyright © 2016 PayU. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PayUModelEMIDetails : NSObject

@property (strong, nonatomic) NSString *emiBankInterest;
@property (strong, nonatomic) NSString *bankRate;
@property (strong, nonatomic) NSString *bankCharge;
@property (strong, nonatomic) NSString *amount;
@property (strong, nonatomic) NSString *cardType;
@property (strong, nonatomic) NSString *emiValue;
@property (strong, nonatomic) NSString *emiInterestPaid;
@property (strong, nonatomic) NSString *bankReference;

/*!
 * This method returns dictionary object after parsing getEMIAmountAccordingToInterest
 * @return [obj NSDictionary] [NSDictionary type]
 * @param  [JSON]      [id type]
 */
+(NSDictionary *)prepareDictFromJSON:(id)JSON;

@end
