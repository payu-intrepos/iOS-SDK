//
//  PayUModelTokenDetails.h
//  PayUBizCoreKit
//
//  Created by Amit Salaria on 24/12/21.
//  Copyright © 2021 PayU. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PayUModelTokenDetails : NSObject

@property (nonatomic, strong) NSString * token;
@property (nonatomic, strong) NSString * expiryMonth;
@property (nonatomic, strong) NSString * expiryYear;

+(instancetype)prepareTokenDetailsFromJSON:(NSDictionary *) JSON;

@end


/*
 
 {
    "token_exp_yr":"2022",
    "token_exp_mon":"12",
    "token_value":"4489682380061439"
 }
 
 */
