//
//  PayUJSONParser.h
//  PayU_iOS_CoreSDK
//
//  Created by Umang Arya on 09/10/15.
//  Copyright © 2015 PayU. All rights reserved.
//

/*!
 * This class is used to parse JSON
 */

#import <Foundation/Foundation.h>
#import "PayUModelPaymentRelatedDetail.h"
#import "PayUModelOfferStatus.h"
#import "PayUModelOfferDetails.h"
#import "PayUModelEMIDetails.h"
#import "PayUModelUPI.h"
#import "PayUModelCheckIsDomestic.h"
#import "PayUModelGetTxnInfo.h"
#import "PayUConstants.h"
#import "PayUModelSodexoCardDetail.h"
#import "PayUModelTokenizedPaymentDetails.h"
@import PayUParamsKit;

@interface PayUJSONParser : NSObject
typedef void (^completionBlockForJSONParserForFetchAsset)(PayUModelFetchAssets *assets ,NSString *errorMessage, id extraParam);
typedef void (^completionBlockForJSONParserForAddImpression)(NSString *successMessage,NSString *errorMessage, id extraParam);
typedef void (^completionBlockForJSONParserForUpdatePayUId)(NSString *successMessage,NSString *errorMessage, id extraParam);
typedef void (^completionBlockForJSONParserForAllOfferDetails)(PayUModelAllOfferDetail *offerDetails ,NSString *errorMessage, id extraParam);
typedef void (^completionBlockForJSONParserForValidateOfferDetails)(PayUModelOfferDetail *offerDetails ,NSString *errorMessage, id extraParam);
typedef void (^completionBlockForJSONParserForGETSDKConfiguration)(NSArray<PayUSDKConfiguration *> *configuration ,NSString *errorMessage, id extraParam);
typedef void (^completionBlockForJSONParserForGetTokenizedPaymentDetails)(PayUModelTokenizedPaymentDetails *tokenizedPaymentdetails, NSString *errorMessage, id extraParam);
typedef void (^completionBlockForJSONParserForSodexoCardDetail)(PayUModelSodexoCardDetail *sodexoCardDetail, NSString *errorMessage, id extraParam);
typedef void (^completionBlockForJSONParserforPaymentRelatedDetailForMobileSDK)(PayUModelPaymentRelatedDetail *paymentRelatedDetails ,NSString *errorMessage, id extraParam);
typedef void (^completionBlockForJSONParserForOfferStatus)(PayUModelOfferStatus *offerStatus ,NSString *errorMessage, id extraParam);
typedef void (^completionBlockForJSONParserForOfferDetails)(PayUModelOfferDetails *offerDetails ,NSString *errorMessage, id extraParam);
typedef void (^completionBlockForJSONParserForDeleteStoredCard)(NSString * deleteStoredCardStatus, NSString * deleteStoredCardMessage ,NSString *errorMessage, id extraParam);
typedef void (^completionBlockForJSONParserForGetEMIAmountAccordingToInterest)(NSDictionary *dictEMIDetails ,NSString *errorMessage, id extraParam);
typedef void (^completionBlockForJSONParserForEligibleBinsForEMI)(NSArray<PayUModelEMIDetails *> *arrEMIDetails ,NSString *errorMessage, id extraParam);
typedef void (^completionBlockForJSONParserForGetUserCards)(NSDictionary *dictStoredCard ,NSString *errorMessage, id extraParam);
typedef void (^completionBlockForJSONParserForVerifyPayment)(NSDictionary *dictVerifyPayment ,NSString *errorMessage, id extraParam);
typedef void (^completionBlockForJSONParserForDeleteOneTapToken)(NSString *deleteOneTapTokenMsg ,NSString *errorMessage, id extraParam);
typedef void (^completionBlockForJSONParserForCheckIsDomestic)(PayUModelCheckIsDomestic *checkIsDomestic , NSString *errorMessage, id extraParam);
typedef void (^completionBlockForJSONParserForGetBinInfo)(NSArray<PayUModelCheckIsDomestic*> *arrAllBin , NSString *errorMessage, id extraParam);

typedef void (^completionBlockForJSONParserForGetTransactionInfo)(NSArray *arrOfGetTxnInfo , NSString *errorMessage, id extraParam);
typedef void (^completionBlockForJSONParserForSaveUserCard)(PayUModelStoredCard *objStoredCard , NSString *errorMessage, id extraParam);
typedef void (^completionBlockForJSONParserForMCPLookup)(PayUModelMultiCurrencyPayment *mcpInfo , NSString *errorMessage, id extraParam);
typedef void (^completionBlockForJSONParserForRefund)(NSString *message , NSString *errorMessage, id extraParam);
typedef void (^completionBlockForJSONParserForVerifyIFSC)(PayUModelIFSCInfo *ifscInfo , NSString *errorMessage, id extraParam);

/*!
 * This method parse the JSON for CCDC/NetBanking Offer.
 * @param [JSON] [id - object returned from "JSONObjectWithData" method of NSJSONSerialization]
 * @param [block]
 */
-(void)JSONParserforOfferStatus:(id) JSON withCompletionBlock:(completionBlockForJSONParserForOfferStatus) paramCompletionBlock;

/*!
 * This method parse the JSON for CCDC/NetBanking Offers.
 * @param [JSON] [id - object returned from "JSONObjectWithData" method of NSJSONSerialization]
 * @param [paymentType]         [NSString type]
 * @param [block]
 */
-(void)JSONParserforOfferDetails:(id) JSON withPaymentType:(NSString *) paymentType andCompletionBlock:(completionBlockForJSONParserForOfferDetails) paramCompletionBlock;

/*!
 * This method parse the JSON for CCDC/payment related detail. It parses the JSON and prepares array of model classes for all payment options.
 * @param [JSON] [id - object returned from "JSONObjectWithData" method of NSJSONSerialization]
 * @param [block]
 */
-(void)JSONParserforPaymentRelatedDetailForMobileSDK:(id) JSON
                            andOneTapTokenDictionary:(NSDictionary *) oneTapTokenDictionary
                                          apiVersion:(PayUAPIVersion) apiVersion
                                 withCompletionBlock:(completionBlockForJSONParserforPaymentRelatedDetailForMobileSDK) paramCompletionBlock;
/*!
 * This method parse the JSON for Checkout detail. It parses the JSON and prepares array of model classes for all payment options.
 * @param [JSON] [id - object returned from "JSONObjectWithData" method of NSJSONSerialization]
 * @param [block]
 */
-(void)JSONParserforCheckoutDetails:(id) JSON
                            andOneTapTokenDictionary:(NSDictionary *) oneTapTokenDictionary
                                          apiVersion:(PayUAPIVersion) apiVersion
                                          isForDynamic:(BOOL) isForDynamic
                withCompletionBlock:(completionBlockForJSONParserforPaymentRelatedDetailForMobileSDK) paramCompletionBlock;

/*!
 * This method parse the JSON for deleteStoredCard.
 * @param [JSON] [id - object returned from "JSONObjectWithData" method of NSJSONSerialization]
 * @param [block]
 */
-(void)JSONParserForDeleteStoredCard:(id) JSON
                          apiVersion:(PayUAPIVersion) apiVersion
                 withCompletionBlock:(completionBlockForJSONParserForDeleteStoredCard) paramCompletionBlock;

-(void)JSONParserForGetEMIAmountAccordingToInterest:(id) JSON withCompletionBlock:(completionBlockForJSONParserForGetEMIAmountAccordingToInterest) paramCompletionBlock;

-(void)JSONParserForEligibleBinsForEMI:(id) JSON withCompletionBlock:(completionBlockForJSONParserForEligibleBinsForEMI) paramCompletionBlock;

-(void)JSONParserForGetUserCards:(id) JSON
                      apiVersion:(PayUAPIVersion) apiVersion
              isForTokenizedCard:(BOOL) isForTokenizedCard
             withCompletionBlock:(completionBlockForJSONParserForGetUserCards) paramCompletionBlock;

-(void)JSONParserForVerifyPayment:(id) JSON withCompletionBlock:(completionBlockForJSONParserForVerifyPayment) paramCompletionBlock;

-(void)JSONParserForDeleteOneTapToken:(id) JSON withCompletionBlock:(completionBlockForJSONParserForDeleteOneTapToken) paramCompletionBlock;

-(void)JSONParserForCheckIsDomestic:(id) JSON withCompletionBlock:(completionBlockForJSONParserForCheckIsDomestic) paramCompletionBlock;

-(void)JSONParserForGetBinInfo:(id) JSON of: (BOOL) isAllBin withCompletionBlock:(completionBlockForJSONParserForGetBinInfo) paramCompletionBlock;

-(void)JSONParserForGetTransactionInfo:(id) JSON withCompletionBlock:(completionBlockForJSONParserForGetTransactionInfo) paramCompletionBlock;

-(void)JSONParserForSaveUserCard:(id) JSON withCompletionBlock:(completionBlockForJSONParserForSaveUserCard) paramCompletionBlock;


-(void)JSONParserForMCPLookUP:(id) JSON withCompletionBlock:(completionBlockForJSONParserForMCPLookup) paramCompletionBlock;

-(void)JSONParserForRefundTransaction:(id) JSON withCompletionBlock:(completionBlockForJSONParserForRefund) paramCompletionBlock;


-(void)JSONParserForSodexoCardDetail:(id) JSON withCompletionBlock:(completionBlockForJSONParserForSodexoCardDetail) paramCompletionBlock;

-(void)JSONParserForGetTokenizedPaymentDetails:(id) JSON withCompletionBlock:(completionBlockForJSONParserForGetTokenizedPaymentDetails) paramCompletionBlock;

-(void)JSONParserforAllOfferDetails:(id) JSON withPaymentType:(NSString *) paymentType andCompletionBlock:(completionBlockForJSONParserForAllOfferDetails) paramCompletionBlock;

-(void)JSONParserforValidateOfferDetails:(id) JSON withPaymentType:(NSString *) paymentType andCompletionBlock:(completionBlockForJSONParserForValidateOfferDetails) paramCompletionBlock;

-(void)JSONParserForGetSDKConfiguration:(id) JSON withCompletionBlock:(completionBlockForJSONParserForGETSDKConfiguration) paramCompletionBlock;

-(void)JSONParserforFetchAssets:(id) JSON withPaymentType:(NSString *) paymentType andCompletionBlock:(completionBlockForJSONParserForFetchAsset) paramCompletionBlock;
-(void)JSONParserforAdPostImpression:(id) JSON withPaymentType:(NSString *) paymentType andCompletionBlock:(completionBlockForJSONParserForAddImpression) paramCompletionBlock;
-(void)JSONParserforUpdatePayUId:(id) JSON withPaymentType:(NSString *) paymentType andCompletionBlock:(completionBlockForJSONParserForUpdatePayUId) paramCompletionBlock ;
@end
