//
//  PayUInternetBankingViewController.h
//  PayU_iOS_SDK
//
//  Created by Suryakant Sharma on 05/01/15.
//  Copyright (c) 2015 PayU, India. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PayUInternetBankingViewController : UIViewController

@property(nonatomic,strong) NSArray *bankDetails;
@property (nonatomic,strong) NSMutableDictionary *parameterDict;
//total amount, being pay
@property (nonatomic,assign) float totalAmount;

@end
