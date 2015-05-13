//
//  CardValidation.h
//  PayU_iOS_SDK
//
//  Created by Suryakant Sharma on 15/12/14.
//  Copyright (c) 2014 PayU, India. All rights reserved.
//

#import <Foundation/Foundation.h>



typedef NS_ENUM(NSInteger, CreditCardBrand) {
    CreditCardBrandVisa,        //0
    CreditCardBrandMasterCard,  //1
    CreditCardBrandDinersClub,  //2
    CreditCardBrandAmex,        //3
    CreditCardBrandDiscover,    //4
    CreditCardBrandJCB,         //5
    CreditCardBrandLaser,       //6
    CreditCardBrandMaestro,     //7
    CreditCardBrandMaestroType1,//8
    CreditCardBrandMaestroType2,//9
    CreditCardBrandMaestroType3,//10
    CreditCardBrandUnknown      //11
};



@interface CardValidation : NSObject

+ (NSString *) removeEmptyCharsFromString: (NSString *)str;
+ (BOOL) luhnCheck:(NSString *)cardNumber;
+ (BOOL) checkCardLengthWithNumber:(NSString *)cardNumber ForBrand:(CreditCardBrand) cardType;
+ (CreditCardBrand)checkCardBrandWithNumber:(NSString *)cardNumber;

@end
