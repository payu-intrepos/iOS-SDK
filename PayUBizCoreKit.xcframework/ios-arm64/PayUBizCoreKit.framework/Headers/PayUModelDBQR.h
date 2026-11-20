//
//  PayUModelDBQR.h
//  PayUBizCoreKit
//
//  Created by amrendra.roy on 25/06/26.
//  Copyright © 2026 PayU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PayUBasePaymentModel.h"
#import "PayUModelPaymentRelatedDetail.h"

NS_ASSUME_NONNULL_BEGIN

@interface PayUModelDBQR : PayUBasePaymentModel

+ (NSArray *)prepareDBQRArrayFromDict:(id)JSON;

+ (NSArray *)prepareUPIArrayForCFFromDict:(id)JSON withDownStaus:(NSDictionary *)downJSON;

+ (NSArray *)prepareDBQRArrayForCFDynamicFromDict:(id)JSON withDownStaus:(NSDictionary *)downJSON;

@end

NS_ASSUME_NONNULL_END
