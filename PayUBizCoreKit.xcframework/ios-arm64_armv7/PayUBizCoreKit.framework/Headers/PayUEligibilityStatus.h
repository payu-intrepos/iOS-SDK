//
//  PayUModelMCPConversion+PayUEligibilityStatus.h
//  PayUBizCoreKit
//
//  Created by Shubham Garg on 22/09/21.
//  Copyright © 2021 PayU. All rights reserved.
//



#import <Foundation/Foundation.h>

@interface PayUEligibilityStatus: NSObject
    @property (strong, nonatomic) NSString * reason;
    @property (nonatomic) BOOL status;
@end


