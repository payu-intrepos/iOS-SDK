//
//  PayUModelEMIType.h
//  PayUBizCoreKit
//
//  Created by Shubham Garg on 08/07/22.
//  Copyright © 2022 PayU. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PayUModelEMIType : NSObject
@property (strong, nonatomic) NSString * type;
@property (strong, nonatomic) NSString * ibiboCode;
@property (strong, nonatomic) NSString * imageURL;
@property (strong, nonatomic) NSNumber * _Nullable imageUpdatedOn;
@property  BOOL hasEligible;
@property (nonatomic, strong) NSArray *all;
@property (nonatomic, strong) NSArray *bankCodes;

@end

NS_ASSUME_NONNULL_END
