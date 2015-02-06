//
//  PayUShippingAddress.h
//  PayU_iOS_SDK
//
//  Created by Suryakant Sharma on 08/12/14.
//  Copyright (c) 2014 PayU, India. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PayUShippingAddress : NSObject


//First Name of the recipient at this address
@property(nonatomic, copy) NSString *recipientFirstName;

// Last Name of the recipient at this address
@property(nonatomic, copy) NSString *recipientLastName;


// Line 1 of the address
@property(nonatomic, copy) NSString *line1;

// Line 2 of the address
@property(nonatomic, copy) NSString *line2;

// City name
@property(nonatomic, copy) NSString *city;

// state name
@property(nonatomic, copy) NSString *state;

// country code
@property(nonatomic, copy) NSString *countryCode;

// ZIP code
@property(nonatomic, copy) NSString *postalCode;

// Offer key, if merchant want to give any discount
@property(nonatomic, copy) NSString *offerKey;


@end
