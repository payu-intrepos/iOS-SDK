//
//  PayUCashCardViewController.h
//  PayU_iOS_SDK
//
//  Created by Suryakant Sharma on 20/01/15.
//  Copyright (c) 2015 PayU, India. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PayUCashCardViewController : UIViewController

@property(nonatomic,strong) NSArray *cashCardDetail;

//total amount, being pay
@property (nonatomic,assign) float totalAmount;


//App tittle
@property (nonatomic,copy) NSString *appTitle;


@end
