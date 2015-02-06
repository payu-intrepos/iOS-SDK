//
//  PayUConstant.h
//  PayU_iOS_SDK
//
//  Created by Suryakant Sharma on 05/12/14.
//  Copyright (c) 2014 PayU, India. All rights reserved.
//

#ifndef PayU_iOS_SDK_PayUConstant_h
#define PayU_iOS_SDK_PayUConstant_h

// Test URL
#define PAYU_PAYMENT_BASE_URL_TEST @"https://test.payu.in/_payment"
#define PAYU_PAYMENT_ALL_AVAILABLE_PAYMENT_OPTION_TEST  @"https://test.payu.in/merchant/postservice?form=2"

// Production
#define PAYU_PAYMENT_BASE_URL_PRODUCTION @"https://secure.payu.in/_payment"
#define PAYU_PAYMENT_ALL_AVAILABLE_PAYMENT_OPTION_PRODUCTION  @"https://info.payu.in/merchant/postservice.php?form=2"



//All Required or option Param defines
#define     PARAM_KEY                       @"key"
#define     PARAM_COMMAND                   @"command"
#define     PARAM_HASH                      @"hash"
#define     PARAM_SALT                      @"salt"
#define     PARAM_VAR1                      @"var1"
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


#define     PARAM_PG                        @"pg"
#define     PARAM_BANK_CODE                 @"bankcode"
#define     PARAM_CARD_NUMBER               @"ccnum"
#define     PARAM_CARD_NAME                 @"ccname"
#define     PARAM_CARD_CVV                  @"ccvv"
#define     PARAM_CARD_EXPIRY_MONTH         @"ccexpmon"
#define     PARAM_CARD_EXPIRY_YEAR          @"ccexpyr"

#define     PARAM_CARD_TOKEN                @"card_token"


// Stored Card operations

#define  PARAM_GET_STORED_CARD              @"get_user_cards"

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
#define     PARAM_PAYU_MONEY                @"payumobey"
#define     PARAM_STORE_CARD                @"storedcards"
#define     PARAM_CASH_ON_DILEVERY          @"cod"


#define     IPHONE_3_5   480

/*#ifdef DEBUG
#    define DLog(...) NSLog(__VA_ARGS__)
#else
#    define DLog(...)
#endif
#define ALog(...) NSLog(__VA_ARGS__)*/


//HTTP methods
#define  POST  @"POST"
#define  GET   @"GET"

#endif
