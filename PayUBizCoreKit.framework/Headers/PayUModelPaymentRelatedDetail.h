//
//  PayUModelPaymentRelatedDetail.h
//  PayU_iOS_CoreSDK
//
//  Created by Umang Arya on 09/10/15.
//  Copyright © 2015 PayU. All rights reserved.
//

/*!
 * This class declares the properties that holds payment related details.
 */
#import <Foundation/Foundation.h>
#import "PayUModelNetBanking.h"
#import "PayUModelStoredCard.h"
#import "PayUModelCashCard.h"
#import "PayUModelEMI.h"

@interface PayUModelPaymentRelatedDetail : NSObject

@property (nonatomic, strong) NSArray *oneTapStoredCardArray;
@property (nonatomic, strong) NSArray *storedCardArray;
@property (nonatomic, strong) NSArray *netBankingArray;
@property (nonatomic, strong) NSArray *enachArray;
@property (nonatomic, strong) NSArray *siArray;
@property (nonatomic, strong) NSArray *cashCardArray;
@property (nonatomic, strong) NSArray *upiArray;
@property (nonatomic, strong) NSArray *EMIArray;
@property (nonatomic, strong) NSArray *ccArray;
@property (nonatomic, strong) NSArray *dcArray;
@property (nonatomic, strong) NSArray *NoCostEMIArray;
@property BOOL isDCSI;
@property BOOL isCCSI;
@property (nonatomic, strong) NSMutableArray *availablePaymentOptionsArray;

@end


/*
 URL:https://info.payu.in/merchant/postservice.php?form=2

 PostParam:
 instrument_id=12345678&instrument_type=iOS&device_type=2&key=smsplus&command=payment_related_details_for_mobile_sdk&var1=ra:ra&hash=0ae36f0d580b261b910ab918836bc4fb17e37b208723a0ef06764ef226ac8896a5c37524d6df844bea7e1bc6f111fc1b8edf1d01da6fae1b4534ae1d747f4dc1



 Response:

 {
   "ibiboCodes" : {
     "qr" : {
       "CCQR" : {
         "show_form" : "0",
         "title" : "CC Online Dynamic QR",
         "pgId" : "236",
         "pt_priority" : "100",
         "bank_id" : null
       },
       "UPIQR" : {
         "show_form" : "0",
         "title" : "UPI Online Dynamic QR",
         "pgId" : "236",
         "pt_priority" : "100",
         "bank_id" : null
       },
       "VDCQR" : {
         "show_form" : "0",
         "title" : "Visa DC Online Dynamic Bharat QR",
         "pgId" : "236",
         "pt_priority" : "100",
         "bank_id" : null
       },
       "MDCQR" : {
         "show_form" : "0",
         "title" : "Master DC Online Dynamic Bharat QR",
         "pgId" : "236",
         "pt_priority" : "100",
         "bank_id" : null
       },
       "RDCQR" : {
         "show_form" : "0",
         "title" : "Rupay DC Online Dynamic Bharat QR",
         "pgId" : "236",
         "pt_priority" : "100",
         "bank_id" : null
       },
       "VCCQR" : {
         "show_form" : "0",
         "title" : "Visa CC Online Dynamic Bharat QR",
         "pgId" : "236",
         "pt_priority" : "100",
         "bank_id" : null
       },
       "DCQR" : {
         "show_form" : "0",
         "title" : "DC Online Dynamic QR",
         "pgId" : "236",
         "pt_priority" : "100",
         "bank_id" : null
       },
       "MCCQR" : {
         "show_form" : "0",
         "title" : "Master CC Online Dynamic Bharat QR",
         "pgId" : "236",
         "pt_priority" : "100",
         "bank_id" : null
       },
       "BQR" : {
         "show_form" : "0",
         "title" : "Online Dynamic QR",
         "pgId" : "236",
         "pt_priority" : "100",
         "bank_id" : null
       },
       "RCCQR" : {
         "show_form" : "0",
         "title" : "Rupay CC Online Dynamic Bharat QR",
         "pgId" : "236",
         "pt_priority" : "100",
         "bank_id" : null
       }
     },
     "upi" : {
       "TEZ" : {
         "show_form" : "0",
         "title" : "Google Tez",
         "pgId" : "162",
         "pt_priority" : "100",
         "bank_id" : null
       },
       "TEZOMNI" : {
         "show_form" : "0",
         "title" : "TEZ OMNI",
         "pgId" : "162",
         "pt_priority" : "100",
         "bank_id" : null
       },
       "INTENT" : {
         "show_form" : "0",
         "title" : "Generic Intent",
         "pgId" : "157",
         "pt_priority" : "100",
         "bank_id" : null
       },
       "UPI" : {
         "show_form" : "0",
         "title" : "UPI",
         "pgId" : "283",
         "pt_priority" : "100",
         "bank_id" : null
       }
     },
     "dbqr" : {
       "CCDBQR" : {
         "show_form" : "0",
         "title" : "CC Offline Dynamic Bharat QR",
         "pgId" : "236",
         "pt_priority" : "100",
         "bank_id" : null
       },
       "DCDBQR" : {
         "show_form" : "0",
         "title" : "DC Offline Dynamic Bharat QR",
         "pgId" : "236",
         "pt_priority" : "100",
         "bank_id" : null
       },
       "RDCDBQR" : {
         "show_form" : "0",
         "title" : "Rupay DC Offline Dynamic Bharat QR",
         "pgId" : "236",
         "pt_priority" : "100",
         "bank_id" : null
       },
       "VCCDBQR" : {
         "show_form" : "0",
         "title" : "Visa CC Offline Dynamic Bharat QR",
         "pgId" : "236",
         "pt_priority" : "100",
         "bank_id" : null
       },
       "RCCDBQR" : {
         "show_form" : "0",
         "title" : "Rupay CC Offline Dynamic Bharat QR",
         "pgId" : "236",
         "pt_priority" : "100",
         "bank_id" : null
       },
       "MDCDBQR" : {
         "show_form" : "0",
         "title" : "Master DC Offline Dynamic Bharat QR",
         "pgId" : "236",
         "pt_priority" : "100",
         "bank_id" : null
       },
       "MCCDBQR" : {
         "show_form" : "0",
         "title" : "Master CC Offline Dynamic Bharat QR",
         "pgId" : "236",
         "pt_priority" : "100",
         "bank_id" : null
       },
       "UPIDBQR" : {
         "show_form" : "0",
         "title" : "UPI Offline Dynamic Bharat QR",
         "pgId" : "236",
         "pt_priority" : "100",
         "bank_id" : null
       },
       "VDCDBQR" : {
         "show_form" : "0",
         "title" : "Visa DC Offline Dynamic Bharat QR",
         "pgId" : "236",
         "pt_priority" : "100",
         "bank_id" : null
       },
       "DBQR" : {
         "show_form" : "0",
         "title" : "Offline Dynamic Bharat QR",
         "pgId" : "236",
         "pt_priority" : "100",
         "bank_id" : null
       }
     },

     "no_cost_emi" : {
       "EMIRBL3" : {
         "show_form" : "0",
         "title" : "3 Months",
         "bank" : "RBL",
         "pgId" : "321",
         "pt_priority" : "100",
         "bank_id" : null

       },
       "EMIA9" : {
         "show_form" : "0",
         "title" : "9 Months",
         "bank" : "AXIS",
         "pgId" : "321",
         "pt_priority" : "100",
         "bank_id" : null
       },
       "EMIIC12" : {
         "show_form" : "0",
         "title" : "12 Months",
         "bank" : "ICICI",
         "pgId" : "321",
         "pt_priority" : "100",
         "bank_id" : null
       },
       "EMIK6" : {
         "show_form" : "0",
         "title" : "6 Months",
         "bank" : "KOTAK",
         "pgId" : "321",
         "pt_priority" : "100",
         "bank_id" : null
       },
       "BAJFIN09" : {
         "show_form" : "1",
         "title" : "9 Months",
         "bank" : "BAJFIN",
         "pgId" : "274",
         "pt_priority" : "100",
         "bank_id" : null
       },
       "EMIRBL12" : {
         "show_form" : "0",
         "title" : "12 Months",
         "bank" : "RBL",
         "pgId" : "321",
         "pt_priority" : "100",
         "bank_id" : null
       },
       "EMIRBL6" : {
         "show_form" : "0",
         "title" : "6 Months",
         "bank" : "RBL",
         "pgId" : "321",
         "pt_priority" : "100",
         "bank_id" : null
       },
       "EMICB9" : {
         "show_form" : "0",
         "title" : "9 Months",
         "bank" : "CORP",
         "pgId" : "321",
         "pt_priority" : "100",
         "bank_id" : null
       },
       "EMISCB12" : {
         "show_form" : "0",
         "title" : "12 Months",
         "bank" : "SCB",
         "pgId" : "321",
         "pt_priority" : "100",
         "bank_id" : null
       },
       "EMIIC24" : {
         "show_form" : "0",
         "title" : "24 Months",
         "bank" : "ICICI",
         "pgId" : "321",
         "pt_priority" : "100",
         "bank_id" : null
       },
       "EMISCB3" : {
         "show_form" : "0",
         "title" : "3 Months",
         "bank" : "SCB",
         "pgId" : "321",
         "pt_priority" : "100",
         "bank_id" : null
       },
       "EMIIC18" : {
         "show_form" : "0",
         "title" : "18 Months",
         "bank" : "ICICI",
         "pgId" : "321",
         "pt_priority" : "100",
         "bank_id" : null
       },
       "EMIRBL9" : {
         "show_form" : "0",
         "title" : "9 Months",
         "bank" : "RBL",
         "pgId" : "321",
         "pt_priority" : "100",
         "bank_id" : null
       },
       "EMISCB6" : {
         "show_form" : "0",
         "title" : "6 Months",
         "bank" : "SCB",
         "pgId" : "321",
         "pt_priority" : "100",
         "bank_id" : null
       },
       "EMIRBL24" : {
         "show_form" : "0",
         "title" : "24 Months",
         "bank" : "RBL",
         "pgId" : "321",
         "pt_priority" : "100",
         "bank_id" : null
       },
       "EMIA12" : {
         "show_form" : "0",
         "title" : "12 Months",
         "bank" : "AXIS",
         "pgId" : "321",
         "pt_priority" : "100",
         "bank_id" : null
       },
       "EMIIND12" : {
         "show_form" : "0",
         "title" : "12 Months",
         "bank" : "INDUS",
         "pgId" : "321",
         "pt_priority" : "100",
         "bank_id" : null
       },
       "EMIRBL18" : {
         "show_form" : "0",
         "title" : "18 Months",
         "bank" : "RBL",
         "pgId" : "321",
         "pt_priority" : "100",
         "bank_id" : null
       },
       "EMIIC3" : {
         "show_form" : "0",
         "title" : "3 Months",
         "bank" : "ICICI",
         "pgId" : "321",
         "pt_priority" : "100",
         "bank_id" : null
       },
       "EMI03" : {
         "show_form" : "1",
         "title" : "3 Months",
         "bank" : "CITI",
         "pgId" : "8",
         "pt_priority" : "100",
         "bank_id" : null
       },
       "EMISCB24" : {
         "show_form" : "0",
         "title" : "24 Months",
         "bank" : "SCB",
         "pgId" : "321",
         "pt_priority" : "100",
         "bank_id" : null
       },
       "EMISCB9" : {
         "show_form" : "0",
         "title" : "9 Months",
         "bank" : "SCB",
         "pgId" : "321",
         "pt_priority" : "100",
         "bank_id" : null
       },
       "ZESTMON" : {
         "show_form" : "1",
         "title" : "Zest Money EMI",
         "bank" : "ZESTMON",
         "pgId" : "273",
         "pt_priority" : "100",
         "bank_id" : null
       },
       "EMIK12" : {
         "show_form" : "0",
         "title" : "12 Months",
         "bank" : "KOTAK",
         "pgId" : "321",
         "pt_priority" : "100",
         "bank_id" : null
       },
       "EMISCB18" : {
         "show_form" : "0",
         "title" : "18 Months",
         "bank" : "SCB",
         "pgId" : "321",
         "pt_priority" : "100",
         "bank_id" : null
       },
       "EMIK3" : {
         "show_form" : "0",
         "title" : "3 Months",
         "bank" : "KOTAK",
         "pgId" : "321",
         "pt_priority" : "100",
         "bank_id" : null
       },
       "EMIA6" : {
         "show_form" : "0",
         "title" : "6 Months",
         "bank" : "AXIS",
         "pgId" : "321",
         "pt_priority" : "100",
         "bank_id" : null
       },
       "EMIIC9" : {
         "show_form" : "0",
         "title" : "9 Months",
         "bank" : "ICICI",
         "pgId" : "321",
         "pt_priority" : "100",
         "bank_id" : null
       },
       "EMI" : {
         "show_form" : "1",
         "title" : "3 Months",
         "bank" : "HDFC",
         "pgId" : "307",
         "pt_priority" : "100",
         "bank_id" : null
       },
       "EMIIND24" : {
         "show_form" : "0",
         "title" : "24 Months",
         "bank" : "INDUS",
         "pgId" : "321",
         "pt_priority" : "100",
         "bank_id" : null
       },
       "EMIK18" : {
         "show_form" : "0",
         "title" : "18 Months",
         "bank" : "KOTAK",
         "pgId" : "321",
         "pt_priority" : "100",
         "bank_id" : null
       },
       "EMIIND18" : {
         "show_form" : "0",
         "title" : "18 Months",
         "bank" : "INDUS",
         "pgId" : "321",
         "pt_priority" : "100",
         "bank_id" : null
       },
       "EMICB12" : {
         "show_form" : "0",
         "title" : "12 Months",
         "bank" : "CORP",
         "pgId" : "321",
         "pt_priority" : "100",
         "bank_id" : null
       },
       "ICICID03" : {
         "show_form" : "1",
         "title" : "3 Months",
         "bank" : "ICICID",
         "pgId" : "276",
         "pt_priority" : "100",
         "bank_id" : null
       },
       "EMICBI12" : {
         "show_form" : "0",
         "title" : "12 Months",
         "bank" : "CBIN",
         "pgId" : "321",
         "pt_priority" : "100",
         "bank_id" : null
       },
       "ICICID12" : {
         "show_form" : "1",
         "title" : "12 Months",
         "bank" : "ICICID",
         "pgId" : "276",
         "pt_priority" : "100",
         "bank_id" : null
       },
       "EMIIND36" : {
         "show_form" : "0",
         "title" : "36 Months",
         "bank" : "INDUS",
         "pgId" : "321",
         "pt_priority" : "100",
         "bank_id" : null
       },
       "ICICID06" : {
         "show_form" : "1",
         "title" : "6 Months",
         "bank" : "ICICID",
         "pgId" : "276",
         "pt_priority" : "100",
         "bank_id" : null
       },
       "EMIA3" : {
         "show_form" : "0",
         "title" : "3 Months",
         "bank" : "AXIS",
         "pgId" : "321",
         "pt_priority" : "100",
         "bank_id" : null
       },
       "EMICBI3" : {
         "show_form" : "0",
         "title" : "3 Months",
         "bank" : "CBIN",
         "pgId" : "321",
         "pt_priority" : "100",
         "bank_id" : null
       },
       "EMI6" : {
         "show_form" : "1",
         "title" : "6 Months",
         "bank" : "HDFC",
         "pgId" : "307",
         "pt_priority" : "100",
         "bank_id" : null
       },
       "EMIIND3" : {
         "show_form" : "0",
         "title" : "3 Months",
         "bank" : "INDUS",
         "pgId" : "321",
         "pt_priority" : "100",
         "bank_id" : null
       },
       "ICICID09" : {
         "show_form" : "1",
         "title" : "9 Months",
         "bank" : "ICICID",
         "pgId" : "276",
         "pt_priority" : "100",
         "bank_id" : null
       },
       "EMICBI6" : {
         "show_form" : "0",
         "title" : "6 Months",
         "bank" : "CBIN",
         "pgId" : "321",
         "pt_priority" : "100",
         "bank_id" : null
       },
       "EMICB6" : {
         "show_form" : "0",
         "title" : "6 Months",
         "bank" : "CORP",
         "pgId" : "321",
         "pt_priority" : "100",
         "bank_id" : null
       },
       "EMIIND6" : {
         "show_form" : "0",
         "title" : "6 Months",
         "bank" : "INDUS",
         "pgId" : "321",
         "pt_priority" : "100",
         "bank_id" : null
       },
       "EMICBI9" : {
         "show_form" : "0",
         "title" : "9 Months",
         "bank" : "CBIN",
         "pgId" : "321",
         "pt_priority" : "100",
         "bank_id" : null
       },
       "EMIIND9" : {
         "show_form" : "0",
         "title" : "9 Months",
         "bank" : "INDUS",
         "pgId" : "321",
         "pt_priority" : "100",
         "bank_id" : null
       },
       "EMIIC6" : {
         "show_form" : "0",
         "title" : "6 Months",
         "bank" : "ICICI",
         "pgId" : "321",
         "pt_priority" : "100",
         "bank_id" : null
       },
       "HDFCD03" : {
         "show_form" : "1",
         "title" : "3 Months",
         "bank" : "HDFCD",
         "pgId" : "275",
         "pt_priority" : "100",
         "bank_id" : null
       },
       "BOBCC06" : {
         "show_form" : "1",
         "title" : "6 Months",
         "bank" : "BOB",
         "pgId" : "7",
         "pt_priority" : "100",
         "bank_id" : null
       },
       "HDFCD12" : {
         "show_form" : "1",
         "title" : "12 Months",
         "bank" : "HDFCD",
         "pgId" : "275",
         "pt_priority" : "100",
         "bank_id" : null
       },
       "EMIK24" : {
         "show_form" : "0",
         "title" : "24 Months",
         "bank" : "KOTAK",
         "pgId" : "321",
         "pt_priority" : "100",
         "bank_id" : null
       },
       "HDFCD06" : {
         "show_form" : "1",
         "title" : "6 Months",
         "bank" : "HDFCD",
         "pgId" : "275",
         "pt_priority" : "100",
         "bank_id" : null
       },
       "EMIK9" : {
         "show_form" : "0",
         "title" : "9 Months",
         "bank" : "KOTAK",
         "pgId" : "321",
         "pt_priority" : "100",
         "bank_id" : null
       },
       "EMIHS03" : {
         "show_form" : "0",
         "title" : "3 Months",
         "bank" : "HSBC",
         "pgId" : "321",
         "pt_priority" : "100",
         "bank_id" : null
       },
       "HDFCD09" : {
         "show_form" : "1",
         "title" : "9 Months",
         "bank" : "HDFCD",
         "pgId" : "275",
         "pt_priority" : "100",
         "bank_id" : null
       },
       "EMIHS12" : {
         "show_form" : "0",
         "title" : "12 Months",
         "bank" : "HSBC",
         "pgId" : "321",
         "pt_priority" : "100",
         "bank_id" : null
       },
       "BAJFIN03" : {
         "show_form" : "1",
         "title" : "3 Months",
         "bank" : "BAJFIN",
         "pgId" : "274",
         "pt_priority" : "100",
         "bank_id" : null
       },
       "HDFCD18" : {
         "show_form" : "1",
         "title" : "18 Months",
         "bank" : "HDFCD",
         "pgId" : "275",
         "pt_priority" : "100",
         "bank_id" : null
       },
       "EMIHS06" : {
         "show_form" : "0",
         "title" : "6 Months",
         "bank" : "HSBC",
         "pgId" : "321",
         "pt_priority" : "100",
         "bank_id" : null
       },
       "BAJFIN12" : {
         "show_form" : "1",
         "title" : "12 Months",
         "bank" : "BAJFIN",
         "pgId" : "274",
         "pt_priority" : "100",
         "bank_id" : null
       },
       "EMIHS09" : {
         "show_form" : "0",
         "title" : "9 Months",
         "bank" : "HSBC",
         "pgId" : "321",
         "pt_priority" : "100",
         "bank_id" : null
       },
       "BAJFIN06" : {
         "show_form" : "1",
         "title" : "6 Months",
         "bank" : "BAJFIN",
         "pgId" : "274",
         "pt_priority" : "100",
         "bank_id" : null
       },
       "EMIHS18" : {
         "show_form" : "0",
         "title" : "18 Months",
         "bank" : "HSBC",
         "pgId" : "321",
         "pt_priority" : "100",
         "bank_id" : null
       },
       "EMAMEX12" : {
         "show_form" : "1",
         "title" : "12 months",
         "bank" : "AMEX",
         "pgId" : "54",
         "pt_priority" : "100",
         "bank_id" : null
       }
     },
     "creditcard" : {
       "DINR" : {
         "show_form" : "0",
         "title" : "Diners Credit Card",
         "pgId" : "321",
         "pt_priority" : "100",
         "bank_id" : null
       },
       "RUPAYCC" : {
         "show_form" : "1",
         "title" : "Rupay Credit Card",
         "pgId" : "147",
         "pt_priority" : "100",
         "bank_id" : null
       },
       "AMEX" : {
         "show_form" : "1",
         "title" : "AMEX Cards",
         "pgId" : "54",
         "pt_priority" : "100",
         "bank_id" : null
       },
       "CC" : {
         "show_form" : "0",
         "title" : "Credit Card",
         "pgId" : "321",
         "pt_priority" : "100",
         "bank_id" : null
       }
     },
     "ofupi" : {
       "OFINTENT" : {
         "show_form" : "0",
         "title" : "Offline Intent",
         "pgId" : "236",
         "pt_priority" : "100",
         "bank_id" : null
       }
     },
     "bangla" : {
       "SSL" : {
         "show_form" : "0",
         "title" : "SSLCommerz",
         "pgId" : "232",
         "pt_priority" : "100",
         "bank_id" : null
       }
     },
     "visac" : {
       "VISAC" : {
         "show_form" : "0",
         "title" : "VISA CHECKOUT CREDIT",
         "pgId" : "193",
         "pt_priority" : "100",
         "bank_id" : null
       }
     },
     "netbanking" : {
       "IDFCNB" : {
         "show_form" : "0",
         "title" : "IDFC FIRST Bank",
         "pgId" : "154",
         "pt_priority" : "44",
         "bank_id" : null
       },
       "KRVB" : {
         "show_form" : "0",
         "title" : "Karur Vysya Bank",
         "pgId" : "71",
         "pt_priority" : "56",
         "bank_id" : null
       },
       "AXNBTPV" : {
         "show_form" : "0",
         "title" : "Axis NB TPV",
         "pgId" : "23",
         "pt_priority" : "12",
         "bank_id" : null
       },
       "SBINBTPV" : {
         "show_form" : "0",
         "title" : "State Bank Of India - TPV",
         "pgId" : "39",
         "pt_priority" : "83",
         "bank_id" : null
       },
       "FEDB" : {
         "show_form" : "0",
         "title" : "Federal Bank",
         "pgId" : "59",
         "pt_priority" : "37",
         "bank_id" : null
       },
       "AXISCNB" : {
         "show_form" : "0",
         "title" : "Axis Corporate Netbanking",
         "pgId" : "260",
         "pt_priority" : "11",
         "bank_id" : null
       },
       "CSMSNB" : {
         "show_form" : "0",
         "title" : "Cosmos Bank",
         "pgId" : "118",
         "pt_priority" : "28",
         "bank_id" : null
       },
       "TBON" : {
         "show_form" : "0",
         "title" : "The Nainital Bank",
         "pgId" : "132",
         "pt_priority" : "90",
         "bank_id" : null
       },
       "SOIB" : {
         "show_form" : "0",
         "title" : "South Indian Bank",
         "pgId" : "36",
         "pt_priority" : "76",
         "bank_id" : null
       },
       "ABIRLA" : {
         "show_form" : "0",
         "title" : "Aditya Birla Payments Bank",
         "pgId" : "257",
         "pt_priority" : "6",
         "bank_id" : null
       },
       "UNIB" : {
         "show_form" : "0",
         "title" : "PNB (Erstwhile-United Bank of India)",
         "pgId" : "63",
         "pt_priority" : "95",
         "bank_id" : null
       },
       "KRVBC" : {
         "show_form" : "0",
         "title" : "Karur Vysya - Corporate Banking",
         "pgId" : "71",
         "pt_priority" : "55",
         "bank_id" : null
       },
       "INOB" : {
         "show_form" : "0",
         "title" : "Indian Overseas Bank",
         "pgId" : "45",
         "pt_priority" : "47",
         "bank_id" : null
       },
       "SBNCORP" : {
         "show_form" : "0",
         "title" : "State Bank of India (Corporate)",
         "pgId" : "39",
         "pt_priority" : "82",
         "bank_id" : null
       },
       "SYNDB" : {
         "show_form" : "0",
         "title" : "Syndicate Bank",
         "pgId" : "107",
         "pt_priority" : "88",
         "bank_id" : null
       },
       "PNBB" : {
         "show_form" : "0",
         "title" : "Punjab National Bank",
         "pgId" : "102",
         "pt_priority" : "67",
         "bank_id" : null
       },
       "SVCNB" : {
         "show_form" : "0",
         "title" : "Shamrao Vithal Co-operative Bank Ltd.",
         "pgId" : "122",
         "pt_priority" : "75",
         "bank_id" : null
       },
       "BOMB" : {
         "show_form" : "0",
         "title" : "Bank of Maharashtra",
         "pgId" : "58",
         "pt_priority" : "17",
         "bank_id" : null
       },
       "AIRNB" : {
         "show_form" : "0",
         "title" : "Airtel Payments Bank",
         "pgId" : "158",
         "pt_priority" : "7",
         "bank_id" : null
       },
       "DLSB" : {
         "show_form" : "0",
         "title" : "Dhanlaxmi Bank - Retail",
         "pgId" : "89",
         "pt_priority" : "34",
         "bank_id" : null
       },
       "UCOB" : {
         "show_form" : "0",
         "title" : "UCO Bank",
         "pgId" : "109",
         "pt_priority" : "91",
         "bank_id" : null
       },
       "DSHB" : {
         "show_form" : "0",
         "title" : "Deutsche Bank",
         "pgId" : "64",
         "pt_priority" : "32",
         "bank_id" : null
       },
       "SRSWT" : {
         "show_form" : "0",
         "title" : "Saraswat Bank",
         "pgId" : "93",
         "pt_priority" : "73",
         "bank_id" : null
       },
       "YESNBTPV" : {
         "show_form" : "0",
         "title" : "Yes Bank - NB TPV",
         "pgId" : "26",
         "pt_priority" : "98",
         "bank_id" : null
       },
       "VJYB" : {
         "show_form" : "0",
         "title" : "Vijaya Bank",
         "pgId" : "70",
         "pt_priority" : "96",
         "bank_id" : null
       },
       "JANANB" : {
         "show_form" : "0",
         "title" : "Jana Small Finance Bank",
         "pgId" : "322",
         "pt_priority" : "52",
         "bank_id" : null
       },
       "SBIB" : {
         "show_form" : "0",
         "title" : "State Bank of India",
         "pgId" : "39",
         "pt_priority" : "4",
         "bank_id" : null
       },
       "JSBNB" : {
         "show_form" : "0",
         "title" : "Janata Sahakari Bank Pune",
         "pgId" : "120",
         "pt_priority" : "53",
         "bank_id" : null
       },
       "DENN" : {
         "show_form" : "0",
         "title" : "Dena Bank",
         "pgId" : "134",
         "pt_priority" : "31",
         "bank_id" : null
       },
       "RBL" : {
         "show_form" : "0",
         "title" : "RBL Bank",
         "pgId" : "190",
         "pt_priority" : "71",
         "bank_id" : null
       },
       "CPNB" : {
         "show_form" : "0",
         "title" : "Punjab National Bank - Corporate Banking",
         "pgId" : "105",
         "pt_priority" : "68",
         "bank_id" : null
       },
       "TMBB" : {
         "show_form" : "0",
         "title" : "Tamilnad Mercantile Bank",
         "pgId" : "114",
         "pt_priority" : "89",
         "bank_id" : null
       },
       "ICIB" : {
         "show_form" : "0",
         "title" : "ICICI Bank",
         "pgId" : "19",
         "pt_priority" : "3",
         "bank_id" : null
       },
       "JAKB" : {
         "show_form" : "0",
         "title" : "Jammu & Kashmir Bank",
         "pgId" : "37",
         "pt_priority" : "51",
         "bank_id" : null
       },
       "OBCB" : {
         "show_form" : "0",
         "title" : "PNB (Erstwhile -Oriental Bank of Commerce)",
         "pgId" : "112",
         "pt_priority" : "63",
         "bank_id" : null
       },
       "BBCB" : {
         "show_form" : "0",
         "title" : "Bank of Baroda - Corporate Banking",
         "pgId" : "1",
         "pt_priority" : "15",
         "bank_id" : null
       },
       "CABB" : {
         "show_form" : "0",
         "title" : "Canara Bank",
         "pgId" : "69",
         "pt_priority" : "19",
         "bank_id" : null
       },
       "KRKB" : {
         "show_form" : "0",
         "title" : "Karnataka Bank",
         "pgId" : "35",
         "pt_priority" : "54",
         "bank_id" : null
       },
       "BBRB" : {
         "show_form" : "0",
         "title" : "Bank of Baroda",
         "pgId" : "190",
         "pt_priority" : "14",
         "bank_id" : null
       },
       "CBIB" : {
         "show_form" : "0",
         "title" : "Central Bank Of India",
         "pgId" : "68",
         "pt_priority" : "23",
         "bank_id" : null
       },
       "DCBB" : {
         "show_form" : "0",
         "title" : "DCB Bank",
         "pgId" : "42",
         "pt_priority" : "30",
         "bank_id" : null
       },
       "BOIB" : {
         "show_form" : "0",
         "title" : "Bank of India",
         "pgId" : "53",
         "pt_priority" : "16",
         "bank_id" : null
       },
       "UBIB" : {
         "show_form" : "0",
         "title" : "Union Bank",
         "pgId" : "25",
         "pt_priority" : "93",
         "bank_id" : null
       },
       "CUBB" : {
         "show_form" : "0",
         "title" : "City Union Bank",
         "pgId" : "67",
         "pt_priority" : "25",
         "bank_id" : null
       },
       "CRPB" : {
         "show_form" : "0",
         "title" : "Union Bank of India (Erstwhile Corporation Bank)",
         "pgId" : "33",
         "pt_priority" : "94",
         "bank_id" : null
       },
       "PSBNB" : {
         "show_form" : "0",
         "title" : "Punjab & Sind Bank",
         "pgId" : "128",
         "pt_priority" : "66",
         "bank_id" : null
       },
       "INDB" : {
         "show_form" : "0",
         "title" : "Indian Bank ",
         "pgId" : "74",
         "pt_priority" : "46",
         "bank_id" : null
       },
       "INIB" : {
         "show_form" : "0",
         "title" : "IndusInd Bank",
         "pgId" : "28",
         "pt_priority" : "49",
         "bank_id" : null
       },
       "YESB" : {
         "show_form" : "0",
         "title" : "Yes Bank",
         "pgId" : "26",
         "pt_priority" : "97",
         "bank_id" : null
       },
       "CBNBTPV" : {
         "show_form" : "0",
         "title" : "Canara Bank TPV",
         "pgId" : "69",
         "pt_priority" : "20",
         "bank_id" : null
       },
       "HDFNBTPV" : {
         "show_form" : "0",
         "title" : "HDFC NB - TPV",
         "pgId" : "56",
         "pt_priority" : "39",
         "bank_id" : null
       },
       "ABNBTPV" : {
         "show_form" : "0",
         "title" : "Andhra NB TPV",
         "pgId" : "81",
         "pt_priority" : "10",
         "bank_id" : null
       },
       "LVRB" : {
         "show_form" : "0",
         "title" : "Lakshmi Vilas Bank",
         "pgId" : "116",
         "pt_priority" : "60",
         "bank_id" : null
       },
       "162B" : {
         "show_form" : "0",
         "title" : "Kotak Mahindra Bank",
         "pgId" : "77",
         "pt_priority" : "5",
         "bank_id" : null
       },
       "AXIB" : {
         "show_form" : "0",
         "title" : "AXIS Bank",
         "pgId" : "23",
         "pt_priority" : "1",
         "bank_id" : null
       },
       "CSBN" : {
         "show_form" : "0",
         "title" : "Catholic Syrian Bank",
         "pgId" : "60",
         "pt_priority" : "21",
         "bank_id" : null
       },
       "HDFCCONB" : {
         "show_form" : "0",
         "title" : "HDFC Bank - Corporate Banking",
         "pgId" : "221",
         "pt_priority" : "38",
         "bank_id" : null
       },
       "IDBB" : {
         "show_form" : "0",
         "title" : "IDBI Bank",
         "pgId" : "32",
         "pt_priority" : "43",
         "bank_id" : null
       },
       "UBIBC" : {
         "show_form" : "0",
         "title" : "Union Bank - Corporate Banking",
         "pgId" : "25",
         "pt_priority" : "92",
         "bank_id" : null
       },
       "ADBB" : {
         "show_form" : "0",
         "title" : "Union Bank of India (Erstwhile Andhra Bank)",
         "pgId" : "81",
         "pt_priority" : "9",
         "bank_id" : null
       }
     },
     "cashcard" : {
       "AMZPAY" : {
         "show_form" : "0",
         "title" : "Amazon Pay",
         "pgId" : "244",
         "pt_priority" : "100",
         "bank_id" : null
       },
       "FREC" : {
         "show_form" : "0",
         "title" : "Freecharge Wallet",
         "pgId" : "321",
         "pt_priority" : "100",
         "bank_id" : null
       },
       "PPINTENT" : {
         "show_form" : "0",
         "title" : "PhonePe Intent",
         "pgId" : "235",
         "pt_priority" : "100",
         "bank_id" : null
       },
       "OLAM" : {
         "show_form" : "0",
         "title" : "OlaMoney(Postpaid+Wallet)",
         "pgId" : "245",
         "pt_priority" : "100",
         "bank_id" : null
       },
       "PAYZ" : {
         "show_form" : "0",
         "title" : "HDFC Bank - PayZapp",
         "pgId" : "129",
         "pt_priority" : "100",
         "bank_id" : null
       },
       "PHONEPE" : {
         "show_form" : "0",
         "title" : "PhonePe\/BHIM UPI",
         "pgId" : "235",
         "pt_priority" : "100",
         "bank_id" : null
       },
       "YESW" : {
         "show_form" : "0",
         "title" : "YES PAY Wallet",
         "pgId" : "123",
         "pt_priority" : "100",
         "bank_id" : null
       },
       "JIOM" : {
         "show_form" : "0",
         "title" : "Jio Money",
         "pgId" : "191",
         "pt_priority" : "100",
         "bank_id" : null
       },
       "PAYTM" : {
         "show_form" : "0",
         "title" : "Paytm",
         "pgId" : "253",
         "pt_priority" : "100",
         "bank_id" : null
       },
       "AMON" : {
         "show_form" : "0",
         "title" : "Airtel Money",
         "pgId" : "30",
         "pt_priority" : "100",
         "bank_id" : null
       }
     },
     "enach" : {
       "KKBKENCC" : {
         "show_form" : "0",
         "title" : "Kotak Mahindra Bank",
         "pgId" : "266",
         "pt_priority" : "5",
         "bank_id" : null
       },
       "ICICENCC" : {
         "show_form" : "0",
         "title" : "ICICI Bank",
         "pgId" : "266",
         "pt_priority" : "3",
         "bank_id" : null
       }
     },
     "debitcard" : {
       "RUPAY" : {
         "show_form" : "1",
         "title" : "Rupay Debit Card",
         "pgId" : "147",
         "pt_priority" : "5",
         "bank_id" : null
       },
       "VISA" : {
         "show_form" : "1",
         "title" : "Visa Debit Cards (All Banks)",
         "pgId" : "211",
         "pt_priority" : "2",
         "bank_id" : null
       },
       "MAST" : {
         "show_form" : "1",
         "title" : "MasterCard Debit Cards",
         "pgId" : "211",
         "pt_priority" : "1",
         "bank_id" : null
       }
     },
     "isbqr" : {
       "ISBQR" : {
         "show_form" : "0",
         "title" : "Offline Integrated Static Bharat QR",
         "pgId" : "236",
         "pt_priority" : "100",
         "bank_id" : null
       }
     },
     "aadhaarpay" : {
       "ADHR" : {
         "show_form" : "0",
         "title" : "Aadhaar Pay",
         "pgId" : "315",
         "pt_priority" : "100",
         "bank_id" : null
       }
     },
     "sbqr" : {
       "SBQR" : {
         "show_form" : "0",
         "title" : "Offline Static Bharat QR",
         "pgId" : "236",
         "pt_priority" : "100",
         "bank_id" : null
       }
     },
     "standinginstruction" : {
       "KKBKENCR" : {
         "show_form" : "0",
         "title" : "KOTAK MAHINDRA BANK LTD Recurring",
         "pgId" : "266",
         "pt_priority" : "5",
         "bank_id" : null
       },
       "ICICENCR" : {
         "show_form" : "0",
         "title" : "ICICI BANK LTD Recurring",
         "pgId" : "266",
         "pt_priority" : "3",
         "bank_id" : null
       },
       "DCSI" : {
         "show_form" : "1",
         "title" : "Standing Instruction DC",
         "pgId" : "310",
         "pt_priority" : "100",
         "bank_id" : null
       },
       "HDFCDCSI" : {
         "show_form" : "1",
         "title" : "Standing Instruction DC",
         "pgId" : "310",
         "pt_priority" : "100",
         "bank_id" : null
       },
       "CCSI" : {
         "show_form" : "1",
         "title" : "Standing Instruction CC",
         "pgId" : "310",
         "pt_priority" : "100",
         "bank_id" : null
       }
     },
     "ivr" : {
       "IVR" : {
         "show_form" : "1",
         "title" : "IVR",
         "pgId" : "8",
         "pt_priority" : "100",
         "bank_id" : null
       }
     },
     "lazypay" : {
       "LAZYPAY" : {
         "show_form" : "0",
         "title" : "LazyPay",
         "pgId" : "185",
         "pt_priority" : "100",
         "bank_id" : null
       }
     }
   },
   "userCards" : {
     "status" : 0,
     "msg" : "Card not found."
   }
 }
 */



