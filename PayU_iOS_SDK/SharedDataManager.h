//
//  SharedDataManager.h
//  PayU_iOS_SDK
//
//  Created by Suryakant Sharma on 16/12/14.
//  Copyright (c) 2014 PayU, India. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PayUPaymentResultViewController.h"

@interface SharedDataManager : NSObject

//All payment options available on the SALT
@property(nonatomic,strong) NSDictionary *allPaymentOptionDict;

//All param provided by User.
@property(nonatomic,strong) NSDictionary *allInfoDict;

//All Stored Card for given user if any.
@property(nonatomic,strong) NSDictionary *storedCard;


//List of down internet banking option.
@property(nonatomic,strong) NSMutableArray *listOfDownInternetBanking;

//List of down credit/debit bins.
@property(nonatomic,strong) NSMutableArray *listOfDownCardBins;

//All the hash comes from server.
@property(nonatomic,strong) NSDictionary *hashDict;

//SBI Bins
@property(nonatomic,strong) NSMutableArray *allSbiBins;


- (BOOL) isSBIMaestro:(NSString *) cardNumber;
- (NSString *)checkCardDownTime:(NSString *) cardNumber;
- (void) makeVasApiCall;

//to create shared instance
+ (id)sharedDataManager;

@end
