//
//  PayUPayment.h
//  PayU_iOS_SDK
//
//  Created by Suryakant Sharma on 08/12/14.
//  Copyright (c) 2014 PayU, India. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PayUShippingAddress.h"
#import "PayUPaymentDetails.h"


#pragma mark - PayUPayment
@interface PayUPayment : NSObject

#pragma mark Rquired properties

// Amount for the payment. A Positive decimal number
@property(nonatomic, copy) NSDecimalNumber *amount;

// A brief decription about the transaction
@property(nonatomic, copy) NSString *briefDescription;

#pragma mark Optional properties

// List of Items ordered by user
@property (nonatomic, copy) NSArray *orderItems;

@property (nonatomic, copy, readwrite) PayUPaymentDetails *paymentDetails;

//shipping address
@property (nonatomic, strong) PayUShippingAddress *shippingAddress;

// A optional short description
@property (nonatomic, copy) NSString *shortDescription;


@end
