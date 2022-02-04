//
//  PayUModelTokenizedPaymentDetails.h
//  PayUBizCoreKit
//
//  Created by Amit Salaria on 24/12/21.
//  Copyright © 2021 PayU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PayUModelTokenDetails.h"

@interface PayUModelTokenizedPaymentDetails : NSObject

@property (nonatomic, strong) NSString * cardNo;
@property (nonatomic, strong) NSString * cardToken;
@property (nonatomic, strong) NSString * cardType;
@property (nonatomic, strong) NSString * cardMode;
@property (nonatomic, strong) NSString * cardName;
@property (nonatomic, strong) NSString * cardPAR;
@property (nonatomic, strong) NSString * cryptogram;
@property (nonatomic, strong) NSString * trid;
@property (nonatomic, strong) NSString * tokenReferenceId;
@property (nonatomic, strong) NSString * oneClickFlow;
@property (nonatomic, strong) NSString * oneClickStatus;
@property (nonatomic, strong) NSString * oneClickCardAlias;
@property (nonatomic, strong) PayUModelTokenDetails * networkToken;

+(instancetype)prepareTokenizedPaymentDetailsFromResponse:(NSDictionary *) JSON;

@end

/*

 {
    "status":"1",
    "msg":"Instrument details",
    "details":{
       "one_click_status":"",
       "one_click_flow":"",
       "card_type":"VISA",
       "network_token":{
          "token_exp_yr":"2022",
          "token_exp_mon":"12",
          "token_value":"4489682380061439"
       },
       "trid":"400000340044",
       "card_mode":"",
       "token_refernce_id":"534160269c59eb67f84f19681cb7f501",
       "card_PAR":"V0010013021320427651459792018",
       "card_no":"XXXXXXXXXXXX0005",
       "one_click_card_alias":"",
       "card_token":"ef4bb7fe505e18ebf12b",
       "card_name":"",
       "cryptogram":"AgAAAGQBdCZtW8sAmbHTg0UAAAA="
    }
 }
 
 */
