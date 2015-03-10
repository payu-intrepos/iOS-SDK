//
//  PayUConnectionHandlerController.m
//  PayU_iOS_SDK
//
//  Created by Suryakant Sharma on 14/02/15.
//  Copyright (c) 2015 PayU, India. All rights reserved.
//

#import "PayUConnectionHandlerController.h"
#import "PayUConstant.h"
#import "SharedDataManager.h"
#import "Utils.h"
#import "Reachability.h"
#import "ReachabilityManager.h"

#define PARAM_VAR1_DEFAULT    @"default"
#define PG_TYPE               @"NB"
#define BANK_CODE             @"bankcode"
#define WALLET_BANK_CODE      @"payuw"


@interface PayUConnectionHandlerController() <NSURLConnectionDelegate>

@property (nonatomic,strong) NSMutableDictionary *parameterDict;
@property (nonatomic,strong) NSOperationQueue *networkQueue;

@property (nonatomic,strong) NSURLConnection *connectionGettingStoredCard;
@property (nonatomic,strong) NSURLConnection *connectionForDeletingCard;
@property (nonatomic,strong) NSURLConnection *connectionForNetBanking;


@property (nonatomic,strong) NSMutableData *connectionSpecificDataObject;
@property (nonatomic,strong) NSMutableData *receivedData;
@property (nonatomic,strong) NSMutableDictionary *allStoredCards;

@property (nonatomic,strong) NSString *var1;
@property (nonatomic,strong) NSString *command;

@end

@implementation PayUConnectionHandlerController


void(^serverResponseForUrlCallback)(BOOL success, NSDictionary *response, NSError *error);
void(^serverResponseForNetworkUrlForStoredCardCallback)(NSURLResponse *response, NSData *data, NSError *connectionError);
void(^serverResponseForNetworkUrlForNetBankingCallback)(NSURLResponse *response, NSData *data, NSError *connectionError);
void(^serverResponseForNetworkUrlForDeleteStoredCardCallback)(NSURLResponse *response, NSData *data, NSError *connectionError);



- (instancetype) init:(NSDictionary *) requiredParam;
{
    if (self = [super init])
    {
        SharedDataManager *dataManager = [SharedDataManager sharedDataManager];
        NSLog(@"Shared Data = %@",dataManager.allInfoDict);
        //if(0 != dataManager.allInfoDict.allKeys.count){
             if(nil != requiredParam)
            _parameterDict = [requiredParam mutableCopy];
            dataManager.allInfoDict = [self createDictionaryWithAllParam];
       // }
        NSLog(@"Shared Data = %@",dataManager.allInfoDict);

        // Reachability
        [ReachabilityManager sharedManager];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityDidChange:) name:payUReachabilityChangedNotification object:nil];
    }
    return self;
}
- (void)dealloc {
    ALog(@"");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)listOfStoredCardWithCallback:(urlRequestCompletionBlock) completionBlock {
    
    serverResponseForNetworkUrlForStoredCardCallback = completionBlock;
    if (_connectionSpecificDataObject) {
        _connectionSpecificDataObject = nil;
    }
    _connectionSpecificDataObject = [[NSMutableData alloc] init];
    
    NSURL *restURL = [NSURL URLWithString:PAYU_PAYMENT_ALL_AVAILABLE_PAYMENT_OPTION];
    
    // create the request
    NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:restURL
                                                            cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                        timeoutInterval:60.0];
    // Specify that it will be a POST request
    theRequest.HTTPMethod = POST;
    
    
    
    NSMutableDictionary *paramDict = [[NSMutableDictionary alloc] initWithDictionary:[[SharedDataManager sharedDataManager] allInfoDict]];
    if(0 == paramDict.allKeys.count){
        paramDict = _parameterDict;
    }
    
    [paramDict setValue:[NSString stringWithFormat:@"%@",[paramDict valueForKey:PARAM_USER_CREDENTIALS]] forKey:PARAM_VAR1];
    [paramDict setValue:PARAM_GET_STORED_CARD forKey:PARAM_COMMAND];
    [paramDict setValue:[paramDict valueForKey:PARAM_USER_CREDENTIALS] forKey:PARAM_VAR1];
    
    NSMutableString *postData = [[NSMutableString alloc] init];
    for(NSString *aKey in [paramDict allKeys]){
        if(![aKey isEqualToString:PARAM_SALT]){
            [postData appendFormat:@"%@=%@",aKey,[paramDict valueForKey:aKey]];
            [postData appendString:@"&"];
        }
    }
    
    [postData appendString:@"&"];
    [postData appendFormat:@"%@=%@",PARAM_DEVICE_TYPE,IOS_SDK];
    [postData appendString:@"&"];
    
    NSMutableString *hashValue = [[NSMutableString alloc] init];
    if([paramDict valueForKey:PARAM_KEY]){
        [hashValue appendFormat:@"%@",[paramDict valueForKey:PARAM_KEY]];
        [hashValue appendString:@"|"];
    }
    if([paramDict valueForKey:PARAM_COMMAND]){
        [hashValue appendString:[paramDict valueForKey:PARAM_COMMAND]];
        [hashValue appendString:@"|"];
    }
    if([paramDict valueForKey:PARAM_VAR1]){
        [hashValue appendString:[paramDict valueForKey:PARAM_VAR1]];
        [hashValue appendString:@"|"];
    }
    if([paramDict valueForKey:PARAM_SALT]){
        [hashValue appendString:[paramDict valueForKey:PARAM_SALT]];
        //[hashValue appendString:@"|"];
    }
    
    NSLog(@"Hash String = %@ hashvalue = %@",hashValue,[Utils createCheckSumString:hashValue]);
    [postData appendFormat:@"%@=%@",PARAM_HASH,[Utils createCheckSumString:hashValue]];
    
    //sha512(key|command|var1|salt)
    NSLog(@"STORED CARD POST DATA = %@",postData);
    
    //set request content type we MUST set this value.
    [theRequest setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    //set post data of request
    [theRequest setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
    
    //Create a queue
    _networkQueue = [[NSOperationQueue alloc] init];

    [NSURLConnection sendAsynchronousRequest:theRequest queue:_networkQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        serverResponseForNetworkUrlForStoredCardCallback(response,data,connectionError);
    }];
}

- (void)listOfInternetBankingOptionCallback:(urlRequestCompletionBlock) completionBlock {
    
    serverResponseForNetworkUrlForNetBankingCallback = completionBlock;
    if (_connectionSpecificDataObject) {
        _connectionSpecificDataObject = nil;
    }
    _connectionSpecificDataObject = [[NSMutableData alloc] init];
    
    NSException *exeption = nil;
    
    NSURL *restURL = [NSURL URLWithString:PAYU_PAYMENT_ALL_AVAILABLE_PAYMENT_OPTION];
    
    // create the request
    NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:restURL
                                                            cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                        timeoutInterval:60.0];
    // Specify that it will be a POST request
    theRequest.HTTPMethod = @"POST";
    NSString *command = nil;
    
    if([[NSBundle mainBundle] objectForInfoDictionaryKey:PARAM_COMMAND]){
        command = [[NSBundle mainBundle] objectForInfoDictionaryKey:PARAM_COMMAND];
    }
    else{
        exeption = [[NSException alloc] initWithName:@"Required Param missing" reason:@"KEY is not provided, this is one of required parameters." userInfo:nil];
        [exeption raise];
    }
    
    NSMutableDictionary *paramDict = [[NSMutableDictionary alloc] initWithDictionary:[[SharedDataManager sharedDataManager] allInfoDict]];
    if(0 == paramDict.allKeys.count){
        paramDict = _parameterDict;
    }
    
    NSString *postData = [NSString stringWithFormat:@"key=%@&var1=%@&command=%@&hash=%@",[paramDict objectForKey:PARAM_KEY],[paramDict objectForKey:PARAM_VAR1],command,[Utils createCheckSumString:[NSString stringWithFormat:@"%@|%@|%@|%@",[paramDict objectForKey:PARAM_KEY],command,[paramDict objectForKey:PARAM_VAR1],[paramDict objectForKey:PARAM_SALT]]]];
    
    //set request content type we MUST set this value.
    [theRequest setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    //set post data of request
    [theRequest setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
    
    _networkQueue = [[NSOperationQueue alloc] init];
    // We just have 1 thread for this work, that way canceling is easy
    //_networkQueue.maxConcurrentOperationCount = 1;
    [NSURLConnection sendAsynchronousRequest:theRequest queue:_networkQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSLog(@"responseDict=%@",_allStoredCards);
        serverResponseForNetworkUrlForNetBankingCallback(response,data,connectionError);
    }];


}

- (void) deleteStoredCardWithCardToken:(NSNumber*)cardToken withCompletionBlock:(urlRequestCompletionBlock)completionBlock {
    
    serverResponseForNetworkUrlForDeleteStoredCardCallback = completionBlock;
    
    NSURL *restURL = [NSURL URLWithString:PAYU_PAYMENT_ALL_AVAILABLE_PAYMENT_OPTION];
    
    // create the request
    NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:restURL
                                                            cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                        timeoutInterval:60.0];
    // Specify that it will be a POST request
    theRequest.HTTPMethod = POST;
    
    NSMutableDictionary *paramDict = [[NSMutableDictionary alloc] initWithDictionary:[[SharedDataManager sharedDataManager] allInfoDict]];
    if(0 == paramDict.allKeys.count){
        paramDict = _parameterDict;
    }
    
    [paramDict setValue:[NSString stringWithFormat:@"%@",[paramDict valueForKey:PARAM_USER_CREDENTIALS]] forKey:PARAM_VAR1];
    [paramDict setValue:PARAM_GET_STORED_CARD forKey:PARAM_COMMAND];
    
    
    NSMutableString *postData = [[NSMutableString alloc] init];
    [postData appendFormat:@"%@=%@",PARAM_KEY,[paramDict valueForKey:PARAM_KEY]];
    [postData appendString:@"&"];
    
    [postData appendFormat:@"%@=%@",PARAM_DEVICE_TYPE,IOS_SDK];
    [postData appendString:@"&"];
    
    [postData appendFormat:@"%@=%@",PARAM_COMMAND,PARAM_DELETE_STORED_CARD];
    [postData appendString:@"&"];
    
    [postData appendFormat:@"%@=%@",PARAM_VAR1,[paramDict valueForKey:PARAM_VAR1]];
    [postData appendString:@"&"];
    
    [postData appendFormat:@"%@=%@",PARAM_VAR2,cardToken];
    [postData appendString:@"&"];
    
    NSMutableString *hashValue = [[NSMutableString alloc] init];
    
    if([paramDict valueForKey:PARAM_KEY]){
        [hashValue appendString:[paramDict valueForKey:PARAM_KEY]];
        [hashValue appendString:@"|"];
    }
    [hashValue appendFormat:@"%@",PARAM_DELETE_STORED_CARD];
    [hashValue appendString:@"|"];
    
    if([paramDict valueForKey:PARAM_VAR1]){
        [hashValue appendString:[paramDict valueForKey:PARAM_VAR1]];
        [hashValue appendString:@"|"];
    }
    if([paramDict valueForKey:PARAM_SALT]){
        [hashValue appendString:[paramDict valueForKey:PARAM_SALT]];
    }
    
    NSLog(@"Hash String = %@ hashvalue = %@",hashValue,[Utils createCheckSumString:hashValue]);
    [postData appendFormat:@"%@=%@",PARAM_HASH,[Utils createCheckSumString:hashValue]];
    //sha512(key|command|var1|salt)
    NSLog(@"DELETE CARD POST DATA = %@",postData);
    //set request content type we MUST set this value.
    [theRequest setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    //set post data of request
    [theRequest setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
    
    _networkQueue = [[NSOperationQueue alloc] init];
    // We just have 1 thread for this work, that way canceling is easy
    //_networkQueue.maxConcurrentOperationCount = 1;
    [NSURLConnection sendAsynchronousRequest:theRequest queue:_networkQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        serverResponseForNetworkUrlForDeleteStoredCardCallback(response,data,connectionError);
    }];
}


- (NSURLRequest *) URLRequestForPaymentWithStoredCard:(NSDictionary *)selectedStoredCardDict{
    
    if (_connectionSpecificDataObject) {
        _connectionSpecificDataObject = nil;
    }
    _connectionSpecificDataObject = [[NSMutableData alloc] init];
    
    NSURL *restURL = [NSURL URLWithString:PAYU_PAYMENT_BASE_URL];
    
    // create the request
    NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:restURL
                                                            cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                        timeoutInterval:60.0];
    // Specify that it will be a POST request
    theRequest.HTTPMethod = @"POST";
    
    NSMutableDictionary *paramDict = [[NSMutableDictionary alloc] initWithDictionary:[[SharedDataManager sharedDataManager] allInfoDict]];
    //[paramDict setValue:@"default" forKey:PARAM_VAR1];
    [paramDict setValue:@"get_merchant_ibibo_codes" forKey:PARAM_COMMAND];
    
    NSMutableString *postData = [[NSMutableString alloc] init];
    for(NSString *aKey in [paramDict allKeys]){
        if(!([aKey isEqualToString:PARAM_SALT]) && !([aKey isEqualToString:PARAM_FIRST_NAME])){
            [postData appendFormat:@"%@=%@",aKey,[paramDict valueForKey:aKey]];
            [postData appendString:@"&"];
        }
    }
    
    if([selectedStoredCardDict objectForKey:@"card_type"]){
        [postData appendFormat:@"%@=%@",PARAM_PG,[selectedStoredCardDict objectForKey:@"card_type"]];
        [postData appendString:@"&"];
    }
    
    if([selectedStoredCardDict objectForKey:@"card_token"]){
        [postData appendFormat:@"%@=%@",PARAM_CARD_TOKEN,[selectedStoredCardDict objectForKey:@"card_token"]];
        [postData appendString:@"&"];
    }
    //user_credentials name_on_card
    if([selectedStoredCardDict objectForKey:@"name_on_card"]){
        [postData appendFormat:@"%@=%@",PARAM_FIRST_NAME,[selectedStoredCardDict objectForKey:@"name_on_card"]];
        [postData appendString:@"&"];
    }
    if([selectedStoredCardDict objectForKey:PARAM_CARD_CVV]){
        [postData appendFormat:@"%@=%@",PARAM_CARD_CVV,[selectedStoredCardDict objectForKey:PARAM_CARD_CVV]];
        [postData appendString:@"&"];
    }
    
    if([selectedStoredCardDict objectForKey:@"card_mode"]){
        [postData appendFormat:@"%@=%@",PARAM_BANK_CODE,[selectedStoredCardDict objectForKey:@"card_mode"]];
    }
    [postData appendString:@"&"];
    [postData appendFormat:@"%@=%@",PARAM_DEVICE_TYPE,IOS_SDK];
    [postData appendString:@"&"];
    
    
    
    //checksum calculation.
    
    NSMutableString *hashValue = [[NSMutableString alloc] init];
    if([paramDict valueForKey:PARAM_KEY]){
        [hashValue appendFormat:@"%@",[paramDict valueForKey:PARAM_KEY]];
        [hashValue appendString:@"|"];
    }
    if([paramDict valueForKey:PARAM_TXID]){
        [hashValue appendFormat:@"%@",[paramDict valueForKey:PARAM_TXID]];
        [hashValue appendString:@"|"];
    }
    if([paramDict valueForKey:PARAM_TOTAL_AMOUNT]){
        [hashValue appendFormat:@"%@",[paramDict valueForKey:PARAM_TOTAL_AMOUNT]];
        [hashValue appendString:@"|"];
    }
    if([paramDict valueForKey:PARAM_PRODUCT_INFO]){
        [hashValue appendFormat:@"%@",[paramDict valueForKey:PARAM_PRODUCT_INFO]];
        [hashValue appendString:@"|"];
    }
    if([paramDict valueForKey:PARAM_FIRST_NAME]){
        // name, we will provide the one that is stored along with card info.
        [hashValue appendFormat:@"%@",[selectedStoredCardDict objectForKey:@"name_on_card"]];
        [hashValue appendString:@"|"];
    }
    if([paramDict valueForKey:PARAM_EMAIL]){
        [hashValue appendFormat:@"%@",[paramDict valueForKey:PARAM_EMAIL]];
        [hashValue appendString:@"|"];
    }
    if([paramDict valueForKey:PARAM_UDF_1]){
        [hashValue appendFormat:@"%@",[paramDict valueForKey:PARAM_UDF_1]];
        [hashValue appendString:@"|"];
    }
    else{
        [hashValue appendString:@"|"];
    }
    if([paramDict valueForKey:PARAM_UDF_2]){
        [hashValue appendFormat:@"%@",[paramDict valueForKey:PARAM_UDF_2]];
        [hashValue appendString:@"|"];
    }
    else{
        [hashValue appendString:@"|"];
    }
    if([paramDict valueForKey:PARAM_UDF_3]){
        [hashValue appendFormat:@"%@",[paramDict valueForKey:PARAM_UDF_3]];
        [hashValue appendString:@"|"];
    }
    else{
        [hashValue appendString:@"|"];
    }
    if([paramDict valueForKey:PARAM_UDF_4]){
        [hashValue appendFormat:@"%@",[paramDict valueForKey:PARAM_UDF_4]];
        [hashValue appendString:@"|"];
    }
    else{
        [hashValue appendString:@"|"];
    }
    if([paramDict valueForKey:PARAM_UDF_5]){
        [hashValue appendFormat:@"%@",[paramDict valueForKey:PARAM_UDF_5]];
        [hashValue appendString:@"|"];
    }
    else{
        [hashValue appendString:@"|"];
    }
    [hashValue appendString:@"|||||"];
    if([paramDict valueForKey:PARAM_SALT]){
        [hashValue appendString:[paramDict valueForKey:PARAM_SALT]];
    }
    
    NSLog(@"Hash String = %@ hashvalue = %@",hashValue,[Utils createCheckSumString:hashValue]);
    [postData appendFormat:@"%@=%@",PARAM_HASH,[Utils createCheckSumString:hashValue]];
    //sha512(key|txnid|amount|productinfo|firstname|email|udf1|udf2|udf3|udf4|udf5||||||SALT)
    NSLog(@"Pay with Stored card POST DATA = %@",postData);
    //set request content type we MUST set this value.
    [theRequest setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    //set post data of request
    [theRequest setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
    
    return theRequest;
    
}


- (NSMutableURLRequest *) URLRequestForInternetBankingWithBankCode:(NSString *)bankCode{
    
    NSLog(@"Bank code = %@",bankCode);
    if (_connectionSpecificDataObject) {
        _connectionSpecificDataObject = nil;
    }
    _connectionSpecificDataObject = [[NSMutableData alloc] init];
    
    NSURL *restURL = [NSURL URLWithString:PAYU_PAYMENT_BASE_URL];
    
    // create the request
    NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:restURL
                                                            cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                        timeoutInterval:60.0];
    // Specify that it will be a POST request
    theRequest.HTTPMethod = @"POST";
    
    NSDictionary *paramDict = [[SharedDataManager sharedDataManager] allInfoDict];
    NSMutableString *postData = [[NSMutableString alloc] init];

    
    NSLog(@"ParamDict = %@",paramDict);
    
    if([paramDict objectForKey:PARAM_TOTAL_AMOUNT]){
        [postData appendFormat:@"%@=%@",PARAM_TOTAL_AMOUNT,[paramDict objectForKey:PARAM_TOTAL_AMOUNT]];
        [postData appendString:@"&"];
        
    }
    [postData appendFormat:@"%@=%@",PARAM_PG,PG_TYPE];
    [postData appendString:@"&"];
    
    if([paramDict objectForKey:PARAM_TXID]){
        [postData appendFormat:@"%@=%@",PARAM_TXID,[paramDict objectForKey:PARAM_TXID]];
        [postData appendString:@"&"];
    }
    
    if(bankCode){
        [postData appendFormat:@"%@=%@",PARAM_BANK_CODE,bankCode];
        [postData appendString:@"&"];
    }
    [postData appendFormat:@"%@=%@",PARAM_DEVICE_TYPE,IOS_SDK];
    [postData appendString:@"&"];
    
    if([paramDict objectForKey:PARAM_SURL]){
        [postData appendFormat:@"%@=%@",PARAM_SURL,[paramDict objectForKey:PARAM_SURL]];
        [postData appendString:@"&"];
    }
    if([paramDict objectForKey:PARAM_FURL]){
        [postData appendFormat:@"%@=%@",PARAM_FURL,[paramDict objectForKey:PARAM_FURL]];
        [postData appendString:@"&"];
    }
    if([paramDict objectForKey:PARAM_KEY]){
        [postData appendFormat:@"%@=%@",PARAM_KEY,[paramDict objectForKey:PARAM_KEY]];
        [postData appendString:@"&"];
    }
    if([paramDict objectForKey:PARAM_PRODUCT_INFO]){
        [postData appendFormat:@"%@=%@",PARAM_PRODUCT_INFO,[paramDict objectForKey:PARAM_PRODUCT_INFO]];
        [postData appendString:@"&"];
    }
    
    //checksum calculation.
    
    NSMutableString *hashValue = [[NSMutableString alloc] init];
    if([paramDict valueForKey:PARAM_KEY]){
        [hashValue appendFormat:@"%@",[paramDict valueForKey:PARAM_KEY]];
        [hashValue appendString:@"|"];
    }
    if([paramDict valueForKey:PARAM_TXID]){
        [hashValue appendFormat:@"%@",[paramDict valueForKey:PARAM_TXID]];
        [hashValue appendString:@"|"];
    }
    if([paramDict valueForKey:PARAM_TOTAL_AMOUNT]){
        [hashValue appendFormat:@"%@",[paramDict valueForKey:PARAM_TOTAL_AMOUNT]];
        [hashValue appendString:@"|"];
    }
    if([paramDict valueForKey:PARAM_PRODUCT_INFO]){
        [hashValue appendFormat:@"%@",[paramDict valueForKey:PARAM_PRODUCT_INFO]];
        [hashValue appendString:@"|"];
    }
    if([paramDict valueForKey:PARAM_FIRST_NAME]){
        //[hashValue appendFormat:@"%@",[paramDict valueForKey:PARAM_FIRST_NAME]];
        [hashValue appendString:@"|"];
    }
    if([paramDict valueForKey:PARAM_EMAIL]){
        //[hashValue appendFormat:@"%@",[paramDict valueForKey:PARAM_EMAIL]];
        [hashValue appendString:@"|"];
    }
    if([paramDict valueForKey:PARAM_UDF_1]){
        [hashValue appendFormat:@"%@",[paramDict valueForKey:PARAM_UDF_1]];
        [hashValue appendString:@"|"];
    }
    else{
        [hashValue appendString:@"|"];
    }
    if([paramDict valueForKey:PARAM_UDF_2]){
        [hashValue appendFormat:@"%@",[paramDict valueForKey:PARAM_UDF_2]];
        [hashValue appendString:@"|"];
    }
    else{
        [hashValue appendString:@"|"];
    }
    if([paramDict valueForKey:PARAM_UDF_3]){
        [hashValue appendFormat:@"%@",[paramDict valueForKey:PARAM_UDF_3]];
        [hashValue appendString:@"|"];
    }
    else{
        [hashValue appendString:@"|"];
    }
    if([paramDict valueForKey:PARAM_UDF_4]){
        [hashValue appendFormat:@"%@",[paramDict valueForKey:PARAM_UDF_4]];
        [hashValue appendString:@"|"];
    }
    else{
        [hashValue appendString:@"|"];
    }
    if([paramDict valueForKey:PARAM_UDF_5]){
        [hashValue appendFormat:@"%@",[paramDict valueForKey:PARAM_UDF_5]];
        [hashValue appendString:@"|"];
    }
    else{
        [hashValue appendString:@"|"];
    }
    [hashValue appendString:@"|||||"];
    if([paramDict valueForKey:PARAM_SALT]){
        [hashValue appendString:[paramDict valueForKey:PARAM_SALT]];
    }
    
    NSLog(@"Hash String = %@ hashvalue = %@",hashValue,[Utils createCheckSumString:hashValue]);
    [postData appendFormat:@"%@=%@",PARAM_HASH,[Utils createCheckSumString:hashValue]];
    //sha512(key|txnid|amount|productinfo|firstname|email|udf1|udf2|udf3|udf4|udf5||||||SALT)
    NSLog(@"POST DATA = %@",postData);
    //set request content type we MUST set this value.
    [theRequest setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    //set post data of request
    [theRequest setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
    
    return theRequest;
}

-(NSDictionary *) createDictionaryWithAllParam{
    
    NSMutableDictionary *allParamDict = [[NSMutableDictionary alloc] init];
    NSException *exeption = nil;
    if([[NSBundle mainBundle] objectForInfoDictionaryKey:PARAM_VAR1]){
        _var1  = PARAM_VAR1_DEFAULT;
    }
    
    if([[NSBundle mainBundle] objectForInfoDictionaryKey:PARAM_SALT]){
        [allParamDict setValue:[[NSBundle mainBundle] objectForInfoDictionaryKey:PARAM_SALT] forKey:PARAM_SALT];
    }
    else{
        exeption = [[NSException alloc] initWithName:@"Required Param missing" reason:@"SALT is not provided, this is one of required parameters." userInfo:nil];
        [exeption raise];
    }
    
    if([[NSBundle mainBundle] objectForInfoDictionaryKey:PARAM_KEY]){
        [allParamDict setValue:[[NSBundle mainBundle] objectForInfoDictionaryKey:PARAM_KEY] forKey:PARAM_KEY];
    }
    else{
        exeption = [[NSException alloc] initWithName:@"Required Param missing" reason:@"KEY is not provided, this is one of required parameters." userInfo:nil];
        [exeption raise];
    }
    if([[NSBundle mainBundle] objectForInfoDictionaryKey:PARAM_COMMAND]){
        _command = [[NSBundle mainBundle] objectForInfoDictionaryKey:PARAM_COMMAND];
        //[allParamDict setValue:_command forKey:PARAM_COMMAND];
    }
    else{
        exeption = [[NSException alloc] initWithName:@"Required Param missing" reason:@"KEY is not provided, this is one of required parameters." userInfo:nil];
        [exeption raise];
    }
    
    if(0 != _parameterDict.allKeys.count){
        [allParamDict addEntriesFromDictionary:_parameterDict];
        [allParamDict addEntriesFromDictionary:[[SharedDataManager sharedDataManager] allInfoDict]];

    }
    else{
        [allParamDict addEntriesFromDictionary:[[SharedDataManager sharedDataManager] allInfoDict]];
    }
    
    
    NSLog(@"ALL PARAM DICT =%@",allParamDict);
    return allParamDict;
}

-(NSURLRequest *) URLRequestForCardPayment:(NSDictionary *) detailsDict{
    
    if (_connectionSpecificDataObject) {
        _connectionSpecificDataObject = nil;
    }
    _connectionSpecificDataObject = [[NSMutableData alloc] init];
    
    NSURL *restURL = [NSURL URLWithString:PAYU_PAYMENT_BASE_URL];
    
    // create the request
    NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:restURL
                                                            cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                        timeoutInterval:60.0];
    // Specify that it will be a POST request
    theRequest.HTTPMethod = @"POST";
    
    NSDictionary *paramDict = [[SharedDataManager sharedDataManager] allInfoDict];
    
    NSMutableString *postData = [[NSMutableString alloc] init];
    for(NSString *aKey in [paramDict allKeys]){
        if(![aKey isEqualToString:PARAM_SALT]){
            [postData appendFormat:@"%@=%@",aKey,[paramDict valueForKey:aKey]];
            [postData appendString:@"&"];
        }
    }
    if([detailsDict valueForKey:@"store_card"] && [paramDict valueForKey:PARAM_USER_CREDENTIALS]){
        [postData appendFormat:@"%@=%@",PARAM_STORE_YOUR_CARD,[NSNumber numberWithInt:1]];
        [postData appendString:@"&"];
        if([detailsDict valueForKey:@"card_name"]){
            [postData appendFormat:@"%@=%@",PARAM_STORE_CARD_NAME,[detailsDict valueForKey:@"card_name"]];
            [postData appendString:@"&"];
        }
    }

    if([detailsDict valueForKey:PARAM_PG]){
        [postData appendFormat:@"%@=%@",PARAM_PG,[detailsDict objectForKey:PARAM_PG]];
        [postData appendString:@"&"];
    }
    if([detailsDict valueForKey:PARAM_CARD_NUMBER]){
        [postData appendFormat:@"%@=%@",PARAM_CARD_NUMBER,[detailsDict objectForKey:PARAM_CARD_NUMBER]];
        [postData appendString:@"&"];
    }
    if([detailsDict valueForKey:PARAM_CARD_NAME]){
        [postData appendFormat:@"%@=%@",PARAM_CARD_NAME,[detailsDict objectForKey:PARAM_CARD_NAME]];
        [postData appendString:@"&"];
    }

    if([detailsDict valueForKey:PARAM_CARD_EXPIRY_MONTH]){
        [postData appendFormat:@"%@=%ld",PARAM_CARD_EXPIRY_MONTH,(long)[[detailsDict objectForKey:PARAM_CARD_EXPIRY_MONTH] integerValue]];
        [postData appendString:@"&"];
    }
    if([detailsDict valueForKey:PARAM_CARD_EXPIRY_YEAR]){
        [postData appendFormat:@"%@=%ld",PARAM_CARD_EXPIRY_YEAR,(long)[[detailsDict objectForKey:PARAM_CARD_EXPIRY_YEAR] integerValue]];
        [postData appendString:@"&"];
    }
    
    if( [[detailsDict valueForKey:PARAM_BANK_CODE] caseInsensitiveCompare:@"VISA"] == NSOrderedSame && [detailsDict valueForKey:PARAM_CARD_CVV]){
        [postData appendFormat:@"%@=%@",PARAM_BANK_CODE,@"VISA"];
        [postData appendString:@"&"];
    }
    else if([detailsDict valueForKey:PARAM_CARD_CVV]){
        [postData appendFormat:@"%@=%@",PARAM_BANK_CODE,@"CC"];
        [postData appendString:@"&"];
    }
    if([detailsDict valueForKey:PARAM_CARD_CVV]){
        [postData appendFormat:@"%@=%@",PARAM_CARD_CVV,[detailsDict valueForKey:PARAM_CARD_CVV]];
        [postData appendString:@"&"];
    }
    else{
        [postData appendFormat:@"%@=%@",PARAM_BANK_CODE,@"MAES"];
    }
    
    [postData appendString:@"&"];
    [postData appendFormat:@"%@=%@",PARAM_DEVICE_TYPE,IOS_SDK];
    [postData appendString:@"&"];
    
    //checksum calculation.
    
    NSMutableString *hashValue = [[NSMutableString alloc] init];
    if([paramDict valueForKey:PARAM_KEY]){
        [hashValue appendFormat:@"%@",[paramDict valueForKey:PARAM_KEY]];
        [hashValue appendString:@"|"];
    }
    if([paramDict valueForKey:PARAM_TXID]){
        [hashValue appendFormat:@"%@",[paramDict valueForKey:PARAM_TXID]];
        [hashValue appendString:@"|"];
    }
    if([paramDict valueForKey:PARAM_TOTAL_AMOUNT]){
        [hashValue appendFormat:@"%@",[paramDict valueForKey:PARAM_TOTAL_AMOUNT]];
        [hashValue appendString:@"|"];
    }
    if([paramDict valueForKey:PARAM_PRODUCT_INFO]){
        [hashValue appendFormat:@"%@",[paramDict valueForKey:PARAM_PRODUCT_INFO]];
        [hashValue appendString:@"|"];
    }
    if([paramDict valueForKey:PARAM_FIRST_NAME]){
        [hashValue appendFormat:@"%@",[paramDict valueForKey:PARAM_FIRST_NAME]];
        [hashValue appendString:@"|"];
    }
    if([paramDict valueForKey:PARAM_EMAIL]){
        [hashValue appendFormat:@"%@",[paramDict valueForKey:PARAM_EMAIL]];
        [hashValue appendString:@"|"];
    }
    if([paramDict valueForKey:PARAM_UDF_1]){
        [hashValue appendFormat:@"%@",[paramDict valueForKey:PARAM_UDF_1]];
        [hashValue appendString:@"|"];
    }
    else{
        [hashValue appendString:@"|"];
    }
    if([paramDict valueForKey:PARAM_UDF_2]){
        [hashValue appendFormat:@"%@",[paramDict valueForKey:PARAM_UDF_2]];
        [hashValue appendString:@"|"];
    }
    else{
        [hashValue appendString:@"|"];
    }
    if([paramDict valueForKey:PARAM_UDF_3]){
        [hashValue appendFormat:@"%@",[paramDict valueForKey:PARAM_UDF_3]];
        [hashValue appendString:@"|"];
    }
    else{
        [hashValue appendString:@"|"];
    }
    if([paramDict valueForKey:PARAM_UDF_4]){
        [hashValue appendFormat:@"%@",[paramDict valueForKey:PARAM_UDF_4]];
        [hashValue appendString:@"|"];
    }
    else{
        [hashValue appendString:@"|"];
    }
    if([paramDict valueForKey:PARAM_UDF_5]){
        [hashValue appendFormat:@"%@",[paramDict valueForKey:PARAM_UDF_5]];
        [hashValue appendString:@"|"];
    }
    else{
        [hashValue appendString:@"|"];
    }
    [hashValue appendString:@"|||||"];
    if([paramDict valueForKey:PARAM_SALT]){
        [hashValue appendString:[paramDict valueForKey:PARAM_SALT]];
    }
    
    NSLog(@"Hash String = %@ hashvalue = %@",hashValue,[Utils createCheckSumString:hashValue]);
    [postData appendFormat:@"%@=%@",PARAM_HASH,[Utils createCheckSumString:hashValue]];
    //sha512(key|txnid|amount|productinfo|firstname|email|udf1|udf2|udf3|udf4|udf5||||||SALT)
    NSLog(@"POST DATA = %@",postData);
    //set request content type we MUST set this value.
    [theRequest setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    //set post data of request
    [theRequest setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
    return theRequest;
}

- (NSURLRequest *) URLRequestForPayWithPayUMoney{
   
    if (_connectionSpecificDataObject) {
        _connectionSpecificDataObject = nil;
    }
    _connectionSpecificDataObject = [[NSMutableData alloc] init];
    
    NSURL *restURL = [NSURL URLWithString:PAYU_PAYMENT_BASE_URL];
    
    // create the request
    NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:restURL
                                                            cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                        timeoutInterval:60.0];
    // Specify that it will be a POST request
    theRequest.HTTPMethod = @"POST";
    
    NSDictionary *paramDict = [[SharedDataManager sharedDataManager] allInfoDict];
    NSMutableString *postData = [[NSMutableString alloc] init];
    
    
    NSLog(@"ParamDict = %@",paramDict);
    
    if([paramDict objectForKey:PARAM_TOTAL_AMOUNT]){
        [postData appendFormat:@"%@=%@",PARAM_TOTAL_AMOUNT,[paramDict objectForKey:PARAM_TOTAL_AMOUNT]];
        [postData appendString:@"&"];
        
    }
    [postData appendFormat:@"%@=%@",PARAM_PG,PARAM_PG_WALLET];
    [postData appendString:@"&"];
    
    if([paramDict objectForKey:PARAM_TXID]){
        [postData appendFormat:@"%@=%@",PARAM_TXID,[paramDict objectForKey:PARAM_TXID]];
        [postData appendString:@"&"];
    }
    
    [postData appendFormat:@"%@=%@",PARAM_DEVICE_TYPE,IOS_SDK];
    [postData appendString:@"&"];
    
    [postData appendFormat:@"%@=%@",PARAM_BANK_CODE,WALLET_BANK_CODE];
    [postData appendString:@"&"];
    
    NSString *deviceId;
    #if TARGET_IPHONE_SIMULATOR
    deviceId = @"TARGET_IPHONE_SIMULATOR";
    #else
    deviceId = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    #endif
    
    NSLog(@"DeviceID = %@",deviceId);
    
    [postData appendFormat:@"%@=%@",PARAM_INSTRUMENT_ID,deviceId];
    [postData appendString:@"&"];
    
    [postData appendFormat:@"%@=%@",PARAM_INSTRUMENT_TYPE,INSTRUMENT_TYPE];
    [postData appendString:@"&"];
    
    if([paramDict objectForKey:PARAM_SURL]){
        [postData appendFormat:@"%@=%@",PARAM_SURL,[paramDict objectForKey:PARAM_SURL]];
        [postData appendString:@"&"];
    }
    if([paramDict objectForKey:PARAM_FURL]){
        [postData appendFormat:@"%@=%@",PARAM_FURL,[paramDict objectForKey:PARAM_FURL]];
        [postData appendString:@"&"];
    }
    if([paramDict objectForKey:PARAM_KEY]){
        [postData appendFormat:@"%@=%@",PARAM_KEY,[paramDict objectForKey:PARAM_KEY]];
        [postData appendString:@"&"];
    }
    if([paramDict objectForKey:PARAM_PRODUCT_INFO]){
        [postData appendFormat:@"%@=%@",PARAM_PRODUCT_INFO,[paramDict objectForKey:PARAM_PRODUCT_INFO]];
        [postData appendString:@"&"];
    }
    
    //checksum calculation.
    
    NSMutableString *hashValue = [[NSMutableString alloc] init];
    if([paramDict valueForKey:PARAM_KEY]){
        [hashValue appendFormat:@"%@",[paramDict valueForKey:PARAM_KEY]];
        [hashValue appendString:@"|"];
    }
    if([paramDict valueForKey:PARAM_TXID]){
        [hashValue appendFormat:@"%@",[paramDict valueForKey:PARAM_TXID]];
        [hashValue appendString:@"|"];
    }
    if([paramDict valueForKey:PARAM_TOTAL_AMOUNT]){
        [hashValue appendFormat:@"%@",[paramDict valueForKey:PARAM_TOTAL_AMOUNT]];
        [hashValue appendString:@"|"];
    }
    if([paramDict valueForKey:PARAM_PRODUCT_INFO]){
        [hashValue appendFormat:@"%@",[paramDict valueForKey:PARAM_PRODUCT_INFO]];
        [hashValue appendString:@"|"];
    }
    if([paramDict valueForKey:PARAM_FIRST_NAME]){
        //[hashValue appendFormat:@"%@",[paramDict valueForKey:PARAM_FIRST_NAME]];
        [hashValue appendString:@"|"];
    }
    if([paramDict valueForKey:PARAM_EMAIL]){
        //[hashValue appendFormat:@"%@",[paramDict valueForKey:PARAM_EMAIL]];
        [hashValue appendString:@"|"];
    }
    if([paramDict valueForKey:PARAM_UDF_1]){
        [hashValue appendFormat:@"%@",[paramDict valueForKey:PARAM_UDF_1]];
        [hashValue appendString:@"|"];
    }
    else{
        [hashValue appendString:@"|"];
    }
    if([paramDict valueForKey:PARAM_UDF_2]){
        [hashValue appendFormat:@"%@",[paramDict valueForKey:PARAM_UDF_2]];
        [hashValue appendString:@"|"];
    }
    else{
        [hashValue appendString:@"|"];
    }
    if([paramDict valueForKey:PARAM_UDF_3]){
        [hashValue appendFormat:@"%@",[paramDict valueForKey:PARAM_UDF_3]];
        [hashValue appendString:@"|"];
    }
    else{
        [hashValue appendString:@"|"];
    }
    if([paramDict valueForKey:PARAM_UDF_4]){
        [hashValue appendFormat:@"%@",[paramDict valueForKey:PARAM_UDF_4]];
        [hashValue appendString:@"|"];
    }
    else{
        [hashValue appendString:@"|"];
    }
    if([paramDict valueForKey:PARAM_UDF_5]){
        [hashValue appendFormat:@"%@",[paramDict valueForKey:PARAM_UDF_5]];
        [hashValue appendString:@"|"];
    }
    else{
        [hashValue appendString:@"|"];
    }
    [hashValue appendString:@"|||||"];
    if([paramDict valueForKey:PARAM_SALT]){
        [hashValue appendString:[paramDict valueForKey:PARAM_SALT]];
    }
    
    NSLog(@"Hash String = %@ hashvalue = %@",hashValue,[Utils createCheckSumString:hashValue]);
    [postData appendFormat:@"%@=%@",PARAM_HASH,[Utils createCheckSumString:hashValue]];
    //sha512(key|txnid|amount|productinfo|firstname|email|udf1|udf2|udf3|udf4|udf5||||||SALT)
    NSLog(@"POST DATA = %@",postData);
    //set request content type we MUST set this value.
    [theRequest setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    //set post data of request
    [theRequest setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
    
    return theRequest;
}


// Reachability methods
- (void)reachabilityDidChange:(NSNotification *)notification {
    Reachability *reach = [notification object];
    
    if ([reach isReachable]) {
        
    } else {
        ALog(@"");
        [Utils startPayUNotificationForKey:PAYU_ERROR intValue:PInternetNotReachable object:self];
    }
}

@end
