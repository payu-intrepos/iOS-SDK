//
//  PayUWebServiceResponse.h
//  PayU_iOS_CoreSDK
//
//  Created by Umang Arya on 08/10/15.
//  Copyright © 2015 PayU. All rights reserved.
//

/*!
 * This class gives web service response callback.
 */
#import <Foundation/Foundation.h>
#import "PayUModelPaymentParams.h"
#import "PayUValidations.h"
#import "PayUUtils.h"
#import "PayUCreatePostParam.h"
#import "PayUJSONParser.h"
#import "PayUModelOfferStatus.h"
#import "PayUConstants.h"
#import "PayUSharedDataManager.h"
#import "PayUModelEMIDetails.h"
#import "PayUModelGetTxnInfo.h"
#import "PayUModelVAS.h"
#import "PayUModelSodexoCardDetail.h"
#import "PayUModelTokenizedPaymentDetails.h"
@import PayUParamsKit;

@interface PayUWebServiceResponse : NSObject

typedef void (^completionBlock)(NSDictionary *hashDict);

typedef void (^completionBlockForHashGeneration)(NSDictionary *parameters ,completionBlock completionBlock);

typedef void (^completionBlockForUpdatedPaymentParam)(NSString *paymentType ,NSString *errorMessage, id extraParam);

typedef void (^completionBlockForGetTokenizedPaymentDetails)(PayUModelTokenizedPaymentDetails *tokenizedPaymentdetails ,NSString *errorMessage, id extraParam);

typedef void (^completionBlockForSodexoCardDetail)(PayUModelSodexoCardDetail *sodexoCardDetail, NSString *errorMessage, id extraParam);

typedef void (^completionBlockForPayUPaymentRelatedDetail)(PayUModelPaymentRelatedDetail *paymentRelatedDetails ,NSString *errorMessage, id extraParam);

typedef void (^completionBlockForOfferStatus)(PayUModelOfferStatus *offerStatus ,NSString *errorMessage, id extraParam);

typedef void (^completionBlockForOfferDetails)(PayUModelOfferDetails *offerDetails ,NSString *errorMessage, id extraParam);

typedef void (^completionBlockForAllOfferDetails)(PayUModelAllOfferDetail *offerDetails ,NSString *errorMessage, id extraParam);

typedef void (^completionBlockForValidateOfferDetails)(PayUModelOfferDetail *offerDetails ,NSString *errorMessage, id extraParam);

typedef void (^completionBlockForDeleteStoredCard)(NSString * deleteStoredCardStatus, NSString * deleteStoredCardMessage ,NSString *errorMessage, id extraParam);

typedef void (^completionBlockForGetSDKConfigurations)(NSArray<PayUSDKConfiguration *> *configuration, NSString *errorMessage, id extraParam);

typedef void (^completionBlockForGetVASStatusForCardBinOrBankCode)(id ResponseMessage ,NSString *errorMessage, id extraParam);

typedef void (^completionBlockForVAS)(PayUModelVAS *vas ,NSString *errorMessage, id extraParam);

typedef void (^completionBlockForGetEMIAmountAccordingToInterest)(NSDictionary *dictEMIDetails ,NSString *errorMessage, id extraParam);

typedef void (^completionBlockForEligibleBinsForEMI)(NSArray<PayUModelEMIDetails *> *arrEMIDetails ,NSString *errorMessage, id extraParam);

typedef void (^completionBlockForGetUserCards)(NSDictionary *dictStoredCard ,NSString *errorMessage, id extraParam);

typedef void (^completionBlockForVerifyPayment)(NSDictionary *dictVerifyPayment ,NSString *errorMessage, id extraParam);
typedef void (^completionBlockForDeleteOneTapToken)(NSString *deleteOneTapTokenMsg ,NSString *errorMessage, id extraParam);
typedef void (^completionBlockForCheckIsDomestic)(PayUModelCheckIsDomestic *checkIsDomestic , NSString *errorMessage, id extraParam);
typedef void (^completionBlockForGetBinInfo)(NSArray<PayUModelCheckIsDomestic*> *allBin , NSString *errorMessage, id extraParam);
typedef void (^completionBlockForRefund)(NSString *message , NSString *errorMessage, id extraParam);
typedef void (^completionBlockForGetTransactionInfo)(NSArray *arrOfGetTxnInfo , NSString *errorMessage, id extraParam);
typedef void (^completionBlockForSaveUserCard)(PayUModelStoredCard *objStoredCard , NSString *errorMessage, id extraParam);
typedef void (^completionBlockForMCPLookup)(PayUModelMultiCurrencyPayment *mcpInfo , NSString *errorMessage, id extraParam);
typedef void (^completionBlockForIFSC)(PayUModelIFSCInfo *isfcInfo , NSString *errorMessage, id extraParam);

//MARK:- initailizer
-(id)init;
//MARK:- This method is to start crash reporting
+(void) start;
/*!
 * This method gives webService response callback for MobileSDK.
 * @param [paymentParam]                                                    [PayUModelPaymentParams type]
 * @param [block]
 * @see   [createRequestWithPaymentParam - PayUCreateRequest]
 * @see   [getWebServiceResponse - PayUUtils]
 * @see   [JSONParserforPaymentRelatedDetailForMobileSDK - PayUJSONParser]
 */
-(void)getPayUPaymentRelatedDetailForMobileSDK:(PayUModelPaymentParams *) paymentParam
                           withCompletionBlock:(completionBlockForPayUPaymentRelatedDetail) paramCompletionBlock;

/*!
 * This method gives websertvice response callback for CheckoutDetail(Server Downtime, additional charges).
 * @param [paymentParam]    [PayUModelPaymentParams type]
 * @param [block]
 * @see   [createRequestWithPaymentParam - PayUCreateRequest]
 * @see   [getWebServiceResponse - PayUUtils]
 * @see   [JSONParserforCheckoutDetail - PayUJSONParser]
 */
-(void)getCheckoutDetail:(PayUModelPaymentParams *) paymentParam
                           withCompletionBlock:(completionBlockForPayUPaymentRelatedDetail) paramCompletionBlock;
/*!
 * This method gives webService response callback for OfferStatus.
 * @param [paymentParam]                                                    [PayUModelPaymentParams type]
 * @param [block]
 * @see   [createRequestWithPaymentParam - PayUCreateRequest]
 * @see   [getWebServiceResponse - PayUUtils]
 * @see   [JSONParserforOfferStatus - PayUJSONParser]
 */
-(void)getOfferStatus:(PayUModelPaymentParams *) paymentParam withCompletionBlock:(completionBlockForOfferStatus) paramCompletionBlock;

/*!
 * This method gives webService response callback for OfferDetails.
 * @param [paymentParam]                                                    [PayUModelPaymentParams type]
 * @param [block]
 * @see   [createRequestWithPaymentParam - PayUCreateRequest]
 * @see   [getWebServiceResponse - PayUUtils]
 * @see   [JSONParserforOfferDetails - PayUJSONParser]
 */
-(void)getOfferDetails:(PayUModelPaymentParams *) paymentParam forPaymentType:(NSString *)paymentType withCompletionBlock:(completionBlockForOfferDetails) paramCompletionBlock;

/*!
 * This method gives webService response callback for deleteStoreCard.
 * @param [paymentParam]                                                    [PayUModelPaymentParams type]
 * @param [block]
 * @see   [createRequestWithPaymentParam - PayUCreateRequest]
 * @see   [getWebServiceResponse - PayUUtils]
 * @see   [JSONParserForDeleteStoredCard - PayUJSONParser]
 */
-(void)deleteStoredCard:(PayUModelPaymentParams *) paymentParam withCompletionBlock:(completionBlockForDeleteStoredCard) paramCompletionBlock DEPRECATED_MSG_ATTRIBUTE("Use \"deleteTokenizedStoredCard:withCompletionBlock\" method instead.");

-(void)callVASForMobileSDKWithPaymentParam:(PayUModelPaymentParams *) paymentParam
                       withCompletionBlock:(completionBlockForVAS) paramCompletionBlock;

/*!
 * This method gives webService response callback for VAS. It is recommended to call from merchant side before payment initiated. It stores the response in singleton class. It contains info about banks and cardBins that are down for payment.
 * @param [paymentParam]                                        [PayUModelPaymentParams type]
 * @param [block]
 * @see   [createRequestWithPaymentParam - PayUCreateRequest]
 * @see   [getWebServiceResponse - PayUUtils]
 */
-(void)callVASForMobileSDKWithPaymentParam:(PayUModelPaymentParams *) paymentParam;

/*!
 * This method gives response callback for VAS status for passed cardBin or bankCode. All information has stored in "PayUSharedDataManager" class.
 * @param [cardBinOrBankCode]                               [NSString type]
 * @param [block]
 * @see   [isNumeric  -PayUValidations]
 * @see   [getIssuerOfCardNumber - PayUValidations]
 */
-(void)getVASStatusForCardBinOrBankCode:(NSString *) cardBinOrBankCode withCompletionBlock:(completionBlockForGetVASStatusForCardBinOrBankCode) paramCompletionBlock;
/*!
 * This method gives webService response callback for EMIAmountAccordingToInterest API.
 * @param [paymentParam]                                                    [PayUModelPaymentParams type]
 * @param [block]
 * @see   [createRequestWithPaymentParam - PayUCreateRequest]
 * @see   [getWebServiceResponse - PayUUtils]
 * @see   [JSONParserForGetEMIAmountAccordingToInterest - PayUJSONParser]
 */
-(void)getEMIAmountAccordingToInterest:(PayUModelPaymentParams *) paymentParam withCompletionBlock:(completionBlockForGetEMIAmountAccordingToInterest) paramCompletionBlock;

/// This will return minimum amount and supported bin by each bank for EMI
/// @param paymentParam  paymentParams object
/// @param paramCompletionBlock  completion block
-(void)eligibleBinsForEMI:(PayUModelPaymentParams *) paymentParam withCompletionBlock:(completionBlockForEligibleBinsForEMI) paramCompletionBlock;

/*!
 * This method gives webService response callback for getUserCards API.
 * @param [paymentParam]                                                    [PayUModelPaymentParams type]
 * @param [block]
 * @see   [createRequestWithPaymentParam - PayUCreateRequest]
 * @see   [getWebServiceResponse - PayUUtils]
 * @see   [JSONParserForGetUserCards - PayUJSONParser]
 */
-(void)getUserCards:(PayUModelPaymentParams *) paymentParam withCompletionBlock:(completionBlockForGetUserCards) paramCompletionBlock DEPRECATED_MSG_ATTRIBUTE("Use \"getTokenizedStoredCards:withCompletionBlock\" method instead.");

/*!
 * This method gives webService response callback for verifyPayment API.
 * @param [paymentParam]                                                    [PayUModelPaymentParams type]
 * @param [block]
 * @see   [createRequestWithPaymentParam - PayUCreateRequest]
 * @see   [getWebServiceResponse - PayUUtils]
 * @see   [JSONParserForVerifyPayment - PayUJSONParser]
 */
-(void)verifyPayment:(PayUModelPaymentParams *) paymentParam withCompletionBlock:(completionBlockForVerifyPayment) paramCompletionBlock;

/*!
 * This method gives webService response callback for EditUserCard API.
 * @param [paymentParam]                                                    [PayUModelPaymentParams type]
 * @param [block]
 * @see   [createRequestWithPaymentParam - PayUCreateRequest]
 * @see   [getWebServiceResponse - PayUUtils]
 * @see   [JSONParserForEditUserCard - PayUJSONParser]
 */
-(void)editUserCard:(PayUModelPaymentParams *) paymentParam withCompletionBlock:(completionBlockForSaveUserCard) paramCompletionBlock DEPRECATED_MSG_ATTRIBUTE("The \"editUserCard:withCompletionBlock\" method is not supported because of RBI guidelines, in order to save or edit the card, please save card by authenticating it doing an actual payment.");

/*!
 * This method gives webService response callback for DeleteOneTapToken API.
 * @param [paymentParam]                                                    [PayUModelPaymentParams type]
 * @param [block]
 * @see   [createRequestWithPaymentParam - PayUCreateRequest]
 * @see   [getWebServiceResponse - PayUUtils]
 * @see   [JSONParserForEditUserCard - PayUJSONParser]
 */
-(void)deleteOneTapToken:(PayUModelPaymentParams *) paymentParam withCompletionBlock:(completionBlockForDeleteOneTapToken) paramCompletionBlock;

-(void)checkIsDomestic:(PayUModelPaymentParams *) paymentParam withCompletionBlock:(completionBlockForCheckIsDomestic) paramCompletionBlock;
/*!
 * This method gives webService response callback for Card Bin Info.
 * @param [paymentParam]    [PayUModelPaymentParams type]
 * @param [block]
 * @see   [createRequestWithPaymentParam - PayUCreateRequest]
 * @see   [getWebServiceResponse - PayUUtils]
 * @see   [JSONParserForGetBinInfo - PayUJSONParser]
 */
-(void)getBinInfo:(PayUModelPaymentParams *) paymentParam withCompletionBlock:(completionBlockForGetBinInfo) paramCompletionBlock;

-(void)getTransactionInfo:(PayUModelPaymentParams *) paymentParam withCompletionBlock:(completionBlockForGetTransactionInfo) paramCompletionBlock;

-(void)saveUserCard:(PayUModelPaymentParams *) paymentParam withCompletionBlock:(completionBlockForSaveUserCard) paramCompletionBlock DEPRECATED_MSG_ATTRIBUTE("The \"saveUserCard:withCompletionBlock\" method is not supported because of RBI guidelines, in order to save or edit the card, please save card by authenticating it doing an actual payment.");

-(void)mcpLookup:(PayUModelPaymentParams *) paymentParam withCompletionBlock:(completionBlockForMCPLookup) paramCompletionBlock;
/*!
 * This method gives webService response callback for Refund
 * @param [paymentParam]    [PayUModelPaymentParams type]
 * @param [block]
 * @see   [createRequestWithPaymentParam - PayUCreateRequest]
 * @see   [getWebServiceResponse - PayUUtils]
 * @see   [JSONParserForGetBinInfo - PayUJSONParser]
 */
-(void)refundTransaction:(PayUModelPaymentParams *) paymentParam withCompletionBlock:(completionBlockForRefund) paramCompletionBlock;

-(void)getSDKConfiguration:(PayUModelPaymentParams *) paymentParam withCompletionBlock:(completionBlockForGetSDKConfigurations) paramCompletionBlock;

-(void)fetchIFSCDetails:(PayUModelPaymentParams *) paymentParam withCompletionBlock:(completionBlockForIFSC) paramCompletionBlock;

-(void)fetchSodexoCardDetails:(PayUModelPaymentParams *) paymentParam
      withCompletionBlock:(completionBlockForSodexoCardDetail) paramCompletionBlock;

-(void)deleteTokenizedStoredCard:(PayUModelPaymentParams *) paymentParam withCompletionBlock:(completionBlockForDeleteStoredCard) paramCompletionBlock;

-(void)getTokenizedStoredCards:(PayUModelPaymentParams *) paymentParam withCompletionBlock:(completionBlockForGetUserCards) paramCompletionBlock;

-(void)getTokenizedPaymentDetails:(PayUModelPaymentParams *) paymentParam withCompletionBlock:(completionBlockForGetTokenizedPaymentDetails) paramCompletionBlock;

/*!
 * This method gives webService response callback for AllOfferDetails.
 * @param paymentParam PayUModelPaymentParams
 * @param hashCompletionBlock CompletionBlockForHashGeneration Type
 * @param responseCompletionBlock CompletionBlockForAllOfferDetails Type
 * @see   [createRequestWithPaymentParam - PayUCreateRequest]
 * @see   [getWebServiceResponse - PayUUtils]
 * @see   [JSONParserforAllOfferDetails - PayUJSONParser]
 */
-(void)getAllOfferDetails:(PayUModelPaymentParams *) paymentParam completionBlockForHashGeneration:(completionBlockForHashGeneration) hashCompletionBlock completionBlockForAPIResponse:(completionBlockForAllOfferDetails) responseCompletionBlock;

/*!
 * This method gives webService response callback for ValidateOfferDetails.
 * @param paymentParam PayUModelPaymentParams
 * @param hashCompletionBlock completionBlockForHashGeneration Type
 * @param responseCompletionBlock completionBlockForValidateOfferDetails Type
 * @see   [createRequestWithPaymentParam - PayUCreateRequest]
 * @see   [getWebServiceResponse - PayUUtils]
 * @see   [JSONParserforValidateOfferDetails - PayUJSONParser]
 */
-(void)validateOfferDetails:(PayUModelPaymentParams *) paymentParam completionBlockForHashGeneration:(completionBlockForHashGeneration) hashCompletionBlock completionBlockForAPIResponse:(completionBlockForValidateOfferDetails) responseCompletionBlock;

@end
