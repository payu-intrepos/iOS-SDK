//
//  PayUErrorConstant.h
//  PayU_iOS_SDK
//
//  Created by Ankur Singhvi on 2/15/15.
//  Copyright (c) 2015 PayU, India. All rights reserved.
//

#ifndef PayU_iOS_SDK_PayUErrorConstant_h
#define PayU_iOS_SDK_PayUErrorConstant_h

#define PAYU_ERROR                  @"payuerror"

typedef NS_ENUM(NSInteger, PayUErrors) {
    PInternetNotReachable = 0,
    PInternetReachableViaWWAN = 1,
    PBackButtonPressed = 2
};

#endif
