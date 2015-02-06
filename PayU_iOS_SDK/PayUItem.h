//
//  PayUItem.h
//  PayU_iOS_SDK
//
//  Created by Suryakant Sharma on 08/12/14.
//  Copyright (c) 2014 PayU, India. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PayUItem : NSObject

@property(nonatomic, copy, readwrite) NSString *name;

// Number of a particular item
@property(nonatomic, assign) NSUInteger quantity;

// Item cost
@property(nonatomic, copy) NSDecimalNumber *price;

/*Disable required since all the transaction will be done in INR*/
//standard currency code
//@property(nonatomic, copy) NSString *currency;


@end
