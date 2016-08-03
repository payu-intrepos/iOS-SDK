//
//  PayUModelCashCard.h
//  SeamlessTestApp
//
//  Created by Umang Arya on 26/10/15.
//  Copyright © 2015 PayU. All rights reserved.
//

/*!
 * This class declares the properties that holds CachCard information.
 */
#import <Foundation/Foundation.h>

@interface PayUModelCashCard : NSObject

@property (strong, nonatomic) NSString * bankID;
@property (strong, nonatomic) NSString * pgID;
@property (strong, nonatomic) NSString * ptPriority;
@property (strong, nonatomic) NSString * showForm;
@property (strong, nonatomic) NSString * cashCardTitle;
@property (strong, nonatomic) NSString * bankCode;

/*!
 * This method returns model objects array.
 * @return [obj array] [NSArray type]
 * @param  [Json]      [NSDictionary type]
 */
+ (NSArray *)prepareCashCardArrayFromDict:(id)JSON;

@end
