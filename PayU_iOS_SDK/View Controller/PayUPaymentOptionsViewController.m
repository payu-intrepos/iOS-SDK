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

#define CASH_CARD               @"cashcard"

#define PARAM_VAR1_DEFAULT      @"default"
#define PARAM_BANK              @"bank"



@interface PayUPaymentOptionsViewController () <UITableViewDataSource,UITableViewDelegate>


@property (nonatomic,strong) NSURLConnection *connection;
@property (nonatomic,strong) NSMutableData *connectionSpecificDataObject;
@property (nonatomic,strong) NSMutableData *receivedData;
@property (nonatomic,strong) NSMutableDictionary *allPaymentOption;

@property (nonatomic,strong) IBOutlet UITableView *preferredPaymentTable;
@property (unsafe_unretained, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic,strong) IBOutlet UILabel *amountLbl;



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
    
    _amountLbl.text = [NSString stringWithFormat:@"Rs. %.2f",[[dataManager.allInfoDict objectForKey:PARAM_TOTAL_AMOUNT] floatValue]];
    
    NSLog(@"Shared Dict Param = %@ ARGUMENT DICT = %@",dataManager.allInfoDict,_parameterDict);
    NSLog(@"Server API = %@ and ALL Option API = %@",PAYU_PAYMENT_BASE_URL,PAYU_PAYMENT_ALL_AVAILABLE_PAYMENT_OPTION);

    
    [self callAPI];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) sortBankOptionArray:(NSArray *)bankOption{
    _allPaymentMethodNameArray = [[NSMutableArray alloc] init];
    
    NSArray *names = [[NSArray alloc] initWithObjects:PARAM_STORE_CARD,PARAM_CREDIT_CARD,PARAM_DEBIT_CARD,PARAM_NET_BANKING,PARAM_EMI,PARAM_CASH_CARD,PARAM_PAYU_MONEY,nil];
    
    for (NSString * name in names) {
        for (NSString *str in bankOption) {
            if ([str isEqualToString:name]) {
                [_allPaymentMethodNameArray addObject:str];
            }
        }
    }
    [_allPaymentMethodNameArray insertObject:PARAM_STORE_CARD atIndex:0];
    [_allPaymentMethodNameArray addObject:PARAM_PAYU_MONEY];
    NSLog(@"All Key = %@ Sorted option = %@", bankOption, _allPaymentMethodNameArray);
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
    NSDictionary *allEMIOptionsDict = [_allPaymentOption objectForKey:PARAM_EMI];
    NSMutableArray *allEMIOptions = nil;
    if(allEMIOptionsDict.allKeys.count){
        allEMIOptions =  [[NSMutableArray alloc] init];
        for(NSString *aKey in allEMIOptionsDict){
            NSMutableDictionary *emiBankDict = [NSMutableDictionary dictionaryWithDictionary:[allEMIOptionsDict objectForKey:aKey]];
            [emiBankDict setValue:aKey forKey:PARAM_BANK_CODE];
            [allEMIOptions addObject:emiBankDict];
        }
    }
    NSArray *listOfBankAvailableForEMI = [allEMIOptions sortedArrayUsingComparator:^(NSDictionary *item1, NSDictionary *item2) {
        return [item1[PARAM_BANK] compare:item2[PARAM_BANK] options:NSNumericSearch];
    }];
    PayUEMIOptionViewController *emiOprionVC = nil;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        CGSize result = [[UIScreen mainScreen] bounds].size;
        if(result.height == IPHONE_3_5)
        {
            emiOprionVC = [[PayUEMIOptionViewController alloc] initWithNibName:@"EMIOptionView" bundle:nil];
        }
        else
        {
            emiOprionVC = [[PayUEMIOptionViewController alloc] initWithNibName:@"PayUEMIOptionViewController" bundle:nil];
        }
    }
    
    
    emiOprionVC.emiDetails = listOfBankAvailableForEMI;
    emiOprionVC.paymentCategory = @"EMI";
    [self.navigationController pushViewController:emiOprionVC animated:YES];
    
}

-(void) loadAllInternetBankingOption{
    NSDictionary *allInternetBankingOptionsDict = [_allPaymentOption objectForKey:NET_BANKING];
    NSMutableArray *allInternetBankingOptions = nil;
    if(allInternetBankingOptionsDict.allKeys.count)
    {
        allInternetBankingOptions =  [[NSMutableArray alloc] init];
        for(NSString *aKey in allInternetBankingOptionsDict){
            NSMutableDictionary *bankDict = [NSMutableDictionary dictionaryWithDictionary:[allInternetBankingOptionsDict objectForKey:aKey]];
            [bankDict setValue:aKey forKey:PARAM_BANK_CODE];
            [allInternetBankingOptions addObject:bankDict];
        }
    }
    NSArray *listOfBankAvailableForNetBanking = [allInternetBankingOptions sortedArrayUsingComparator:^(NSDictionary *item1, NSDictionary *item2) {
        return [item1[BANK_TITLE] compare:item2[BANK_TITLE] options:NSCaseInsensitiveSearch];
    }];
    NSLog(@"Sorted Bank by default = %@",listOfBankAvailableForNetBanking);
    //    NSLog(@"Sorted Bank bt sorted selector = %@",[listOfBankAvailableForNetBanking sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]);
    
    PayUInternetBankingViewController *internetBankingVC = [[PayUInternetBankingViewController alloc] initWithNibName:@"PayUInternetBankingViewController" bundle:nil];
    internetBankingVC.bankDetails = listOfBankAvailableForNetBanking;
    
    [self.navigationController pushViewController:internetBankingVC animated:YES];
    
}

-(void) loadAllCashCardOption{
    
    NSDictionary *allCashCardOptionsDict = [_allPaymentOption objectForKey:CASH_CARD];
    NSMutableArray *allInternetBankingOptions = nil;
    if(allCashCardOptionsDict.allKeys.count)
    {
        allInternetBankingOptions =  [[NSMutableArray alloc] init];
        for(NSString *aKey in allCashCardOptionsDict){
            NSMutableDictionary *bankDict = [NSMutableDictionary dictionaryWithDictionary:[allCashCardOptionsDict objectForKey:aKey]];
            [bankDict setValue:aKey forKey:PARAM_BANK_CODE];
            [allInternetBankingOptions addObject:bankDict];
        }
    }
    NSArray *listOfBankAvailableCashCardPayment = [allInternetBankingOptions sortedArrayUsingComparator:^(NSDictionary *item1, NSDictionary *item2) {
        return [item1[PARAM_BANK_CODE] compare:item2[PARAM_BANK_CODE] options:NSNumericSearch];
    }];
    
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
    
    cashCardVC.cashCardDetail = listOfBankAvailableCashCardPayment;
    listOfBankAvailableCashCardPayment = nil;
    
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
    NSLog(@"ARGUMENT PARAM DICT =%@",_parameterDict);

    
    NSLog(@"ALL PARAM DICT =%@",allParamDict);
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
    
    static NSString *cellIdentifier = @"customCell";
    
    PreferredPaymentMethodCustomeCell *cell = (PreferredPaymentMethodCustomeCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"PreferredPaymentMethodCustomeCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    NSString *keyName = _allPaymentMethodNameArray[indexPath.row];
    
    if([keyName caseInsensitiveCompare:@"debitcard"] == NSOrderedSame){
        cell.preferredPaymentOption.text = @"Debit Card";
        cell.paymentImage.image = [UIImage imageNamed:@"card.png"];
    }
    else if ([keyName caseInsensitiveCompare:@"creditcard"] == NSOrderedSame){
        cell.preferredPaymentOption.text = @"Credit Card";
        cell.paymentImage.image = [UIImage imageNamed:@"card.png"];
    }
    else if ([keyName caseInsensitiveCompare:@"netbanking"] == NSOrderedSame){
        cell.preferredPaymentOption.text = @"Net banking";
        cell.paymentImage.image = [UIImage imageNamed:@"lock2.png"];
    }
    else if ([keyName caseInsensitiveCompare:@"emi"] == NSOrderedSame){
        cell.preferredPaymentOption.text = @"EMI";
        cell.paymentImage.image = [UIImage imageNamed:@"coin.png"];
    }
    else if ([keyName caseInsensitiveCompare:@"rewards"] == NSOrderedSame){
        cell.preferredPaymentOption.text = @"Rewards";
        cell.paymentImage.image = [UIImage imageNamed:@"card.png"];
    }
    else if ([keyName caseInsensitiveCompare:@"cashcard"] == NSOrderedSame){
        cell.preferredPaymentOption.text = @"Cash Card";
        cell.paymentImage.image = [UIImage imageNamed:@"cash_card.png"];
    }
    else if ([keyName caseInsensitiveCompare:@"payumobey"] == NSOrderedSame){
        cell.preferredPaymentOption.text = @"PayU money";
        cell.paymentImage.image = [UIImage imageNamed:@"payu_money.png"];
    }
    else if ([keyName caseInsensitiveCompare:@"storedcards"] == NSOrderedSame){
        cell.preferredPaymentOption.text = @"Stored cards";
        cell.paymentImage.image = [UIImage imageNamed:@"store_card.png"];
    }
    else if ([keyName caseInsensitiveCompare:@"cod"] == NSOrderedSame){
        cell.preferredPaymentOption.text = @"Cash on delivery";
        cell.paymentImage.image = [UIImage imageNamed:@"store_card.png"];
    }
    else if ([keyName caseInsensitiveCompare:PARAM_PAYU_MONEY] == NSOrderedSame){
        cell.preferredPaymentOption.text = PARAM_PAYU_MONEY;
        cell.paymentImage.image = [UIImage imageNamed:@"payu_money.png"];
    }
    else{
        cell.preferredPaymentOption.text = keyName;
        cell.paymentImage.image = [UIImage imageNamed:@"card.png"];
    }
    
    return cell;
}

#pragma mark - TableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    switch (indexPath.row) {
        case 0:
            //Stored Card.
            [self loadAllStoredCard:(int)indexPath.row];
            break;
        case 1:
            //Credit Card.
            [self loadCCDCView:(int)indexPath.row];
            break;
        case 2:
            //Debit Card.
            [self loadCCDCView:(int)indexPath.row];
            break;
        case 3:
            [self loadAllInternetBankingOption];
            break;
        case 4:
            [self loadAllEMIOption];
            break;
        case 5:
            [self loadAllCashCardOption];
            break;
        case 6:
            [self payWithPayUMoney];
            break;
        case 7:
            [self payWithPayUMoney];
            break;
            
        default:
            break;
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
    
    NSString *postData = [NSString stringWithFormat:@"key=%@&var1=%@&command=%@&hash=%@",[[[SharedDataManager sharedDataManager] allInfoDict] objectForKey:PARAM_KEY],[[[SharedDataManager sharedDataManager] allInfoDict] objectForKey:PARAM_VAR1],_command,[Utils createCheckSumString:[NSString stringWithFormat:@"%@|%@|%@|%@",[[[SharedDataManager sharedDataManager] allInfoDict] objectForKey:PARAM_KEY],_command,[[[SharedDataManager sharedDataManager] allInfoDict] objectForKey:PARAM_VAR1],[[[SharedDataManager sharedDataManager] allInfoDict] objectForKey:PARAM_SALT]]]];
    
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

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
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
        NSLog(@"connectionDidFinishLoading");
        if(_connectionSpecificDataObject){
            NSError *errorJson=nil;
            _allPaymentOption = [NSJSONSerialization JSONObjectWithData:_connectionSpecificDataObject options:kNilOptions error:&errorJson];
            SharedDataManager *dataManager = [SharedDataManager sharedDataManager];
            dataManager.allPaymentOptionDict = _allPaymentOption;
            NSLog(@"responseDict=%@",_allPaymentOption);
            
            //sort available payment methods.
            [self sortBankOptionArray:_allPaymentOption.allKeys];
            
            [_preferredPaymentTable reloadData];
            _activityIndicator.hidden = YES;
            [_activityIndicator stopAnimating];
        }
        
    }
}

@end
