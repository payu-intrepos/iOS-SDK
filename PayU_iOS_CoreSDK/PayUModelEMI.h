//
//  PayUModelEMI.h
//  SeamlessTestApp
//
//  Created by Umang Arya on 28/10/15.
//  Copyright © 2015 PayU. All rights reserved.
//

/*!
 * This class declares the properties that holds EMI related information.
 */
#import <Foundation/Foundation.h>

@interface PayUModelEMI : NSObject

@property (strong, nonatomic) NSString * bankName;
@property (strong, nonatomic) NSString * bankID;
@property (strong, nonatomic) NSString * pgID;
@property (strong, nonatomic) NSString * ptPriority;
@property (strong, nonatomic) NSString * showForm;
@property (strong, nonatomic) NSString * emiTitle;
@property (strong, nonatomic) NSString * bankCode;

/*!
 * This method returns model objects array.
 * @return [obj array] [NSArray type]
 * @param  [Json]      [NSDictionary type]
 */
+ (NSArray *)prepareEMIArrayFromDict:(id)JSON;

@end
