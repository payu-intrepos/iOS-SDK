//
//  PayUModelUPI.h
//  PayUNonSeamlessTestApp
//
//  Created by Vipin Aggarwal on 26/11/18.
//  Copyright © 2018 PayU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PayUBasePaymentModel.h"
#import "PayUModelPaymentRelatedDetail.h"

NS_ASSUME_NONNULL_BEGIN

@interface PayUModelUPI : PayUBasePaymentModel

@property (strong, nonatomic) NSString * upiTitle;
@property (nonatomic, strong) NSArray *supportedApps;

+ (NSArray *)prepareUPIArrayFromDict:(id)JSON;

+ (NSArray *)prepareUPIArrayForCFFromDict:(id)JSON withDownStaus:(NSDictionary *)downJSON;

+ (NSArray *)prepareUPIArrayForCFDynamicFromDict:(id)JSON withDownStaus:(NSDictionary *)downJSON;

+ (NSArray *)prepareUPISIAppsForCFDynamicFromDict:(id)JSON withDownStaus:(NSDictionary *)downJSON;

+ (NSArray *)prepareUPISIHandlesForCFDynamicFromDict:(id)JSON withDownStaus:(NSDictionary *)downJSON;

+ (void )prepareUPIArrayForOTM:(id)JSON withDownStaus:(NSDictionary *)downJSON updateModel: (PayUModelPaymentRelatedDetail *) model;

@end

NS_ASSUME_NONNULL_END
