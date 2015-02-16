//
//  PayUStoredCardViewController.h
//  PayU_iOS_SDK
//
//  Created by Suryakant Sharma on 23/12/14.
//  Copyright (c) 2014 PayU, India. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PayUStoredCardViewController : UIViewController

// the total amount being pay
@property (nonatomic,assign) float totalAmount;

//App titile, if you want to set in navigation Bar.
@property (nonatomic,copy) NSString *appTitle;

@property (nonatomic,strong) NSMutableDictionary *parameterDict;


@end
