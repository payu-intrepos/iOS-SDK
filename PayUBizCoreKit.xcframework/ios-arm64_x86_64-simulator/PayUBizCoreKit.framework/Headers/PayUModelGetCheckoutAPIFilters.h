//
//  PayUModelGetCheckoutAPIFilters.h
//  PayUBizCoreKit
//
//  Created by Amit Salaria on 14/09/22.
//  Copyright © 2022 PayU. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PayUModelGetCheckoutAPIFilters : NSObject

@property (nonatomic, strong) NSString *dcEMIBankCode;
@property (nonatomic, strong) NSString *bnplBankCode;
@property (nonatomic, strong) NSString *cardlessEMIBankCode;

@end
