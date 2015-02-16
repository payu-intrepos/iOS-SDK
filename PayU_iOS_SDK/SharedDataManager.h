//
//  SharedDataManager.h
//  PayU_iOS_SDK
//
//  Created by Suryakant Sharma on 16/12/14.
//  Copyright (c) 2014 PayU, India. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PayUPaymentResultViewController.h"

@interface SharedDataManager : NSObject

//All payment options available on the SALT
@property(nonatomic,strong) NSDictionary *allPaymentOptionDict;

//All param provided by User.
@property(nonatomic,strong) NSDictionary *allInfoDict;


+ (id)sharedDataManager;

@end
