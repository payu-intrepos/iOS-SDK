//
//  CardValidation.m
//  PayU_iOS_SDK
//
//  Created by Suryakant Sharma on 15/12/14.
//  Copyright (c) 2014 PayU, India. All rights reserved.
//

#import "Utils.h"
#import "CardValidation.h"


//Visa: All Visa card numbers start with a 4. New cards have 16 digits. Old cards have 13.
//MasterCard: All MasterCard numbers start with the numbers 51 through 55. All have 16 digits.
//American Express: American Express card numbers start with 34 or 37 and have 15 digits.
//Diners Club: Diners Club card numbers begin with 300 through 305, 36 or 38. All have 14 digits. There are Diners Club cards that begin with 5 and have 16 digits. These are a joint venture between Diners Club and MasterCard, and should be processed like a MasterCard.
//Discover: Discover card numbers begin with 6011 or 65. All have 16 digits.
//JCB: JCB cards beginning with 2131 or 1800 have 15 digits. JCB cards beginning with 35 have 16 digits.

#define kVISA_TYPE                     @"^4"
#define kMASTER_CARD_TYPE              @"^5[1-5][\\d]+"
#define kAMEX_TYPE                     @"^3[47][\\d]+"
#define kDINERS_CLUB_TYPE              @"^3(?:0[0-5]|[68][0-9])[0-9]{11}$"
#define kDISCOVER_TYPE                 @"6(?:011|5[0-9]{2})[0-9]{12}[\\d]+"
#define kMAESTRO_CARD_TYPE_1           @"(5[06-8]|6\\d)\\d{14}(\\d{2,3})?[\\d]+"
#define kMAESTRO_CARD_TYPE_2           @"(5[06-8]|6\\d)[\\d]+"
#define kMAESTRO_CARD_TYPE_3           @"((504([435|645|774|775|809|993]))|(60([0206]|[3845]))|(622[018])\\d)[\\d]+"
#define kJCB_CARD_TYPE                 @"^35(2[89]|[3-8][0-9])[\\d]+"
#define kLASER_CARD_TYPE               @"^((6304)|(6706)|(6771)|(6709))[\\d]+"

#define CARD_LENGTH_MAX 19
#define CARD_LENGTH_MIN  4

@interface CardValidation()

+ (NSArray *) toCharArray:(NSString *)str;

@end

@implementation CardValidation

// removing trailing and leading spaces
+ (NSString *) removeEmptyCharsFromString: (NSString *)str {
    NSString *trimmed = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    return trimmed;
}

+ (NSArray *) toCharArray:(NSString *)str {
    
    NSMutableArray *characters = [[NSMutableArray alloc] initWithCapacity:[str length]];
    for (int i=0; i < [str length]; i++) {
        NSString *ichar  = [NSString stringWithFormat:@"%C", [str characterAtIndex:i]];
        [characters addObject:ichar];
    }
    
    return characters;
}

+ (BOOL) luhnCheck:(NSString *)cardNumber {
    
    if (![CardValidation checkCardLengthWithNumber:cardNumber ForBrand:CreditCardBrandUnknown]) {
        ALog(@"luhnCheck failed for card length: %@",cardNumber);
        return NO;
    }
    
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

// Basic check only. Will need to implement separate code for all the cards
+ (BOOL) checkCardLengthWithNumber:(NSString *)cardNumber ForBrand:(CreditCardBrand) cardType {
    if(cardNumber.length < CARD_LENGTH_MIN || cardNumber.length > CARD_LENGTH_MAX)
        return NO;
    else
        return YES;

}

+ (CreditCardBrand)checkCardBrandWithNumber:(NSString *)cardNumber
{
    if (![self checkCardLengthWithNumber:cardNumber ForBrand:CreditCardBrandUnknown]) {
        NSLog(@"checkCardBrandWithNumber, CreditCardBrandUnknown = %@",cardNumber);
        return CreditCardBrandUnknown;
    }
    CreditCardBrand cardType;
    NSRegularExpression *regex;
    NSError *error = NULL;
    
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
                
            case CreditCardBrandJCB:
                regex = [NSRegularExpression regularExpressionWithPattern:kJCB_CARD_TYPE options:0 error:&error];
                break;
                
            case CreditCardBrandLaser:
                regex = [NSRegularExpression regularExpressionWithPattern:kLASER_CARD_TYPE options:0 error:&error];
                break;
            
            case CreditCardBrandMaestroType1:
                regex = [NSRegularExpression regularExpressionWithPattern:kMAESTRO_CARD_TYPE_1 options:0 error:&error];
                cardType = CreditCardBrandMaestro;
                break;
            case CreditCardBrandMaestroType2:
                regex = [NSRegularExpression regularExpressionWithPattern:kMAESTRO_CARD_TYPE_2 options:0 error:&error];
                cardType = CreditCardBrandMaestro;
                break;
            case CreditCardBrandMaestroType3:
                regex = [NSRegularExpression regularExpressionWithPattern:kMAESTRO_CARD_TYPE_3 options:0 error:&error];
                cardType = CreditCardBrandMaestro;
                break;
        }
        
        NSUInteger matches = [regex numberOfMatchesInString:cardNumber options:0 range:NSMakeRange(0, cardNumber.length)];
        if(matches == 1) {
            return cardType;
        }
    }
    
    return CreditCardBrandUnknown;
}



@end
