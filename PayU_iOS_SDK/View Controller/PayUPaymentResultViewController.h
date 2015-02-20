//
//  PayUPaymentResultViewController.h
//  PayU_iOS_SDK
//
//  Created by Suryakant Sharma on 17/12/14.
//  Copyright (c) 2014 PayU, India. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PayUPaymentResultViewController : UIViewController

@property (nonatomic,strong) NSURLRequest *request;
@property (assign, nonatomic) BOOL flag;
@property (assign, nonatomic) BOOL isBackOrDoneNeeded;

@end
