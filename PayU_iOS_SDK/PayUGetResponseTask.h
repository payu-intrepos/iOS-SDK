//
//  PayUGetResponseTask.h
//  PayU_iOS_SDK_TestApp
//
//  Created by Ankur Singhvi on 3/30/15.
//  Copyright (c) 2015 PayU, India. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PayUGetResponseTask : NSObject

@property (nonatomic, retain) NSMutableArray *banksAvailableArray;
@property (nonatomic, retain) NSMutableArray *emiAvailableArray;
@property (nonatomic, retain) NSMutableArray *modesAvailableArray;
@property (nonatomic, retain) NSMutableArray *cashCardsAvailableArray;
@property (nonatomic, retain) NSMutableArray *creditCardsAvailableArray;
@property (nonatomic, retain) NSMutableArray *debitCardsAvailableArray;

@property (nonatomic,assign) BOOL isCCPresent;
@property (nonatomic,assign) BOOL isDCPresent;
@property (nonatomic,assign) BOOL isNBPresent;
@property (nonatomic,assign) BOOL isEmiPresent;
@property (nonatomic,assign) BOOL isCashCardPresent;

- (id) initWithAllPaymentOptionsDictionary:(NSDictionary *)dict;

@end
