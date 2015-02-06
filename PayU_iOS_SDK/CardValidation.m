//
//  CardValidation.m
//  PayU_iOS_SDK
//
//  Created by Suryakant Sharma on 15/12/14.
//  Copyright (c) 2014 PayU, India. All rights reserved.
//

#import "CardValidation.h"


#define kVISA_TYPE          @"^4[0-9]{3}?"
#define kMASTER_CARD_TYPE   @"^5[1-5][0-9]{2}$"
#define kAMEX_TYPE          @"^3[47][0-9]{2}$"
#define kDINERS_CLUB_TYPE	@"^3(?:0[0-5]|[68][0-9])[0-9]$"
#define kDISCOVER_TYPE		@"^6(?:011|5[0-9]{2})$"
#define kMAESTRO_CARD_TYPE  @"^(5018|5020|5038|6304|6759|676[1-3])$"




@interface CardValidation()

+ (NSArray *) toCharArray:(NSString *)str;

@end

@implementation CardValidation

+ (NSArray *) toCharArray:(NSString *)str {
    
    NSMutableArray *characters = [[NSMutableArray alloc] initWithCapacity:[str length]];
    for (int i=0; i < [str length]; i++) {
        NSString *ichar  = [NSString stringWithFormat:@"%C", [str characterAtIndex:i]];
        [characters addObject:ichar];
    }
    
    return characters;
}

+ (BOOL) luhnCheck:(NSString *)cardNumber {
    
    if(12 > cardNumber.length)
        return NO;
    
    NSArray *stringAsChars = [CardValidation toCharArray:cardNumber];
    
    BOOL isOdd = YES;
    int oddSum = 0;
    int evenSum = 0;
    
    for (int i = (int)[cardNumber length] - 1; i >= 0; i--) {
        
        int digit = [(NSString *)stringAsChars[i] intValue];
        
        if (isOdd)
            oddSum += digit;
        else
            evenSum += digit/5 + (2*digit) % 10;
        
        isOdd = !isOdd;				 
    }
    
    return ((oddSum + evenSum) % 10 == 0);
}

+ (CreditCardBrand)checkCardBrandWithNumber:(NSString *)cardNumber
{
    if([cardNumber length] < 4) return CreditCardBrandUnknown;
    
    CreditCardBrand cardType;
    NSRegularExpression *regex;
    NSError *error;
    
    for(NSUInteger i = 0; i < CreditCardBrandUnknown; ++i) {
        
        cardType = i;
        
        switch(i) {
            case CreditCardBrandVisa:
                regex = [NSRegularExpression regularExpressionWithPattern:kVISA_TYPE options:0 error:&error];
                break;
            case CreditCardBrandMasterCard:
                regex = [NSRegularExpression regularExpressionWithPattern:kMASTER_CARD_TYPE options:0 error:&error];
                break;
            case CreditCardBrandAmex:
                regex = [NSRegularExpression regularExpressionWithPattern:kAMEX_TYPE options:0 error:&error];
                break;
            case CreditCardBrandDinersClub:
                regex = [NSRegularExpression regularExpressionWithPattern:kDINERS_CLUB_TYPE options:0 error:&error];
                break;
            case CreditCardBrandDiscover:
                regex = [NSRegularExpression regularExpressionWithPattern:kDISCOVER_TYPE options:0 error:&error];
                break;
            case CreditCardBrandMaestro:
                regex = [NSRegularExpression regularExpressionWithPattern:kMAESTRO_CARD_TYPE options:0 error:&error];
                break;
        }
        
        NSUInteger matches = [regex numberOfMatchesInString:cardNumber options:0 range:NSMakeRange(0, 4)];
        if(matches == 1) return cardType;
        
    }
    
    return CreditCardBrandUnknown;
}




@end
