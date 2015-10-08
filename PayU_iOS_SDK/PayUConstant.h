//
//  PayUConstant.h
//  PayU_iOS_SDK
//
//  Created by Suryakant Sharma on 05/12/14.
//  Copyright (c) 2014 PayU, India. All rights reserved.
//

#ifndef PayU_iOS_SDK_PayUConstant_h
#define PayU_iOS_SDK_PayUConstant_h

#import "PayUErrorConstant.h"
#import "PayUNotificationConstant.h"

/*#ifdef DEBUG

// Something to log your sensitive data here

#else

//

#endif*/


// Test URL
#define PAYU_PAYMENT_BASE_URL_TEST @"https://mobiletest.payu.in/_payment"
#define PAYU_PAYMENT_ALL_AVAILABLE_PAYMENT_OPTION_TEST  @"https://mobiletest.payu.in/merchant/postservice?form=2"

// Production
#define PAYU_PAYMENT_BASE_URL_PRODUCTION @"https://secure.payu.in/_payment"
#define PAYU_PAYMENT_ALL_AVAILABLE_PAYMENT_OPTION_PRODUCTION  @"https://info.payu.in/merchant/postservice.php?form=2"

// 0 for UIWebView, 1 for WKWebView
#define IS_WKWEBVIEW 0

// 0 for Test server, 1 for MobileTest server and 2 for Production server
#define CB_SERVER_ID 2

// 0 if pointing to payu production server, 1 for test server
#define TEST_SERVER 0

#if  TEST_SERVER
#define PAYU_PAYMENT_BASE_URL                          PAYU_PAYMENT_BASE_URL_TEST
#define PAYU_PAYMENT_ALL_AVAILABLE_PAYMENT_OPTION      PAYU_PAYMENT_ALL_AVAILABLE_PAYMENT_OPTION_TEST
#else
#define PAYU_PAYMENT_BASE_URL                          PAYU_PAYMENT_BASE_URL_PRODUCTION
#define PAYU_PAYMENT_ALL_AVAILABLE_PAYMENT_OPTION      PAYU_PAYMENT_ALL_AVAILABLE_PAYMENT_OPTION_PRODUCTION
#endif

/*
  0 = SDK will calculate Hash
  1 = Merchant will provide hash
  2 = PayU server provide hash, for external use only.
 */

#define HASH_KEY_GENERATION_FROM_SERVER 1



// Different Hash KEYS



#define     PAYMENT_HASH_OLD                @"paymentHash"
#define     MOBILE_SDK                  @"mobileSdk"
#define     DELETE_HASH                 @"deleteHash" //delete_user_card
#define     EDIT_USER_CARD_HASH_OLD     @"editUserCardHash" //edit_user_card
#define     SAVE_USER_CARD_HASH         @"saveUserCardHash"
#define     DETAILS_FOR_MOBILE_SDK      @"detailsForMobileSdk"
#define     GET_USER_CAR_HASH           @"getUserCardHash"


#define     GET_MERCHANT_IBIBO_CODES                @"get_merchant_ibibo_codes_hash"
#define     PAYMENT_HASH                            @"payment_hash"
#define     VAS_FOR_MOBILE_SDK                      @"vas_for_mobile_sdk_hash"
#define     DELETE_USER_CARD                        @"delete_user_card_hash"
#define     EDIT_USER_CARD                          @"edit_user_card_hash"
#define     SAVE_USER_CARD                          @"save_user_card_hash"
#define     PAYMENT_RELATED_DETAILS_FOR_MOBILE_SDK  @"payment_related_details_for_mobile_sdk_hash"
#define     GET_USER_CARDS                          @"get_user_cards_hash"
#define     CHECK_OFFER_STATUS_HASH                 @"check_offer_status_hash"


//All Required or option Param defines
#define     PARAM_KEY                       @"key"
#define     PARAM_COMMAND                   @"command"
#define     PARAM_HASH                      @"hash"
#define     PARAM_SALT                      @"salt"
#define     PARAM_VAR1                      @"var1"
#define     PARAM_VAR2                      @"var2"

#define     PARAM_TXID                      @"txnid"
#define     PARAM_TOTAL_AMOUNT              @"amount"
#define     PARAM_PRODUCT_INFO              @"productinfo"
#define     PARAM_FIRST_NAME                @"firstname"
#define     PARAM_LAST_NAME                 @"lastname"
#define     PARAM_EMAIL                     @"email"
#define     PARAM_PHONE                     @"phone"
#define     PARAM_ADDRESS_1                 @"address1"
#define     PARAM_ADDRESS_2                 @"address2"
#define     PARAM_CITY                      @"city"
#define     PARAM_STATE                     @"state"
#define     PARAM_COUNTRY                   @"country"
#define     PARAM_ZIPCODE                   @"zipcode"
#define     PARAM_UDF_1                     @"udf1"
#define     PARAM_UDF_2                     @"udf2"
#define     PARAM_UDF_3                     @"udf3"
#define     PARAM_UDF_4                     @"udf4"
#define     PARAM_UDF_5                     @"udf5"
#define     PARAM_SURL                      @"surl"
#define     PARAM_FURL                      @"furl"
#define     PARAM_CURL                      @"curl"
#define     PARAM_CODURL                    @"codurl"
#define     PARAM_DROP_CATEGORY             @"drop_category"
#define     PARAM_ENFORCE_PAYMENT_HOD       @"enforce_paymethod"
#define     PARAM_CUSTOM_NOTE               @"custom_note"
#define     PARAM_NOTE_CATEGORY             @"note_category"
#define     PARAM_API_VERSION               @"api_version"
#define     PARAM_SHIPPING_FIRSTNAME        @"shipping_firstname"
#define     PARAM_SHIPPING_LASTNAME         @"shipping_lastname"
#define     PARAM_SHIPPING_ADDRESS_1        @"shipping_address1"
#define     PARAM_SHIPPING_ADDRESS_2        @"shipping_address2"
#define     PARAM_SHIPPING_CITY             @"shipping_city"
#define     PARAM_SHIPPING_STATE            @"shipping_state"
#define     PARAM_SHIPPING_COUNTRY          @"shipping_country"
#define     PARAM_SHIPPING_ZIPCODE          @"shipping_zipcode"
#define     PARAM_SHIPPING_PHONE            @"shipping_phone"
#define     PARAM_OFFER_KEY                 @"offer_key"
#define     PARAM_DEVICE_TYPE               @"device_type"
#define     PARAM_INSTRUMENT_TYPE           @"instrument_type"
#define     PARAM_INSTRUMENT_ID             @"instrument_id"

#define     PARAM_OFFER_DISCOUNT            @"discount"
#define     CARD_TYPE @"CC"
#define     PARAM_PG                        @"pg"
#define     PARAM_BANK_CODE                 @"bankcode"
#define     PARAM_CARD_NUMBER               @"ccnum"
#define     PARAM_CARD_NAME                 @"ccname"
#define     PARAM_CARD_CVV                  @"ccvv"
#define     PARAM_CARD_EXPIRY_MONTH         @"ccexpmon"
#define     PARAM_CARD_EXPIRY_YEAR          @"ccexpyr"

#define     PARAM_CARD_TOKEN                @"store_card_token"

#define     PARAM_STORE_YOUR_CARD           @"store_card"
#define     PARAM_STORE_CARD_NAME           @"card_name"


// Stored Card operations

#define  PARAM_GET_STORED_CARD              @"get_user_cards"
#define  PARAM_DELETE_STORED_CARD           @"delete_user_card"


#define PARAM_VAS_COMMAND_VALUE             @"vas_for_mobile_sdk"
#define PARAM_CHECK_OFFER_STATUS            @"check_offer_status"

#define PARAM_SERVER_HASH_GENERATION_COMMAND @"mobileHashTestWs"

//IOS Identifier
#define     IOS_SDK                         @"2"
#define     PARAM_USER_CREDENTIALS          @"user_credentials"

// All bank option Param
#define     PARAM_DEBIT_CARD                @"debitcard"
#define     PARAM_CREDIT_CARD               @"creditcard"
#define     PARAM_NET_BANKING               @"netbanking"
#define     PARAM_EMI                       @"emi"
#define     PARAM_REWARD                    @"rewards"
#define     PARAM_CASH_CARD                 @"cashcard"
#define     PARAM_STORE_CARD                @"storedcards"
#define     PARAM_CASH_ON_DILEVERY          @"cod"
#define     PARAM_PAYU_MONEY                @"PayU Money"
#define     PARAM_PG_WALLET                 @"wallet"

#define     PARAM_CREDIT_DEBIT_CARD         @"Credit/Debit card"

#define BANK_TITLE              @"title"
#define NET_BANKING             @"netbanking"

#define INFO_DICT_RESPONSE      @"response"

#define INSTRUMENT_TYPE         @"iOS"

#define PARAM_PRODUCTION_OR_TEST_MODE  @"production"

#define  PG_URL_LIST @"pgUrlList"


#define     IPHONE_3_5    480
#define     IPHONE_4     568
#define     IPHONE_4_7   667
#define     IPHONE_5_5   736


#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)


/*
 #ifdef DEBUG
 #    define DLog(...) NSLog(__VA_ARGS__)
 #else
 #    define DLog(...)
 #endif
 #define ALog(...) NSLog(__VA_ARGS__)
 */




#ifdef DEBUG
#   define NSLog(...) NSLog(__VA_ARGS__)
#else
#   define NSLog(...)
#endif


//HTTP methods
#define  POST  @"POST"
#define  GET   @"GET"

#endif
