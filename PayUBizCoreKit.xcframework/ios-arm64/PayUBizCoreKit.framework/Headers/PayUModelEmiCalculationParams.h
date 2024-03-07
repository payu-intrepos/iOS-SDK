//
//  PayUModelEmiCalculator.h
//  PayUBizCoreKit
//
//  Created by Sakshi Dubey on 26/12/23.
//  Copyright © 2023 PayU. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PayUModelEmiCalculationParams : NSObject <NSCopying>

@property (strong, nonatomic) NSArray<NSString*>* emiCodes;
@property (strong, nonatomic) NSArray<NSString*>* bankCodes;
@property (strong, nonatomic) NSString* additionalCharges;

@end
