//
//  PayUPaymnetOptionsViewController.h
//  PayU_iOS_SDK
//
//  Created by Suryakant Sharma on 09/12/14.
//  Copyright (c) 2014 PayU, India. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PayUPaymentOptionsViewController : UIViewController

@property (nonatomic, copy) NSString *command;
@property (nonatomic, copy) NSString *var1;
@property (weak, nonatomic) IBOutlet UILabel *TxnID;

@property (nonatomic,strong) NSMutableDictionary *parameterDict;

/*
 from key to curl number are mandatory params
 */
//Merchant key, Provied by PayU
@property (nonatomic, copy) NSString *key;

// transaction ID given by merchant to track the order.
@property (nonatomic, copy) NSString *transactionID;

//total amount, being pay
@property (nonatomic,assign) float totalAmount;

@property (nonatomic, copy) NSString *productInfo;
@property (nonatomic, copy) NSString *firstName;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *phoneNumber;

/*
 ****** MANDATORY ******
 surl = success URL, control redirected to the this URL on success.
 furl = failure URL, control redirected to the this URL on failure.
 curl = cancel URL , control redirected to the this URL on cancel.
 */
@property (nonatomic, copy) NSString *surl;
@property (nonatomic, copy) NSString *furl;
@property (nonatomic, copy) NSString *curl;

// checksum value;
@property (nonatomic, copy) NSString *hashKey;

@property (nonatomic, copy) NSString *lastName;

@property (nonatomic, copy) NSString *address1;
@property (nonatomic, copy) NSString *address2;


@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSString *state;
@property (nonatomic, copy) NSString *country;
@property (nonatomic, copy) NSString *zipcode;

@property (nonatomic, copy) NSString *udf1;
@property (nonatomic, copy) NSString *udf2;
@property (nonatomic, copy) NSString *udf3;
@property (nonatomic, copy) NSString *udf4;
@property (nonatomic, copy) NSString *udf5;

//pg As it call in integration Doc, it defines the payment Category.
@property (nonatomic, copy) NSString *paymentCategory;

//Cash on delivery URL, option provide by PayU, on failure.
@property (nonatomic, copy) NSString *codeURL;

//This parameter is used to customize the payment options for each individual transaction.
@property (nonatomic, copy) NSString *dropCategory;
@property (nonatomic, copy) NSString *enforcePaymethod;
@property (nonatomic, copy) NSString *customNote;
@property (nonatomic, copy) NSString *noteCategory;

//please don't use this param while posting the data
@property (nonatomic, copy) NSString *apiVersion;

/*
 Parameters has to used in case of COD (Cash on Delivery) Only
 */
@property (nonatomic, copy) NSString *shippingFirstName;
@property (nonatomic, copy) NSString *shippingLastName;
@property (nonatomic, copy) NSString *shippingAddress1;
@property (nonatomic, copy) NSString *shippingAddress2;
@property (nonatomic, copy) NSString *shippingCity;
@property (nonatomic, copy) NSString *shippingState;
@property (nonatomic, copy) NSString *shippingCountry;
@property (nonatomic, copy) NSString *shippingZipcode;
@property (nonatomic, copy) NSString *shippingPhoneNumber;

@property (nonatomic, copy) NSString *offerKey;

@property (nonatomic, copy) NSString *userCredentials;


//Provied by PayU
@property (nonatomic, copy) NSString *salt;

//App title
@property (nonatomic, copy) NSString *appTitle;

// this object would receive call back on Transaction success, failure and cancel.
@property (nonatomic,strong) id callBackDelegate;


@property (nonatomic,strong) NSDictionary *allHashDict;

@end
