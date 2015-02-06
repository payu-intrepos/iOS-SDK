//
//  CardValidation.h
//  PayU_iOS_SDK
//
//  Created by Suryakant Sharma on 15/12/14.
//  Copyright (c) 2014 PayU, India. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger, CreditCardBrand) {
    CreditCardBrandVisa,
    CreditCardBrandMasterCard,
    CreditCardBrandDinersClub,
    CreditCardBrandAmex,
    CreditCardBrandDiscover,
    CreditCardBrandMaestro,
    CreditCardBrandUnknown
};


@interface CardValidation : NSObject

+ (BOOL) luhnCheck:(NSString *)cardNumber;
+ (CreditCardBrand)checkCardBrandWithNumber:(NSString *)cardNumber;

@end
