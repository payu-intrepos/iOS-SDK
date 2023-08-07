//
//  PayUModelSupportedApps.h
//  PayUBizCoreKit
//
//  Created by Shubham Garg on 14/07/22.
//  Copyright © 2022 PayU. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PayUModelSupportedApps : NSObject
@property (strong, nonatomic) NSString * upiAppName;
@property (strong, nonatomic) NSString * uri;
@property (strong, nonatomic) NSString * bankCode;
@property (strong, nonatomic) NSString * imageCode;
@property (strong, nonatomic) NSString * imageURL;
@property (strong, nonatomic) NSNumber * _Nullable imageUpdatedOn;
@end

NS_ASSUME_NONNULL_END
