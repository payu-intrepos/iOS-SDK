//
//  PayUModelCheckIsDomestic.h
//  PayUNonSeamlessTestApp
//
//  Created by Umang Arya on 4/18/16.
//  Copyright © 2016 PayU. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PayUModelCheckIsDomestic : NSObject

@property (nonatomic, strong) NSString * isDomestic;
@property (nonatomic, strong) NSString * issuingBank;
@property (nonatomic, strong) NSString * cardType;
@property (nonatomic, strong) NSString * cardCategory;
@property (nonatomic, strong) NSString * bin;
@property (nonatomic, strong) NSString * isAtmPinCard;
@property (nonatomic, strong) NSNumber * isSISupported;
@property (nonatomic, strong) NSNumber * isZeroRedirectSupported;
+ (instancetype)prepareGetBinInfoObejctFromDict:(NSDictionary *)JSON;

+ (instancetype)prepareCheckIsDomesticObejctFromDict:(NSDictionary *)JSON;

@end
