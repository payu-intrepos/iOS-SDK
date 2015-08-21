//
//  PayUCCDCProcessViewController.h
//  PayU_iOS_SDK
//
//  Created by Suryakant Sharma on 12/12/14.
//  Copyright (c) 2014 PayU, India. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PayUCardProcessViewController : UIViewController

/*
 This flag defines that this controller is being use for
 CC or DC.
 1 for CC
 2 for DC
 */
@property(nonatomic,assign) int CCDCFlag;

// the total amount being pay
//@property (nonatomic,assign) float totalAmount;

@property (nonatomic,copy) NSString *appTitle;

/*
 value for param "pg" in seamless transaction.
 In this peticular case values would be "CC/DC"
 */
@property (nonatomic,copy) NSString *cardType;

@property (nonatomic,copy) NSString *offerKey;


//pg As it call in integration Doc, it defines the payment Category.
//@property (nonatomic, copy) NSString *paymentCategory;

//@property (nonatomic, copy) NSString *bankCode;

@property (nonatomic,strong) NSMutableDictionary *parameterDict;

@property (nonatomic,assign) BOOL storeThisCard;

//total amount, being pay
@property (nonatomic,assign) float totalAmount;

@property (nonatomic,assign) BOOL isPaymentBeingDoneByRewardPoints;
@property (nonatomic,strong) UILabel *DiscountedAmntLbl;


@end
