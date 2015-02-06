//
//  SharedDataManager.m
//  PayU_iOS_SDK
//
//  Created by Suryakant Sharma on 16/12/14.
//  Copyright (c) 2014 PayU, India. All rights reserved.
//

#import "SharedDataManager.h"

@implementation SharedDataManager

+ (id)sharedDataManager {
    static SharedDataManager *sharedDataManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDataManager = [[self alloc] init];
    });
    return sharedDataManager;
}

- (id)init {
    if (self = [super init]) {
        _allPaymentOptionDict = [[NSMutableDictionary alloc] init];
        _allInfoDict = [[NSMutableDictionary alloc] init];
    }
    return self;
}

@end
