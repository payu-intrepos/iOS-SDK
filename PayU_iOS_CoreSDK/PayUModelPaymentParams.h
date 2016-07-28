//
//  PayUModelPaymentParams.h
//  PayU_iOS_CoreSDK
//
//  Created by Umang Arya on 28/09/15.
//  Copyright © 2015 PayU. All rights reserved.
//

/*!
 * This class declares all payment params.
 */
#import <Foundation/Foundation.h>
#import "PayUModelHashes.h"
#import "PayUModelStoredCard.h"

@interface PayUModelPaymentParams : NSObject <NSCopying>

// Mandatory Parameters
@property (strong, nonatomic) NSString * key;
@property (strong, nonatomic) NSString * amount;
@property (strong, nonatomic) NSString * productInfo;
@property (strong, nonatomic) NSString * firstName;
@property (strong, nonatomic) NSString * email;
@property (strong, nonatomic) NSString * transactionID;
@property (strong, nonatomic) NSString * SURL;
@property (strong, nonatomic) NSString * FURL;
// For setting Environment
//  ENVIRONMENT_PRODUCTION   is for Production
//  ENVIRONMENT_TEST   is for Test
@property (strong, nonatomic) NSString * environment;
// Hashes
@property (strong, nonatomic) PayUModelHashes *hashes;



// Other Parameters
@property (strong, nonatomic) NSString * userCredentials;


// Optional Parameters
@property (strong, nonatomic) NSString * phoneNumber;
@property (strong, nonatomic) NSString * address1;
@property (strong, nonatomic) NSString * address2;
@property (strong, nonatomic) NSString * city;
@property (strong, nonatomic) NSString * state;
@property (strong, nonatomic) NSString * country;
@property (strong, nonatomic) NSString * zipcode;
@property (strong, nonatomic) NSString * udf1;
@property (strong, nonatomic) NSString * udf2;
@property (strong, nonatomic) NSString * udf3;
@property (strong, nonatomic) NSString * udf4;
@property (strong, nonatomic) NSString * udf5;
@property (strong, nonatomic) NSString * CURL;
@property (strong, nonatomic) NSString * CODURL;
@property (strong, nonatomic) NSString * dropCategory;
@property (strong, nonatomic) NSString * enforcePayMethod;
@property (strong, nonatomic) NSString * customNote;
@property (strong, nonatomic) NSString * noteCategory;
@property (strong, nonatomic) NSString * apiVersion;
@property (strong, nonatomic) NSString * shippingFirstname;
@property (strong, nonatomic) NSString * shippingLastname;
@property (strong, nonatomic) NSString * shippingAddress1;
@property (strong, nonatomic) NSString * shippingAddress2;
@property (strong, nonatomic) NSString * shippingCity;
@property (strong, nonatomic) NSString * shippingState;
@property (strong, nonatomic) NSString * shippingCountry;
@property (strong, nonatomic) NSString * shippingZipcode;
@property (strong, nonatomic) NSString * shippingPhone;
@property (strong, nonatomic) NSString * offerKey;



// Param for Stored card
@property (nonatomic, strong) NSString * cardBin;
@property (nonatomic, strong) NSString * cardBrand;
@property (nonatomic, strong) NSString * oneTapFlag;
@property (nonatomic, strong) NSString * cardMode;
@property (nonatomic, strong) NSString * cardName;
@property (nonatomic, strong) NSString * cardNo;
@property (nonatomic, strong) NSString * cardToken;
@property (nonatomic, strong) NSString * cardType;
@property (nonatomic, strong) NSString * isDomestic;
@property (nonatomic, strong) NSString * isExpired;
@property (nonatomic, strong) NSString * issuingBank;




// Param for CCDC & Stored Card
@property (strong, nonatomic) NSString * cardNumber;
@property (strong, nonatomic) NSString * expiryMonth;
@property (strong, nonatomic) NSString * expiryYear;
@property (strong, nonatomic) NSString * CVV;
@property (strong, nonatomic) NSString * nameOnCard;
@property  BOOL isOneTap;

//Param for CCDC
@property (strong, nonatomic) NSString * storeCardName;



// Param for NetBanking, StoredCard, CashCard, EMI
@property (strong, nonatomic) NSString * bankCode;

// Param for OneTap
@property (strong, nonatomic) NSDictionary *OneTapTokenDictionary;


//This param is for GetTransactionInfo API
@property (strong, nonatomic) NSString *startTime;
@property (strong, nonatomic) NSString *endTime;

//This param is for SaveuserCard API
@property (strong, nonatomic) NSString *duplicateCheck;
@property (strong, nonatomic) NSString *encryptionData;
@end
