//
//  PayUPaymnetOptionsViewController.m
//  PayU_iOS_SDK
//
//  Created by Suryakant Sharma on 09/12/14.
//  Copyright (c) 2014 PayU, India. All rights reserved.
//

#import "PayUPaymentOptionsViewController.h"
#import "PayUConstant.h"
#import <CommonCrypto/CommonDigest.h>
#import "PreferredPaymentMethodCustomeCell.h"
#import "PayUCardProcessViewController.h"
#import "PayUStoredCardViewController.h"
#import "SharedDataManager.h"
#import "PayUInternetBankingViewController.h"
#import "PayUEMIOptionViewController.h"
#import "Utils.h"
#import "PayUCashCardViewController.h"
#import "PayUConnectionHandlerController.h"

// POX
#import "PayUGetResponseTask.h"

#define CASH_CARD               @"cashcard"

#define PARAM_VAR1_DEFAULT      @"default"
#define PARAM_BANK              @"bank"

#define RESPONSE_DICT_KEY_1     @"ibiboCodes"
#define RESPONSE_DICT_KEY_2     @"userCards"


typedef enum : NSUInteger {
    STORED_CARD,
    CREDIT_OR_DEBIT_CARD,
    NETBANKING,
    EMI,
    CASHCARD,
    PAYU_MONEY
} ePAYMENT_OPTIONS;


@interface PayUPaymentOptionsViewController () <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) PayUGetResponseTask *payUGetResponseTask; // POX
@property (nonatomic,strong) NSURLConnection *connection;
@property (nonatomic,strong) NSMutableData *connectionSpecificDataObject;
@property (nonatomic,strong) NSMutableData *receivedData;
@property (nonatomic,strong) NSMutableDictionary *allPaymentOption;

@property (nonatomic,strong) IBOutlet UITableView *preferredPaymentTable;
@property (unsafe_unretained, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic,strong) IBOutlet UILabel *amountLbl;

-(void) callAPI;


@property (nonatomic, retain) NSMutableArray *allPaymentMethodNameArray;

- (NSDictionary *) createDictionaryWithAllParam;
- (void) loadAllStoredCard:(int) aFlag;
- (void) loadCCDCView:(int)cardFlag;

@end

@implementation PayUPaymentOptionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationItem.title = _appTitle;
    _connectionSpecificDataObject = [[NSMutableData alloc] init];
    
    //setting up preferred Payment option tableView
    _preferredPaymentTable.delegate = self;
    _preferredPaymentTable.dataSource = self;
    _preferredPaymentTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    _activityIndicator.hidden = NO;
    [_activityIndicator startAnimating];
    SharedDataManager *dataManager = [SharedDataManager sharedDataManager];
    dataManager.allInfoDict = [self createDictionaryWithAllParam];
    
    ALog(@"AllInfoDict = %f",[[dataManager.allInfoDict objectForKey:PARAM_TOTAL_AMOUNT] floatValue]);
    _amountLbl.text = [NSString stringWithFormat:@"Rs. %.2f",[[dataManager.allInfoDict objectForKey:PARAM_TOTAL_AMOUNT] floatValue]];
    
    //_preferredPaymentTable.backgroundColor = [UIColor colorWithRed:240.0/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:1.0f];
    
    NSLog(@"Shared Dict Param = %@ ARGUMENT DICT = %@",dataManager.allInfoDict,_parameterDict);
    NSLog(@"Server API = %@ and ALL Option API = %@",PAYU_PAYMENT_BASE_URL,PAYU_PAYMENT_ALL_AVAILABLE_PAYMENT_OPTION);

    if(1 == HASH_KEY_GENERATION_FROM_SERVER) {
        dataManager.hashDict = _allHashDict;
        [self callAPI];

    }
    else if(2 == HASH_KEY_GENERATION_FROM_SERVER)
    {
        [PayUConnectionHandlerController generateHashFromServer:dataManager.allInfoDict withCompletionBlock:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            NSLog(@"Hash is generated fron PayU server");
            [self callAPI];

        }];
    }
    else{
        [self callAPI];
    }

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) sortBankOptionArray:(NSArray *)bankOption{
    _allPaymentMethodNameArray = [[NSMutableArray alloc] init];
    
    NSArray *names = [[NSArray alloc] initWithObjects:PARAM_STORE_CARD,PARAM_CREDIT_CARD,PARAM_NET_BANKING,PARAM_EMI,PARAM_CASH_CARD,PARAM_PAYU_MONEY,nil];
    
    for (NSString * name in names) {
        for (NSString *str in bankOption) {
            if ([str isEqualToString:name]) {
                if([name isEqualToString:PARAM_CREDIT_CARD] ){
                    [_allPaymentMethodNameArray addObject:PARAM_CREDIT_DEBIT_CARD];
                }
                else  if(![name isEqualToString:PARAM_DEBIT_CARD] ){
                    [_allPaymentMethodNameArray addObject:str];
                }
            }
        }
    }
//    [_allPaymentMethodNameArray insertObject:PARAM_STORE_CARD atIndex:0];
//    [_allPaymentMethodNameArray addObject:PARAM_PAYU_MONEY];
//    ALog(@"All Key = %@ Sorted option = %@", bankOption, _allPaymentMethodNameArray);
    
//    if ([dataManager.allInfoDict valueForKey:PARAM_USER_CREDENTIALS])
//        [_allPaymentMethodNameArray insertObject:PARAM_STORE_CARD atIndex:0];
//    [_allPaymentMethodNameArray addObject:PARAM_PAYU_MONEY];
//    ALog(@"All Key = %@ Sorted option = %@", bankOption, _allPaymentMethodNameArray);
}

- (void) loadAllStoredCard:(int) aFlag{
    
    PayUStoredCardViewController *storedCard = nil;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        CGSize result = [[UIScreen mainScreen] bounds].size;
        if(result.height == IPHONE_3_5)
        {
            storedCard = [[PayUStoredCardViewController alloc] initWithNibName:@"StoredCard" bundle:nil];
        }
        else
        {
            storedCard = [[PayUStoredCardViewController alloc] initWithNibName:@"PayUStoredCardViewController" bundle:nil];
        }
    }
    storedCard.appTitle = _appTitle;
    storedCard.totalAmount = _totalAmount;
    [self.navigationController pushViewController:storedCard animated:YES];
}

-(void) loadCCDCView:(int)cardFlag {
    
    PayUCardProcessViewController *cardProcessCV = nil;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        CGSize result = [[UIScreen mainScreen] bounds].size;
        if(result.height == IPHONE_3_5)
        {
            cardProcessCV = [[PayUCardProcessViewController alloc] initWithNibName:@"CardProcessView" bundle:nil];
        }
        else
        {
            cardProcessCV = [[PayUCardProcessViewController alloc] initWithNibName:@"PayUCardProcessViewController" bundle:nil];
        }
    }
    cardProcessCV.appTitle = _appTitle;
    cardProcessCV.CCDCFlag = cardFlag;
    [self.navigationController pushViewController:cardProcessCV animated:YES];
}

-(void) loadAllEMIOption{
//    NSDictionary *allEMIOptionsDict = [[_allPaymentOption valueForKey:RESPONSE_DICT_KEY_1]objectForKey:PARAM_EMI];
//    NSMutableArray *allEMIOptions = nil;
//    if(allEMIOptionsDict.allKeys.count){
//        allEMIOptions =  [[NSMutableArray alloc] init];
//        for(NSString *aKey in allEMIOptionsDict){
//            NSMutableDictionary *emiBankDict = [NSMutableDictionary dictionaryWithDictionary:[allEMIOptionsDict objectForKey:aKey]];
//            [emiBankDict setValue:aKey forKey:PARAM_BANK_CODE];
//            [allEMIOptions addObject:emiBankDict];
//        }
//    }
//    NSArray *listOfBankAvailableForEMI = [allEMIOptions sortedArrayUsingComparator:^(NSDictionary *item1, NSDictionary *item2) {
//        return [item1[PARAM_BANK] compare:item2[PARAM_BANK] options:NSNumericSearch];
//    }];
    PayUEMIOptionViewController *emiOprionVC = nil;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        CGSize result = [[UIScreen mainScreen] bounds].size;
        if(result.height == IPHONE_3_5)
        {
            emiOprionVC = [[PayUEMIOptionViewController alloc] initWithNibName:@"EMIOptionView" bundle:nil];
        }
        else if (result.height == IPHONE_4){
            emiOprionVC = [[PayUEMIOptionViewController alloc] initWithNibName:@"EMIOption5" bundle:nil];
        }
        else
        {
            emiOprionVC = [[PayUEMIOptionViewController alloc] initWithNibName:@"PayUEMIOptionViewController" bundle:nil];
        }
    }
    
    
//    emiOprionVC.emiDetails = listOfBankAvailableForEMI;
    emiOprionVC.emiDetails = self.payUGetResponseTask.emiAvailableArray;
    emiOprionVC.paymentCategory = @"EMI";
    [self.navigationController pushViewController:emiOprionVC animated:YES];
    
}

-(void) loadAllInternetBankingOption{
//    NSDictionary *allInternetBankingOptionsDict = [[_allPaymentOption valueForKey:@"ibiboCodes"]valueForKey:NET_BANKING];
//    NSMutableArray *allInternetBankingOptions = nil;
//    if(allInternetBankingOptionsDict.allKeys.count)
//    {
//        allInternetBankingOptions =  [[NSMutableArray alloc] init];
//        for(NSString *aKey in allInternetBankingOptionsDict){
//            NSMutableDictionary *bankDict = [NSMutableDictionary dictionaryWithDictionary:[allInternetBankingOptionsDict objectForKey:aKey]];
//            [bankDict setValue:aKey forKey:PARAM_BANK_CODE];
//            [allInternetBankingOptions addObject:bankDict];
//        }
//    }
//    NSArray *listOfBankAvailableForNetBanking = [allInternetBankingOptions sortedArrayUsingComparator:^(NSDictionary *item1, NSDictionary *item2) {
//        return [item1[BANK_TITLE] compare:item2[BANK_TITLE] options:NSCaseInsensitiveSearch];
//    }];
//    ALog(@"Sorted Bank by default = %@",listOfBankAvailableForNetBanking);
    //    ALog(@"Sorted Bank bt sorted selector = %@",[listOfBankAvailableForNetBanking sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]);
    
    PayUInternetBankingViewController *internetBankingVC = [[PayUInternetBankingViewController alloc] initWithNibName:@"PayUInternetBankingViewController" bundle:nil];
    internetBankingVC.bankDetails = self.payUGetResponseTask.banksAvailableArray;
    
    [self.navigationController pushViewController:internetBankingVC animated:YES];
    
}

-(void) loadAllCashCardOption{
    
//    NSDictionary *allCashCardOptionsDict = [[_allPaymentOption valueForKey:@"ibiboCodes"] objectForKey:CASH_CARD];
//    NSMutableArray *allInternetBankingOptions = nil;
//    if(allCashCardOptionsDict.allKeys.count)
//    {
//        allInternetBankingOptions =  [[NSMutableArray alloc] init];
//        for(NSString *aKey in allCashCardOptionsDict){
//            NSMutableDictionary *bankDict = [NSMutableDictionary dictionaryWithDictionary:[allCashCardOptionsDict objectForKey:aKey]];
//            [bankDict setValue:aKey forKey:PARAM_BANK_CODE];
//            [allInternetBankingOptions addObject:bankDict];
//        }
//    }
//    NSArray *listOfBankAvailableCashCardPayment = [allInternetBankingOptions sortedArrayUsingComparator:^(NSDictionary *item1, NSDictionary *item2) {
//        return [item1[PARAM_BANK_CODE] compare:item2[PARAM_BANK_CODE] options:NSNumericSearch];
//    }];
    
    PayUCashCardViewController *cashCardVC = nil;
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        CGSize result = [[UIScreen mainScreen] bounds].size;
        if(result.height == IPHONE_3_5)
        {
            cashCardVC = [[PayUCashCardViewController alloc] initWithNibName:@"CashCardView" bundle:nil];
        }
        else
        {
            cashCardVC = [[PayUCashCardViewController alloc] initWithNibName:@"PayUCashCardViewController" bundle:nil];
        }
    }
    
//    cashCardVC.cashCardDetail = listOfBankAvailableCashCardPayment;
    cashCardVC.cashCardDetail = self.payUGetResponseTask.cashCardsAvailableArray;
    // POX
//    listOfBankAvailableCashCardPayment = nil;
    
    [self.navigationController pushViewController:cashCardVC animated:YES];
    
}

- (void) payWithPayUMoney{
    
    PayUConnectionHandlerController *connectionHandler = [[PayUConnectionHandlerController alloc] init:nil];
    
    PayUPaymentResultViewController *resultViewController = [[PayUPaymentResultViewController alloc] initWithNibName:@"PayUPaymentResultViewController" bundle:nil];
    resultViewController.request = [connectionHandler URLRequestForPayWithPayUMoney];;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        CGSize result = [[UIScreen mainScreen] bounds].size;
        if(result.height == IPHONE_3_5)
        {
            resultViewController.flag = YES;
            
        }
        else{
            resultViewController.flag = NO;
        }
        
    }
    
    [self.navigationController pushViewController:resultViewController animated:YES];

}

-(NSDictionary *) createDictionaryWithAllParam{
    
    NSMutableDictionary *allParamDict = [[NSMutableDictionary alloc] init];
    NSException *exeption = nil;
    if([[NSBundle mainBundle] objectForInfoDictionaryKey:PARAM_VAR1]){
        _var1  = PARAM_VAR1_DEFAULT;
    }
    
    if([[NSBundle mainBundle] objectForInfoDictionaryKey:PARAM_SALT]){
        _salt = [[NSBundle mainBundle] objectForInfoDictionaryKey:PARAM_SALT];
        [allParamDict setValue:_salt forKey:PARAM_SALT];
    }
    else{
        exeption = [[NSException alloc] initWithName:@"Required Param missing" reason:@"SALT is not provided, this is one of required parameters." userInfo:nil];
        [exeption raise];
    }
    
    if([[NSBundle mainBundle] objectForInfoDictionaryKey:PARAM_KEY]){
        _key = [[NSBundle mainBundle] objectForInfoDictionaryKey:PARAM_KEY];
        [allParamDict setValue:_key forKey:PARAM_KEY];
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
    
    [allParamDict addEntriesFromDictionary:_parameterDict];
    ALog(@"ARGUMENT PARAM DICT =%@",_parameterDict);

    
    ALog(@"ALL PARAM DICT =%@",allParamDict);
    return allParamDict;
}

#pragma mark - TableView DataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _allPaymentMethodNameArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellIdentifier = @"cellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
        cell.backgroundColor = [UIColor colorWithRed:240.0/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:1.0f];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
    }
    
    NSString *keyName = _allPaymentMethodNameArray[indexPath.row];
    
    
    
    if([keyName caseInsensitiveCompare:PARAM_DEBIT_CARD] == NSOrderedSame){
        
        cell.textLabel.text = @"Debit Card";
        
        cell.imageView.image = [UIImage imageNamed:@"card.png"];
        
    }
    
    else if ([keyName caseInsensitiveCompare:@"Credit/Debit card"] == NSOrderedSame){
        
        cell.textLabel.text = keyName;
        
        cell.imageView.image = [UIImage imageNamed:@"card.png"];
        
    }
    
    else if ([keyName caseInsensitiveCompare:PARAM_NET_BANKING] == NSOrderedSame){
        
        cell.textLabel.text = @"Net Banking";
        
        cell.imageView.image = [UIImage imageNamed:@"lock2.png"];
        
    }
    
    else if ([keyName caseInsensitiveCompare:PARAM_EMI] == NSOrderedSame){
        
        cell.textLabel.text = @"EMI";
        
        cell.imageView.image = [UIImage imageNamed:@"coin.png"];
        
    }
    
    else if ([keyName caseInsensitiveCompare:PARAM_REWARD] == NSOrderedSame){
        
        cell.textLabel.text = @"Rewards";
        
        cell.imageView.image = [UIImage imageNamed:@"card.png"];
        
    }
    
    else if ([keyName caseInsensitiveCompare:PARAM_CASH_CARD] == NSOrderedSame){
        
        cell.textLabel.text = @"Cash Card";
        
        cell.imageView.image = [UIImage imageNamed:@"cash_card.png"];
        
    }
    
    else if ([keyName caseInsensitiveCompare:PARAM_STORE_CARD] == NSOrderedSame){
        
        cell.textLabel.text = @"Stored Cards";
        
        cell.imageView.image = [UIImage imageNamed:@"store_card.png"];
        
    }
    
    else if ([keyName caseInsensitiveCompare:PARAM_CASH_ON_DILEVERY] == NSOrderedSame){
        
        cell.textLabel.text = @"Cash on Delivery";
        
        cell.imageView.image = [UIImage imageNamed:@"store_card.png"];
        
    }
    
    else if ([keyName caseInsensitiveCompare:PARAM_PAYU_MONEY] == NSOrderedSame){
        
        cell.textLabel.text = PARAM_PAYU_MONEY;
        
        cell.imageView.image = [UIImage imageNamed:@"payu_money.png"];
        
    }
    
    else{
        
        cell.textLabel.text = keyName;
        
        cell.imageView.image = [UIImage imageNamed:@"card.png"];
        
    }
    
    
    
    return cell;
}

#pragma mark - TableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger selection = indexPath.row;
    
    NSString *keyName = _allPaymentMethodNameArray[indexPath.row];
    
    if([keyName caseInsensitiveCompare:PARAM_DEBIT_CARD] == NSOrderedSame){
        [self loadCCDCView:2];
    }
    else if ([keyName caseInsensitiveCompare:@"Credit/Debit card"] == NSOrderedSame){
        [self loadCCDCView:1];
    }
    else if ([keyName caseInsensitiveCompare:PARAM_NET_BANKING] == NSOrderedSame){
        [self loadAllInternetBankingOption];
    }
    else if ([keyName caseInsensitiveCompare:PARAM_EMI] == NSOrderedSame){
        [self loadAllEMIOption];
    }
//    else if ([keyName caseInsensitiveCompare:@"rewards"] == NSOrderedSame){
//        cell.preferredPaymentOption.text = @"Rewards";
//        cell.paymentImage.image = [UIImage imageNamed:@"card.png"];
//    }
    else if ([keyName caseInsensitiveCompare:PARAM_CASH_CARD] == NSOrderedSame){
        [self loadAllCashCardOption];
    }
    else if ([keyName caseInsensitiveCompare:PARAM_STORE_CARD] == NSOrderedSame){
        //Stored Card.
        [self loadAllStoredCard:(int)selection];
    }
//    else if ([keyName caseInsensitiveCompare:PARAM_CASH_ON_DILEVERY] == NSOrderedSame){
//        cell.preferredPaymentOption.text = @"Cash on Delivery";
//        cell.paymentImage.image = [UIImage imageNamed:@"store_card.png"];
//    }
    else if ([keyName caseInsensitiveCompare:PARAM_PAYU_MONEY] == NSOrderedSame){
        [self payWithPayUMoney];
    }
}


#pragma mark - Web Services call by NSURLConnection
// Connection Request.
-(void) callAPI{
    NSURL *restURL = [NSURL URLWithString:PAYU_PAYMENT_ALL_AVAILABLE_PAYMENT_OPTION];
    
    
    // create the request
    NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:restURL
                                                            cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                        timeoutInterval:60.0];
    // Specify that it will be a POST request
    theRequest.HTTPMethod = @"POST";
    /* 
        Sending value of user_credentials as var1 according to new API
     */
    NSString *hashStr = nil;
    if(HASH_KEY_GENERATION_FROM_SERVER){
        hashStr = [[[[SharedDataManager sharedDataManager] hashDict] valueForKey:@"result"] valueForKey:@"detailsForMobileSdk"];
    }
    else {
        hashStr = [Utils createCheckSumString:[NSString stringWithFormat:@"%@|%@|%@|%@",[[[SharedDataManager sharedDataManager] allInfoDict] objectForKey:PARAM_KEY],_command,[[[SharedDataManager sharedDataManager] allInfoDict] objectForKey:PARAM_USER_CREDENTIALS],[[[SharedDataManager sharedDataManager] allInfoDict] objectForKey:PARAM_SALT]]];
    }
    NSLog(@"Hash from Server = %@",hashStr);
    
    NSString *postData = [NSString stringWithFormat:@"key=%@&var1=%@&command=%@&hash=%@",[[[SharedDataManager sharedDataManager] allInfoDict] objectForKey:PARAM_KEY],[[[SharedDataManager sharedDataManager] allInfoDict] objectForKey:PARAM_USER_CREDENTIALS],_command,hashStr];
    
    NSLog(@"POST Data = %@",postData);

    
    //set request content type we MUST set this value.
    [theRequest setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    //set post data of request
    [theRequest setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    // create the connection with the request
    // and start loading the data
    _connection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    if (_connection) {
        _receivedData=[NSMutableData data];
    } else {
        // inform the user that the download could not be made
    }
    [_connection start];
}

#pragma mark - NSURLConnection Delegate methods

// NSURLCONNECTION Delegate methods.

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    ALog(@"");
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    ALog(@"");
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (connection == _connection)
    {
        // do something with the data object.
        if(data){
            [_connectionSpecificDataObject appendData:data];
        }
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if (connection == _connection)
    {
        if(_connectionSpecificDataObject){
            NSError *errorJson=nil;
            
            _allPaymentOption = [NSJSONSerialization JSONObjectWithData:_connectionSpecificDataObject options:kNilOptions error:&errorJson];
            
            //POX
            _payUGetResponseTask = [[PayUGetResponseTask alloc] initWithAllPaymentOptionsDictionary:_allPaymentOption];
            
            SharedDataManager *dataManager = [SharedDataManager sharedDataManager];
            
            //        ALog(@"First API Call response = %@",_allPaymentOption);
            
            dataManager.allPaymentOptionDict = [_allPaymentOption valueForKey:RESPONSE_DICT_KEY_1];
            
            //dataManager.storedCard = [_allPaymentOption valueForKey:RESPONSE_DICT_KEY_2];
            
            //        ALog(@"responseDict=%@",_allPaymentOption);
            
            
            
            //sort available payment methods.
            
            // POX
            //        [self sortBankOptionArray:[[_allPaymentOption valueForKey:RESPONSE_DICT_KEY_1] allKeys]];
            [self sortBankOptionArray:self.payUGetResponseTask.modesAvailableArray];
            
            [_preferredPaymentTable reloadData];
            _activityIndicator.hidden = YES;
            [_activityIndicator stopAnimating];
        }
    }
}

@end
