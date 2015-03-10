//
//  PayUInternetBankingViewController.m
//  PayU_iOS_SDK
//
//  Created by Suryakant Sharma on 05/01/15.
//  Copyright (c) 2015 PayU, India. All rights reserved.
//

#import "PayUInternetBankingViewController.h"
#import "PayUConstant.h"
#import "Utils.h"
#import "PayUPaymentResultViewController.h"
#import "SharedDataManager.h"

#define PG_TYPE @"NB"
#define BANK_CODE @"bankcode"

@interface PayUInternetBankingViewController () <UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,unsafe_unretained) IBOutlet UIButton *selectBank;
@property(nonatomic,unsafe_unretained) IBOutlet UIButton *payNow;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (nonatomic,strong) IBOutlet UILabel *amountLbl;


@property(nonatomic,unsafe_unretained) IBOutlet UIView *containerView;
@property(nonatomic,strong) UITableView *listOfBank;

@property (nonatomic,strong) NSURLConnection *connection;
@property (nonatomic,strong) NSMutableData *connectionSpecificDataObject;
@property (nonatomic,strong) NSMutableData *receivedData;

@property (nonatomic,assign) NSUInteger selectedBankIndex;

@property (nonatomic,strong) NSMutableDictionary *allPaymentOption;


- (IBAction) payNow :(UIButton *)sender;

@end

@implementation PayUInternetBankingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _payNow.enabled = NO;
    _payNow.layer.cornerRadius = 10.0f;
    _selectedBankIndex = -1;
    
    SharedDataManager *manager = [SharedDataManager sharedDataManager];
    // Stored card option will be dislpayed if user_credentials has been provided.
    NSDictionary *paramDict = [[SharedDataManager sharedDataManager] allInfoDict];
    if(0 == paramDict.allKeys.count){
        manager.allInfoDict = [self createDictionaryWithAllParam];
    }
    _amountLbl.text = [NSString stringWithFormat:@"Rs. %.2f",[[paramDict objectForKey:PARAM_TOTAL_AMOUNT] floatValue]];
    
    CGSize result = [[UIScreen mainScreen] bounds].size;
    if(result.height == IPHONE_3_5)
    {
        _selectBank.titleLabel.font = [UIFont systemFontOfSize:15];

    }
 
    if(!_bankDetails){
        [self callAPI];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction) selectBank :(UIButton *)sender{
    
    if(nil == _listOfBank){
        _listOfBank = [[UITableView alloc] initWithFrame:CGRectMake(_selectBank.frame.origin.x, _selectBank.frame.origin.y, _selectBank.frame.size.width, _selectBank.frame.size.height*5) style:UITableViewStylePlain];
        
        _listOfBank.backgroundColor = [UIColor colorWithRed:240.0/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:1.0f];
        _listOfBank.dataSource = self;
        _listOfBank.delegate   = self;
    }
    _listOfBank.alpha = 0.0f;
    
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        _listOfBank.alpha = 1.0f;
        [self.containerView addSubview:_listOfBank];
        
    } completion:^(BOOL finished) {
        
    }];
}

- (IBAction)payNow:(UIButton *)sender{
    
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
    //    for(NSString *aKey in [paramDict allKeys]){
    //        [postData appendFormat:@"%@=%@",aKey,[paramDict valueForKey:aKey]];
    //        [postData appendString:@"&"];
    //    }
    
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
    
    if([_bankDetails[_selectedBankIndex] objectForKey:PARAM_BANK_CODE]){
        [postData appendFormat:@"%@=%@",PARAM_BANK_CODE,[_bankDetails[_selectedBankIndex] objectForKey:PARAM_BANK_CODE]];
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
    
    PayUPaymentResultViewController *resultViewController = [[PayUPaymentResultViewController alloc] initWithNibName:@"PayUPaymentResultViewController" bundle:nil];
    resultViewController.request = theRequest;
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

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        _listOfBank.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [_listOfBank removeFromSuperview];
    }];
    
}
-(void) extractAllInternetBankingOption{
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
    
    _bankDetails = listOfBankAvailableForNetBanking;
    
}

-(NSDictionary *) createDictionaryWithAllParam{
    
    NSMutableDictionary *allParamDict = [[NSMutableDictionary alloc] init];
    NSException *exeption = nil;
    
    if([[NSBundle mainBundle] objectForInfoDictionaryKey:PARAM_VAR1]){
        [allParamDict setValue:[[NSBundle mainBundle] objectForInfoDictionaryKey:PARAM_VAR1] forKey:PARAM_VAR1];
    }
    else{
        exeption = [[NSException alloc] initWithName:@"Required Param missing" reason:@"VAR1 is not provided, this is one of required parameters." userInfo:nil];
        [exeption raise];
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
        [allParamDict setValue:[[NSBundle mainBundle] objectForInfoDictionaryKey:PARAM_COMMAND] forKey:PARAM_COMMAND];
    }
    else{
        exeption = [[NSException alloc] initWithName:@"Required Param missing" reason:@"COMMAND is not provided, this is one of required parameters." userInfo:nil];
        [exeption raise];
    }
    
    [allParamDict addEntriesFromDictionary:_parameterDict];
    
    
    NSLog(@"ALL PARAM DICT =%@",allParamDict);
    return allParamDict;
}


#pragma mark - Web Services call by NSURLConnection

// Connection Request.
-(void) callAPI{
    
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
    
    
    // create the connection with the request
    // and start loading the data
    _connection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    if (_connection) {
        _receivedData=[NSMutableData data];
    } else {
        // inform the user that the download could not be made
    }
    [_connection start];
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _activityIndicator.center=self.view.center;
    [_activityIndicator startAnimating];
    _activityIndicator.hidden = NO;
    
    [self.view addSubview:_activityIndicator];
    
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
            [self extractAllInternetBankingOption];
            _activityIndicator.hidden = YES;
            [_activityIndicator stopAnimating];
            [_activityIndicator removeFromSuperview];
            _activityIndicator = nil;
        }
        
    }
}


#pragma mark - TableView DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _bankDetails.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellIdentifier = @"cellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text = [[_bankDetails objectAtIndex:indexPath.row] valueForKey:@"title"];
    
    return cell;
}

#pragma mark - TableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    _payNow.enabled = YES;
    _payNow.backgroundColor = [UIColor colorWithRed:89.0/255.0 green:193/255.0 blue:0 alpha:1];
    _selectedBankIndex = indexPath.row;
    NSLog(@"didSelectRowAtIndexPath");
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        _listOfBank.alpha = 0.0f;
        [_selectBank setTitle:[[_bankDetails objectAtIndex:indexPath.row] valueForKey:@"title"] forState:UIControlStateNormal];
    } completion:^(BOOL finished) {
        [_listOfBank removeFromSuperview];
    }];
    
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor colorWithRed:240.0/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:1.0f];
}



@end
