//
//  CardValidation.m
//  PayU_iOS_SDK
//
//  Created by Suryakant Sharma on 15/12/14.
//  Copyright (c) 2014 PayU, India. All rights reserved.
//

#import "Utils.h"
#import "CardValidation.h"

// android
//if (mNumber.startsWith("4")) {
//    return "VISA";
//}/* else if(mNumber.matches("^((6304)|(6706)|(6771)|(6709))[\\d]+")) {
//  return "LASER";
//  } else if(mNumber.matches("6(?:011|5[0-9]{2})[0-9]{12}[\\d]+")) {
//  return "DISCOVER";
//  }*/ else if (mNumber.matches("(5[06-8]|6\\d)\\d{14}(\\d{2,3})?[\\d]+") || mNumber.matches("(5[06-8]|6\\d)[\\d]+") || mNumber.matches("((504([435|645|774|775|809|993]))|(60([0206]|[3845]))|(622[018])\\d)[\\d]+")) {
//      return "MAES";
//  } else if (mNumber.matches("^5[1-5][\\d]+")) {
//      return "MAST";
//  } else if (mNumber.matches("^3[47][\\d]+")) {
//      return "AMEX";
//  } else if (mNumber.startsWith("36") || mNumber.matches("^30[0-5][\\d]+")) {
//      return "DINR";
//  } else if (mNumber.matches("2(014|149)[\\d]+")) {
//      return "DINR";
//  }

//if (SetupCardDetails.findIssuer(ccNumber, "CC").contentEquals("VISA") && ccNumber.length() == 16) {
//    return true;
//} else if (SetupCardDetails.findIssuer(ccNumber, "CC").contentEquals("MAST") && ccNumber.length() == 16) {
//    return true;
//} else if (SetupCardDetails.findIssuer(ccNumber, "CC").contentEquals("MAES") && ccNumber.length() >= 12 && ccNumber.length() <= 19) {
//    return true;
//} else if (SetupCardDetails.findIssuer(ccNumber, "CC").contentEquals("DINR") && ccNumber.length() == 14) {
//    return true;
//} else if (SetupCardDetails.findIssuer(ccNumber, "CC").contentEquals("AMEX") && ccNumber.length() == 15) {
//    return true;
//} else if (SetupCardDetails.findIssuer(ccNumber, "CC").contentEquals("JCB") && ccNumber.length() == 16) {
//    return true;
//}

//Visa: All Visa card numbers start with a 4. New cards have 16 digits. Old cards have 13.
//MasterCard: All MasterCard numbers start with the numbers 51 through 55. All have 16 digits.
//American Express: American Express card numbers start with 34 or 37 and have 15 digits.
//Diners Club: Diners Club card numbers begin with 300 through 305, 36 or 38. All have 14 digits. There are Diners Club cards that begin with 5 and have 16 digits. These are a joint venture between Diners Club and MasterCard, and should be processed like a MasterCard.
//Discover: Discover card numbers begin with 6011 or 65. All have 16 digits.
//JCB: JCB cards beginning with 2131 or 1800 have 15 digits. JCB cards beginning with 35 have 16 digits.

#define kVISA_TYPE @"^4[0-9]{12}(?:[0-9]{3})?$"
#define kMASTER_CARD_TYPE   @"^5[1-5][0-9]{14}$"
#define kAMEX_TYPE          @"^3[47][0-9]{13}$"
#define kDINERS_CLUB_TYPE	@"^3(?:0[0-5]|[68][0-9])[0-9]{11}$"
#define kDISCOVER_TYPE		@"^6(?:011|5[0-9]{2})[0-9]{12}$"
#define kMAESTRO_CARD_TYPE  @"^(5018|5020|5038|6304|6759|676[1-3])$"
#define kMAESTRO_CARD_TYPE_1          @"(5[06-8]|6\\d)\\d{14}(\\d{2,3})?[\\d]+"
#define kMAESTRO_CARD_TYPE_2          @"(5[06-8]|6\\d)[\\d]+"
#define kMAESTRO_CARD_TYPE_3          @"((504([435|645|774|775|809|993]))|(60([0206]|[3845]))|(622[018])\\d)[\\d]+"

// not being used
#define kJCB_TYPE @"^(?:2131|1800|35\d{3})\d{11}$"

int CARD_LENGTH_MAX = 19;
int CARD_LENGTH_MIN = 12;


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
//    if (cardType == CreditCardBrandUnknown) {
    if(cardNumber.length < CARD_LENGTH_MIN || cardNumber.length > CARD_LENGTH_MAX)
        return NO;
    else
        return YES;
//    } else {
//        return NO;
//    }
}

+ (CreditCardBrand)checkCardBrandWithNumber:(NSString *)cardNumber
{
    ALog(@"checkCardBrandWithNumber for card number %@",cardNumber);
//    if([cardNumber length] < 4) return CreditCardBrandUnknown;
//    cardNumber = [CardValidation removeEmptyCharsFromString:cardNumber];
    if (![CardValidation checkCardLengthWithNumber:cardNumber ForBrand:CreditCardBrandUnknown]) {
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
            case CreditCardBrandMaestro:
                regex = [NSRegularExpression regularExpressionWithPattern:kMAESTRO_CARD_TYPE_1 options:0 error:&error];
                break;
        }
        
        NSUInteger matches = [regex numberOfMatchesInString:cardNumber options:0 range:NSMakeRange(0, cardNumber.length)];
        if(matches == 1) {
            ALog(@"cardType: %ld = %@", cardType, cardNumber);
            return cardType;
        }
    }
    
    // putting Android Maestro regex checks for other 2 options
    {
        regex = [NSRegularExpression regularExpressionWithPattern:kMAESTRO_CARD_TYPE_2 options:0 error:&error];
        NSUInteger matches = [regex numberOfMatchesInString:cardNumber options:0 range:NSMakeRange(0, cardNumber.length)];
        if(matches == 1) {
            ALog(@"CreditCardBrandMaestro = %@", cardNumber);
            return CreditCardBrandMaestro;
        }
        
        regex = [NSRegularExpression regularExpressionWithPattern:kMAESTRO_CARD_TYPE_3 options:0 error:&error];
        matches = [regex numberOfMatchesInString:cardNumber options:0 range:NSMakeRange(0, cardNumber.length)];
        if(matches == 1) {
            ALog(@"CreditCardBrandMaestro = %@", cardNumber);
            return CreditCardBrandMaestro;
        }
    }
    
    
    return CreditCardBrandUnknown;
}




@end
