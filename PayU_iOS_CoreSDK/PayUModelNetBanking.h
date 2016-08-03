//
//  PayUModelNetBanking.h
//  PayU_iOS_CoreSDK
//
//  Created by Umang Arya on 09/10/15.
//  Copyright © 2015 PayU. All rights reserved.
//

/*!
 * This class declares the properties that holds NetBanking information.
 */
#import <Foundation/Foundation.h>

@interface PayUModelNetBanking : NSObject

@property (strong, nonatomic) NSString * bankID;
@property (strong, nonatomic) NSString * pgID;
@property (strong, nonatomic) NSString * ptPriority;
@property (strong, nonatomic) NSString * showForm;
@property (strong, nonatomic) NSString * netBankingTitle;
@property (strong, nonatomic) NSString * bankCode;

/*!
 * This method returns model objects array.
 * @return [obj array] [NSArray type]
 * @param  [Json]      [NSDictionary type]
 */
+ (NSArray *)prepareNBArrayFromDict:(id)JSON;

@end
/*
 {
 AXIB =             {
 "bank_id" = "<null>";
 pgId = 23;
 "pt_priority" = 3;
 "show_form" = 0;
 title = "AXIS Bank NetBanking";
 };
 BBCB =             {
 "bank_id" = "<null>";
 pgId = 24;
 "pt_priority" = 5;
 "show_form" = 0;
 title = "Bank of Baroda - Corporate Banking";
 };
*/
