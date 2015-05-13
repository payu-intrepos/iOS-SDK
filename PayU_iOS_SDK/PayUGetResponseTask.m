//
//  PayUGetResponseTask.m
//  PayU_iOS_SDK_TestApp
//
//  Created by Ankur Singhvi on 3/30/15.
//  Copyright (c) 2015 PayU, India. All rights reserved.
//

#import "PayUGetResponseTask.h"
#import "PayUConstant.h"
#import "Utils.h"
#import "SharedDataManager.h"

#define RESPONSE_DICT_KEY_1     @"ibiboCodes"

@interface PayUGetResponseTask ()
@property (nonatomic, retain) NSDictionary *responseDict;
//@property (nonatomic, retain) NSMutableArray *enforcePayMethodsArray;
//@property (nonatomic, retain) NSMutableArray *dropCategoriesArray;
@end

@implementation PayUGetResponseTask

- (id) initWithAllPaymentOptionsDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self)
    {
        _responseDict = [NSDictionary dictionaryWithDictionary:dict];
//        _enforcePayMethodsArray = [[NSMutableArray alloc] init];
//        _dropCategoriesArray = [[NSMutableArray alloc] init];
        _banksAvailableArray = [[NSMutableArray alloc] init];
        _emiAvailableArray = [[NSMutableArray alloc] init];
        _modesAvailableArray = [[NSMutableArray alloc] init];
        _cashCardsAvailableArray = [[NSMutableArray alloc] init];
        _creditCardsAvailableArray = [[NSMutableArray alloc] init];
        _debitCardsAvailableArray = [[NSMutableArray alloc] init];
        
        _isCCPresent = false;
        _isDCPresent = false;
        _isNBPresent = false;
        _isEmiPresent = false;
        _isCashCardPresent = false;
    
        if ([_responseDict objectForKey:RESPONSE_DICT_KEY_1] != nil) {
            [self processResponseDict:[_responseDict objectForKey:RESPONSE_DICT_KEY_1]];
        }
    }
    return self;
}

- (void) processResponseDict:(NSDictionary *)responseDict {
//    responseDict.allKeys = debitcard,netbanking,rewards,cashcard,creditcard,emi,cod,paisawallet
    NSMutableArray *enforcePayMethodsArray = [[NSMutableArray alloc] init];
    NSMutableArray *dropCategoriesArray = [[NSMutableArray alloc] init];
    
    SharedDataManager *dataManager = [SharedDataManager sharedDataManager];
    
    // Enforce payment
    if ([dataManager.allInfoDict objectForKey:PARAM_ENFORCE_PAYMENT_HOD] != nil) {
        NSString *payMethods = [dataManager.allInfoDict valueForKey:PARAM_ENFORCE_PAYMENT_HOD];
        for (NSString* payMethod in [[payMethods stringByTrimmingCharactersInSet:
                                      [NSCharacterSet whitespaceAndNewlineCharacterSet]] componentsSeparatedByString:@"|"]) {
            [enforcePayMethodsArray addObject:payMethod];
        }
    }
    
    // Drop category
    if ([dataManager.allInfoDict objectForKey:PARAM_DROP_CATEGORY] != nil) {
        NSString *dropCategoryFullString = [dataManager.allInfoDict valueForKey:PARAM_DROP_CATEGORY];
        NSArray *categoriesArray = [[dropCategoryFullString stringByTrimmingCharactersInSet:
                               [NSCharacterSet whitespaceAndNewlineCharacterSet]] componentsSeparatedByString:@","];
        for (NSString* categoryString in categoriesArray) {
            NSArray* splitCategoryArray = [[categoryString stringByTrimmingCharactersInSet:
                                            [NSCharacterSet whitespaceAndNewlineCharacterSet]] componentsSeparatedByString:@"|"];
            for (NSString *dropString in splitCategoryArray) {
                [dropCategoriesArray addObject:dropString];
            }
        }
    }
    
    // Netbanking
    if ([responseDict objectForKey:PARAM_NET_BANKING] != nil) {
        NSDictionary *allNetBankingOptionsDict = [responseDict objectForKey:PARAM_NET_BANKING];
        if(allNetBankingOptionsDict.allKeys.count)
        {
            if (enforcePayMethodsArray.count == 0 || [enforcePayMethodsArray containsObject:PARAM_NET_BANKING]) {
                for (NSString* bankCode in allNetBankingOptionsDict) {
                    if (![dropCategoriesArray containsObject:bankCode]) {
                        NSDictionary *bankDict = [allNetBankingOptionsDict objectForKey:bankCode];
                        [_banksAvailableArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:bankCode, PARAM_BANK_CODE, [bankDict objectForKey:BANK_TITLE], BANK_TITLE, nil]];
                    }
                }
            } else {
                for (NSString* bankCode in allNetBankingOptionsDict) {
                    if ([enforcePayMethodsArray containsObject:bankCode] && ![dropCategoriesArray containsObject:bankCode]) {
                        NSDictionary *bankDict = [allNetBankingOptionsDict objectForKey:bankCode];
                        [_banksAvailableArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:bankCode, PARAM_BANK_CODE, [bankDict objectForKey:BANK_TITLE], BANK_TITLE, nil]];
                    }
                }
            }
            if (_banksAvailableArray.count > 0) {
                _isNBPresent = true;
            }
            
            // sorting
            if (_banksAvailableArray.count > 0) {
                _banksAvailableArray = [NSMutableArray arrayWithArray:[_banksAvailableArray sortedArrayUsingComparator:^(NSDictionary *item1, NSDictionary *item2) {
                    return [item1[BANK_TITLE] compare:item2[BANK_TITLE] options:NSCaseInsensitiveSearch];
                }]];
            }
        }
    }
    
    // EMI
    if ([responseDict objectForKey:PARAM_EMI] != nil) {
        NSDictionary *allEMIOptionsDict = [responseDict objectForKey:PARAM_EMI];
        
        if (enforcePayMethodsArray.count == 0 || [enforcePayMethodsArray containsObject:@"Emi"]) {
            for (NSString* emiCode in allEMIOptionsDict) {
                if (![dropCategoriesArray containsObject:emiCode]) {
                    NSMutableDictionary *emiDict = [NSMutableDictionary dictionaryWithDictionary:[allEMIOptionsDict objectForKey:emiCode]];
                    [emiDict setValue:emiCode forKey:PARAM_BANK_CODE];
                    [_emiAvailableArray addObject:emiDict];
//                    NSDictionary *emiDict = [allEMIOptionsDict objectForKey:emiCode];
//                    [_emiAvailableArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:emiCode, PARAM_BANK_CODE, [emiDict objectForKey:@"title"], @"emiInterval", [emiDict objectForKey:@"bank"], @"bank", nil]];
                }
            }
        } else {
            for (NSString* emiCode in allEMIOptionsDict) {
                if ([enforcePayMethodsArray containsObject:emiCode] && ![dropCategoriesArray containsObject:emiCode]) {
                    NSMutableDictionary *emiDict = [NSMutableDictionary dictionaryWithDictionary:[allEMIOptionsDict objectForKey:emiCode]];
                    [emiDict setValue:emiCode forKey:PARAM_BANK_CODE];
                    [_emiAvailableArray addObject:emiDict];
//                    NSDictionary *emiDict = [allEMIOptionsDict objectForKey:emiCode];
//                    [_emiAvailableArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:emiCode, PARAM_BANK_CODE, [emiDict objectForKey:@"title"], @"emiInterval", [emiDict objectForKey:@"bank"], @"bank", nil]];
                }
            }
        }
        
        if (_emiAvailableArray.count > 0) {
            _isEmiPresent = true;
            // sorting
            _emiAvailableArray = [NSMutableArray arrayWithArray:[_emiAvailableArray sortedArrayUsingComparator:^(NSDictionary *item1, NSDictionary *item2) {
                return [item1[@"bank"] compare:item2[@"bank"] options:NSNumericSearch];
            }]];
        }
    }
    
    // CashCard
    if ([responseDict objectForKey:PARAM_CASH_CARD] != nil) {
        NSDictionary *allCashCardOptionsDict = [responseDict objectForKey:PARAM_CASH_CARD];
        
        if (enforcePayMethodsArray.count == 0 || [enforcePayMethodsArray containsObject:PARAM_CASH_CARD]) {
            for (NSString* cashCardCode in allCashCardOptionsDict) {
                if (![dropCategoriesArray containsObject:cashCardCode]) {
                    NSMutableDictionary *cashCardDict = [NSMutableDictionary dictionaryWithDictionary:[allCashCardOptionsDict objectForKey:cashCardCode]];
                    [cashCardDict setValue:cashCardCode forKey:PARAM_BANK_CODE];
                    [_cashCardsAvailableArray addObject:cashCardDict];
                }
            }
        } else {
            for (NSString* cashCardCode in allCashCardOptionsDict) {
                if ([enforcePayMethodsArray containsObject:cashCardCode] && ![dropCategoriesArray containsObject:cashCardCode]) {
                    NSMutableDictionary *cashCardDict = [NSMutableDictionary dictionaryWithDictionary:[allCashCardOptionsDict objectForKey:cashCardCode]];
                    [cashCardDict setValue:cashCardCode forKey:PARAM_BANK_CODE];
                    [_cashCardsAvailableArray addObject:cashCardDict];
                }
            }
        }
        
        if (_cashCardsAvailableArray.count > 0) {
            _isCashCardPresent = true;
            // sorting
            _cashCardsAvailableArray = [NSMutableArray arrayWithArray:[_cashCardsAvailableArray sortedArrayUsingComparator:^(NSDictionary *item1, NSDictionary *item2) {
                return [item1[PARAM_BANK_CODE] compare:item2[PARAM_BANK_CODE] options:NSNumericSearch];
            }]];
        }
    }
    
    // CreditCard
    if ([responseDict objectForKey:PARAM_CREDIT_CARD] != nil) {
        NSDictionary *allCreditCardOptionsDict = [responseDict objectForKey:PARAM_CREDIT_CARD];
        
        if (enforcePayMethodsArray.count == 0 || [enforcePayMethodsArray containsObject:PARAM_CREDIT_CARD]) {
            for (NSString* creditCardCode in allCreditCardOptionsDict) {
                if (![dropCategoriesArray containsObject:creditCardCode]) {
                    NSDictionary *creditCardDict = [allCreditCardOptionsDict objectForKey:creditCardCode];
                    [_creditCardsAvailableArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:creditCardCode, @"code", [creditCardDict objectForKey:@"title"], @"name", nil]];
                }
            }
        } else {
            for (NSString* creditCardCode in allCreditCardOptionsDict) {
                if ([enforcePayMethodsArray containsObject:creditCardCode] && ![dropCategoriesArray containsObject:creditCardCode]) {
                    NSDictionary *creditCardDict = [allCreditCardOptionsDict objectForKey:creditCardCode];
                    [_creditCardsAvailableArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:creditCardCode, @"code", [creditCardDict objectForKey:@"title"], @"name", nil]];
                }
            }
        }
        
        if (_creditCardsAvailableArray.count > 0) {
            _isCCPresent = true;
            // sorting
            _creditCardsAvailableArray = [NSMutableArray arrayWithArray:[_creditCardsAvailableArray sortedArrayUsingComparator:^(NSDictionary *item1, NSDictionary *item2) {
                return [item1[@"title"] compare:item2[@"title"] options:NSCaseInsensitiveSearch];
            }]];
        }
    }
    
    // DebitCard
    if ([responseDict objectForKey:PARAM_DEBIT_CARD] != nil) {
        NSDictionary *allDebitCardOptionsDict = [responseDict objectForKey:PARAM_DEBIT_CARD];
        
        if (enforcePayMethodsArray.count == 0 || [enforcePayMethodsArray containsObject:PARAM_DEBIT_CARD]) {
            for (NSString* debitCardCode in allDebitCardOptionsDict) {
                if (![dropCategoriesArray containsObject:debitCardCode]) {
                    NSDictionary *debitCardDict = [allDebitCardOptionsDict objectForKey:debitCardCode];
                    [_debitCardsAvailableArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:debitCardCode, @"code", [debitCardDict objectForKey:@"title"], @"name", nil]];
                }
            }
        } else {
            for (NSString* debitCardCode in allDebitCardOptionsDict) {
                if ([enforcePayMethodsArray containsObject:debitCardCode] && ![dropCategoriesArray containsObject:debitCardCode]) {
                    NSDictionary *debitCardDict = [allDebitCardOptionsDict objectForKey:debitCardCode];
                    [_debitCardsAvailableArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:debitCardCode, @"code", [debitCardDict objectForKey:@"title"], @"name", nil]];
                }
            }
        }
        
        if (_debitCardsAvailableArray.count > 0) {
            _isDCPresent = true;
            // sorting
            _debitCardsAvailableArray = [NSMutableArray arrayWithArray:[_debitCardsAvailableArray sortedArrayUsingComparator:^(NSDictionary *item1, NSDictionary *item2) {
                return [item1[@"title"] compare:item2[@"title"] options:NSCaseInsensitiveSearch];
            }]];
        }
    }
    
    // Modes
    if ([dataManager.allInfoDict valueForKey:PARAM_USER_CREDENTIALS]) {
        if (_isCCPresent || _isDCPresent) {
            [_modesAvailableArray addObject:PARAM_STORE_CARD];
        }
    }
    if (_isCCPresent) {
        [_modesAvailableArray addObject:PARAM_CREDIT_CARD];
    }
    if (_isDCPresent) {
        [_modesAvailableArray addObject:PARAM_DEBIT_CARD];
    }
    if (_isNBPresent) {
        [_modesAvailableArray addObject:PARAM_NET_BANKING];
    }
    if (_isEmiPresent) {
        [_modesAvailableArray addObject:PARAM_EMI];
    }
    if (_isCashCardPresent) {
        [_modesAvailableArray addObject:PARAM_CASH_CARD];
    }
    if ([responseDict objectForKey:@"paisawallet"] != nil) {
        if ((enforcePayMethodsArray.count == 0 || [enforcePayMethodsArray containsObject:@"paisawallet"]) && (dropCategoriesArray.count == 0 || ![dropCategoriesArray containsObject:@"paisawallet"])) {
            [_modesAvailableArray addObject:PARAM_PAYU_MONEY];
        }
    }
}


@end
