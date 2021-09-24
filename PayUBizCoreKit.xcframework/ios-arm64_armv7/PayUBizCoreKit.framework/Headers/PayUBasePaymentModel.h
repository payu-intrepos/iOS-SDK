//
//  PayUBasePaymentModel.h
//  PayUNonSeamlessTestApp
//
//  Created by Vipin Aggarwal on 26/11/18.
//  Copyright © 2018 PayU. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PayUBasePaymentModel : NSObject

@property (strong, nonatomic) NSString * title;
@property (strong, nonatomic) NSString * bankID;
@property (strong, nonatomic) NSString * pgID;
@property (strong, nonatomic) NSString * ptPriority;
@property (strong, nonatomic) NSString * showForm;
@property (strong, nonatomic) NSString * bankCode;
@property (strong, nonatomic) NSNumber * additionalCharge;
@property (nonatomic, strong) NSArray *offers;
@property BOOL isDown;

+ (NSArray *)prepareArrayFromDict:(id)JSON withKey:(NSString *)key ;
+ (NSArray *)prepareArrayForCFFromDict:(NSDictionary *)JSON withDownStaus:(NSDictionary *)downJSON withCFKey:(NSString*) cfKey withDownKey:(NSString*) downKey;
@end

NS_ASSUME_NONNULL_END
