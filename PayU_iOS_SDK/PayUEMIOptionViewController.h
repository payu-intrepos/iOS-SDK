//
//  PayUEMIOptionViewController.h
//  PayU_iOS_SDK
//
//  Created by Suryakant Sharma on 14/01/15.
//  Copyright (c) 2015 PayU, India. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PayUEMIOptionViewController : UIViewController

@property (nonatomic,strong) NSArray *emiDetails;

// the total amount being pay
@property (nonatomic,assign) float totalAmount;

@property (nonatomic,copy) NSString *appTitle;

/*
 value for param "pg" in seamless transaction.
 In this peticular case values would be "CC/DC"
 */
@property (nonatomic,copy) NSString *cardType;

//pg As it call in integration Doc, it defines the payment Category.
@property (nonatomic, copy) NSString *paymentCategory;

@property (nonatomic, copy) NSString *bankCode;



@end
