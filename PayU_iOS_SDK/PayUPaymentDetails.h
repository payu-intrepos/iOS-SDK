//
//  PayUPaymentDetails.h
//  PayU_iOS_SDK
//
//  Created by Suryakant Sharma on 08/12/14.
//  Copyright (c) 2014 PayU, India. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PayUPaymentDetails : NSObject

// Sub-total amount of all items
@property(nonatomic, copy, readwrite) NSDecimalNumber *subtotal;

// Shipping Charge
@property(nonatomic, copy, readwrite) NSDecimalNumber *shipping;

// Tax, if any
@property(nonatomic, copy, readwrite) NSDecimalNumber *tax;


@end
