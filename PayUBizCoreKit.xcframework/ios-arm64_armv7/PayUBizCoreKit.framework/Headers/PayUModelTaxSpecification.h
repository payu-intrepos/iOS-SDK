//
//  PayUModelTaxSpecification.h
//  PayUBizCoreKit
//
//  Created by Shubham Garg on 15/04/21.
//  Copyright © 2021 PayU. All rights reserved.
//

#import <Foundation/Foundation.h>

//cc,dc,nb,emi,cash,upi,lazypay,enach
@interface PayUModelTaxSpecification : NSObject
@property (nonatomic, strong) NSNumber *ccTaxValue;
@property (nonatomic, strong) NSNumber *dcTaxValue;
@property (nonatomic, strong) NSNumber *nbTaxValue;
@property (nonatomic, strong) NSNumber *neftRtgsTaxValue;
@property (nonatomic, strong) NSNumber *emiTaxValue;
@property (nonatomic, strong) NSNumber *cashTaxValue;
@property (nonatomic, strong) NSNumber *upiTaxValue;
@property (nonatomic, strong) NSNumber *enachTaxValue;
@property (nonatomic, strong) NSNumber *lazypayTaxValue;
@property (nonatomic, strong) NSNumber *mcTaxValue;

+ (PayUModelTaxSpecification *)prepareTaxInfoFromDict:(NSDictionary *)JSON;
+ (NSNumber *)checkContainTaxValue:(id)taxValue withDefaultValue:(id)defaultValue;
@end
