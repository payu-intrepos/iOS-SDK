//
//  SharedDataManager.m
//  PayU_iOS_SDK
//
//  Created by Suryakant Sharma on 16/12/14.
//  Copyright (c) 2014 PayU, India. All rights reserved.
//

#import "SharedDataManager.h"
#import "PayUConstant.h"
#import "Utils.h"

#define  DEFAULT  @"default"
#define  UPSTATUS @"up_status"
#define  TITLE    @"title"

@implementation SharedDataManager

+ (id)sharedDataManager {
    static SharedDataManager *sharedDataManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDataManager = [[self alloc] init];
        sharedDataManager.storedCard = nil;
        sharedDataManager.allInfoDict = nil;
        sharedDataManager.allPaymentOptionDict = nil;
    });
    return sharedDataManager;
}

- (id)init {
    if (self = [super init]) {
        _allPaymentOptionDict = [[NSMutableDictionary alloc] init];
        _allInfoDict = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (BOOL) isSBIMaestro:(NSString *) cardNumber{
    NSLog(@"cardNumber bin = %@",cardNumber);
    NSString *firstFiveCardDigit = [cardNumber substringToIndex:6];
    NSLog(@"firstFiveCardDigit bin = %@",cardNumber);

    if(!_allSbiBins)
    _allSbiBins = [NSMutableArray arrayWithObjects:@"504435",@"504645",@"504774",@"504645",@"504775",@"504809",@"504993",@"600206",@"603845",@"622018", nil];
    for(NSString *aSbiBin in _allSbiBins){
        if([firstFiveCardDigit isEqualToString:aSbiBin]){
            _allSbiBins = nil;
            return YES;
        }
    }
    return NO;
}

- (void) makeVasApiCall{
    
    NSURL *restURL = [NSURL URLWithString:PAYU_PAYMENT_ALL_AVAILABLE_PAYMENT_OPTION];
    
    // create the request
    NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:restURL
                                                            cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                        timeoutInterval:60.0];
    // Specify that it will be a POST request
    theRequest.HTTPMethod = @"POST";
    /*
     Sending value of user_credentials as var1 according to new UI
     */
    
    
    NSString *checkSum = nil;
    if(HASH_KEY_GENERATION_FROM_SERVER){
        if ([[[SharedDataManager sharedDataManager] hashDict] valueForKey:MOBILE_SDK]) {
            checkSum = [[[SharedDataManager sharedDataManager] hashDict] valueForKey:MOBILE_SDK];
        } else {
            checkSum = [[[SharedDataManager sharedDataManager] hashDict] valueForKey:VAS_FOR_MOBILE_SDK];
        }
    }
    else{
//        checkSum = [Utils createCheckSumString:[NSString stringWithFormat:@"%@|%@|%@|%@",[[[SharedDataManager sharedDataManager] allInfoDict] objectForKey:PARAM_KEY],PARAM_VAS_COMMAND_VALUE,DEFAULT,[[[SharedDataManager sharedDataManager] allInfoDict] objectForKey:PARAM_SALT]]];
    }
    NSString *postData = [NSString stringWithFormat:@"key=%@&command=%@&var1=%@&var2=%@&var3=%@&device_type=%@&hash=%@",[[[SharedDataManager sharedDataManager] allInfoDict] objectForKey:PARAM_KEY],PARAM_VAS_COMMAND_VALUE,DEFAULT,DEFAULT,DEFAULT,IOS_SDK,checkSum];
    
    //set request content type we MUST set this value.
    [theRequest setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    //set post data of request
    [theRequest setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSOperationQueue *networkQueue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:theRequest queue:networkQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSError *errorJson = nil;
        if(data){
            NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&errorJson];
            NSLog(@"VAS : %@",responseDict);
            [self sortDownInternetBank :[responseDict valueForKey:@"netBankingStatus"]];
            //_listOfDownCardBins  = [responseDict valueForKey:@"issuingBankDownBins"];
            [self sortDownBankCard:[responseDict valueForKey:@"issuingBankDownBins"]];
        }
        NSLog( @"netBankingStatus = %@",_listOfDownInternetBanking);
        NSLog( @"issuingBankDownBins = %@",_listOfDownCardBins);
    }];

}
- (void) sortDownInternetBank:(NSDictionary *)listOfDownBanks{
    
    NSLog(@"Test internetr options allInternetBankingOptionsDict = %@",listOfDownBanks);
    
    if(listOfDownBanks.allKeys.count){
        
        for(NSString *aKey in listOfDownBanks){
            NSMutableDictionary *bankDict = [NSMutableDictionary dictionaryWithDictionary:[listOfDownBanks objectForKey:aKey]];
            if([[[bankDict objectForKey:UPSTATUS] stringValue] isEqualToString:@"0"]){
                if(!_listOfDownInternetBanking){
                    _listOfDownInternetBanking = [[NSMutableArray alloc] init];
                }
                [_listOfDownInternetBanking addObject:[bankDict objectForKey:TITLE]];
            }
        }
    }
    NSLog(@"list of all down banks in shared Data : %@",_listOfDownInternetBanking);
}

- (void) sortDownBankCard:(NSArray *) arrayOfAllCardBins{
    
    if(0 != arrayOfAllCardBins.count){
        for(NSDictionary *aDict in arrayOfAllCardBins){
            if([[[aDict valueForKey:@"status"] stringValue] isEqualToString:@"0"]){
                if(!_listOfDownCardBins){
                    _listOfDownCardBins = [[NSMutableArray alloc] init];
                }
                [_listOfDownCardBins addObject:aDict];
            }
        }
    }
}

- (NSString *)checkCardDownTime:(NSString *) cardNumber {

    for(NSDictionary *aDict in _listOfDownCardBins){
        NSArray *binsArray = [aDict valueForKey:@"bins_arr"];
        if([binsArray containsObject:cardNumber]){
            return [aDict valueForKey:@"issuing_bank"];
        }
    }
    return nil;
}

@end
