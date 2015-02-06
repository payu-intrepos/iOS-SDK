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

#define NET_BANKING             @"netbanking"
#define CASH_CARD               @"cashcard"

#define BANK_TITLE              @"title"
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
    
    _activityIndicator.hidden = NO;
    [_activityIndicator startAnimating];
    SharedDataManager *dataManager = [SharedDataManager sharedDataManager];
    dataManager.allInfoDict = [self createDictionaryWithAllParam];
    
    if(_totalAmount)
    _amountLbl.text = [NSString stringWithFormat:@"Rs. %.2f",_totalAmount];
    
    [self callAPI];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) sortBankOptionArray:(NSArray *)bankOption{
    _allPaymentMethodNameArray = [[NSMutableArray alloc] init];
    
    NSArray *names = [[NSArray alloc] initWithObjects:PARAM_STORE_CARD,PARAM_CREDIT_CARD,PARAM_DEBIT_CARD,PARAM_NET_BANKING,PARAM_EMI,PARAM_CASH_CARD, PARAM_CASH_ON_DILEVERY,PARAM_PAYU_MONEY,PARAM_REWARD,nil];
    
    for (NSString * name in names) {
        for (NSString *str in bankOption) {
            if ([str isEqualToString:name]) {
                [_allPaymentMethodNameArray addObject:str];
            }
        }
    }
    [_allPaymentMethodNameArray insertObject:PARAM_STORE_CARD atIndex:0];
    NSLog(@"All Key = %@ Sorted option = %@", bankOption, _allPaymentMethodNameArray);
}

- (void) loadAllStoredCard:(int) aFlag{
    
    if(0 == aFlag){
//        SharedDataManager *manager = [SharedDataManager sharedDataManager];
//        [manager.allInfoDict setValue:[NSString stringWithFormat:@"%@:%@",[manager.allInfoDict valueForKey:PARAM_KEY],[manager.allInfoDict valueForKey:PARAM_USER_CREDENTIALS]] forKey:PARAM_VAR1];
//        [manager.allInfoDict setValue:PARAM_GET_STORED_CARD forKey:PARAM_COMMAND];
        //NSLog(@"ALL INFO DICT = %@",manager.allInfoDict);
    }
    PayUStoredCardViewController *storedCard = [[PayUStoredCardViewController alloc] initWithNibName:@"PayUStoredCardViewController" bundle:nil];
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
    cardProcessCV.totalAmount = _totalAmount;
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
        return [item1[PARAM_BANK_CODE] compare:item2[PARAM_BANK_CODE] options:NSNumericSearch];
    }];
    NSLog(@"Sorted Bank = %@",listOfBankAvailableForNetBanking);
    
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
        [allParamDict setValue:_command forKey:PARAM_COMMAND];
    }
    else{
        exeption = [[NSException alloc] initWithName:@"Required Param missing" reason:@"KEY is not provided, this is one of required parameters." userInfo:nil];
        [exeption raise];
    }

    if(_transactionID){
        [allParamDict setValue:_transactionID forKey:PARAM_TXID];
    }
    if(_totalAmount){
        [allParamDict setValue:[NSNumber numberWithFloat:_totalAmount] forKey:PARAM_TOTAL_AMOUNT];
    }
    if(_productInfo){
        [allParamDict setValue:_productInfo forKey:PARAM_PRODUCT_INFO];
    }
    if(_firstName){
        [allParamDict setValue:_firstName forKey:PARAM_FIRST_NAME];
    }
    if(_lastName){
        [allParamDict setValue:_lastName forKey:PARAM_LAST_NAME];
    }
    if(_email){
        [allParamDict setValue:_email forKey:PARAM_EMAIL];
    }
    if(_phoneNumber){
        [allParamDict setValue:_phoneNumber forKey:PARAM_PHONE];
    }
    if(_address1){
        [allParamDict setValue:_address1 forKey:PARAM_ADDRESS_1];
    }
    if(_address2){
        [allParamDict setValue:_address2 forKey:PARAM_ADDRESS_2];
    }
    if(_city){
        [allParamDict setValue:_city forKey:PARAM_CITY];
    }
    if(_state){
        [allParamDict setValue:_state forKey:PARAM_STATE];
    }
    if(_country){
        [allParamDict setValue:_country forKey:PARAM_COUNTRY];
    }
    if(_zipcode){
        [allParamDict setValue:_zipcode forKey:PARAM_ZIPCODE];
    }
    if(_udf1){
        [allParamDict setValue:_udf1 forKey:PARAM_UDF_1];
    }
    if(_udf2){
        [allParamDict setValue:_udf2 forKey:PARAM_UDF_2];
    }
    if(_udf3){
        [allParamDict setValue:_udf3 forKey:PARAM_UDF_3];
    }
    if(_udf4){
        [allParamDict setValue:_udf4 forKey:PARAM_UDF_4];
    }
    if(_udf5){
        [allParamDict setValue:_udf5 forKey:PARAM_UDF_5];
    }
    if(_surl){
        [allParamDict setValue:_surl forKey:PARAM_SURL];
    }
    if(_curl){
        [allParamDict setValue:_curl forKey:PARAM_CURL];
    }
    if(_furl){
        [allParamDict setValue:_furl forKey:PARAM_FURL];
    }
    if(_hashKey){
        [allParamDict setValue:_hashKey forKey:PARAM_HASH];
    }
    if(_paymentCategory){
        [allParamDict setValue:_paymentCategory forKey:PARAM_PG];
    }
    if(_codeURL){
        [allParamDict setValue:_codeURL forKey:PARAM_CODURL];
    }
    if(_dropCategory){
        [allParamDict setValue:_dropCategory forKey:PARAM_DROP_CATEGORY];
    }
    if(_enforcePaymethod){
        [allParamDict setValue:_enforcePaymethod forKey:PARAM_ENFORCE_PAYMENT_HOD];
    }
    if(_customNote){
        [allParamDict setValue:_customNote forKey:PARAM_CUSTOM_NOTE];
    }
    if(_noteCategory){
        [allParamDict setValue:_noteCategory forKey:PARAM_NOTE_CATEGORY];
    }
    if(_shippingFirstName){
        [allParamDict setValue:_shippingFirstName forKey:PARAM_SHIPPING_FIRSTNAME];
    }
    if(_shippingLastName){
        [allParamDict setValue:_shippingLastName forKey:PARAM_SHIPPING_LASTNAME];
    }
    if(_shippingAddress1){
        [allParamDict setValue:_shippingAddress1 forKey:PARAM_ADDRESS_1];
    }
    if(_shippingAddress2){
        [allParamDict setValue:_shippingAddress2 forKey:PARAM_ADDRESS_2];
    }
    if(_shippingCity){
        [allParamDict setValue:_shippingCity forKey:PARAM_CITY];
    }
    if(_shippingState){
        [allParamDict setValue:_shippingState forKey:PARAM_STATE];
    }
    if(_shippingCountry){
        [allParamDict setValue:_shippingCountry forKey:PARAM_ADDRESS_2];
    }
    if(_shippingZipcode){
        [allParamDict setValue:_shippingZipcode forKey:PARAM_SHIPPING_ZIPCODE];
    }
    if(_shippingPhoneNumber){
        [allParamDict setValue:_shippingPhoneNumber forKey:PARAM_SHIPPING_PHONE];
    }
    if(_offerKey){
        [allParamDict setValue:_offerKey forKey:PARAM_OFFER_KEY];
    }
    
    // user credentails
    if(_userCredentials){
        [allParamDict setValue:_userCredentials forKey:PARAM_USER_CREDENTIALS];
    }
    
    
    
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
            //Debit Card.
            [self loadCCDCView:(int)indexPath.row];
            break;
        case 2:
            //Credit Card.
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
            [self loadCCDCView:(int)indexPath.row];
            break;
        default:
            break;
    }
}


#pragma mark - Web Services call by NSURLConnection
// Connection Request.
-(void) callAPI{
    NSURL *restURL = [NSURL URLWithString:PAYU_PAYMENT_ALL_AVAILABLE_PAYMENT_OPTION_TEST];
    
    
    // create the request
    NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:restURL
                                                            cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                        timeoutInterval:60.0];
    // Specify that it will be a POST request
    theRequest.HTTPMethod = @"POST";
    
    NSString *postData = [NSString stringWithFormat:@"key=%@&var1=%@&command=%@&hash=%@&drop_category=%@",_key,_var1,_command,[Utils createCheckSumString:[NSString stringWithFormat:@"%@|%@|%@|%@",_key,_command,_var1,_salt]],@"DC|CC"];
    
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
