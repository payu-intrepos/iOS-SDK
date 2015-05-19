//
//  CBBankPageLoading.h
//  PayU_iOS_SDK_TestApp
//
//  Created by Suryakant Sharma on 15/05/15.
//  Copyright (c) 2015 PayU, India. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CBConnectionHandler.h"

@interface CBBankPageLoading : UIView

@property (nonatomic,weak) CBConnectionHandler *handler;
@property (assign, nonatomic) BOOL isViewOnScreen;

@property(nonatomic,strong)  NSTimer  *loadingTimer;


- (void)drawCircle: (NSInteger)number;
- (id)initWithFrame:(CGRect)frame andCBConnectionHandler:(CBConnectionHandler *)handler;


@end
