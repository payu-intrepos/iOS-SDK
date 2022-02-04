//
//  PayUModelHashes.h
//  PayU_iOS_CoreSDK
//
//  Created by Umang Arya on 29/09/15.
//  Copyright © 2015 PayU. All rights reserved.
//

/*!
 * This class declares the properties that holds Hash related information.
 */
#import <Foundation/Foundation.h>

@interface PayUModelHashes : NSObject <NSCopying>

@property (strong, nonatomic) NSString * paymentHash;
@property (strong, nonatomic) NSString * paymentRelatedDetailsHash;
@property (strong, nonatomic) NSString * VASForMobileSDKHash;
@property (strong, nonatomic) NSString * deleteUserCardHash DEPRECATED_ATTRIBUTE;
@property (strong, nonatomic) NSString * editUserCardHash DEPRECATED_ATTRIBUTE;
@property (strong, nonatomic) NSString * saveUserCardHash DEPRECATED_ATTRIBUTE;
@property (strong, nonatomic) NSString * getUserCardHash DEPRECATED_ATTRIBUTE;
@property (strong, nonatomic) NSString * offerHash;
@property (strong, nonatomic) NSString * offerDetailsHash;
@property (strong, nonatomic) NSString * EMIDetailsHash;
@property (strong, nonatomic) NSString * eligibleBinsForEMI;
@property (strong, nonatomic) NSString * verifyTransactionHash;
@property (strong, nonatomic) NSString * deleteOneTapTokenHash;
@property (strong, nonatomic) NSString * checkIsDomesticHash;
@property (strong, nonatomic) NSString * getBinInfoHash;
@property (strong, nonatomic) NSString * getCheckoutDetailsHash;
@property (strong, nonatomic) NSString * getTransactionInfoHash;
@property (strong, nonatomic) NSString * lookupApiHash;
@property (strong, nonatomic) NSString * refundTransactionHash;
@property (strong, nonatomic) NSString * checkBalanceApiHash;
@property (strong, nonatomic) NSString * deleteTokenizedStoredCardHash;
@property (strong, nonatomic) NSString * getTokenizedStoredCardHash;
@property (strong, nonatomic) NSString * getTokenizedPaymentDetailHash;

/*
 get_merchant_ibibo_codes_hash"
 payment_hash"
 vas_for_mobile_sdk_hash"
 delete_user_card_hash"
 edit_user_card_hash"
 save_user_card_hash"
 payment_related_details_for_mobile_sdk_hash"
 get_user_cards_hash"
 check_offer_status_hash"
 */

@end
