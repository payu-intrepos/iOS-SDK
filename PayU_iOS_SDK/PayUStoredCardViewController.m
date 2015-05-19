//
//  PayUStoredCardViewController.m
//  PayU_iOS_SDK
//
//  Created by Suryakant Sharma on 23/12/14.
//  Copyright (c) 2014 PayU, India. All rights reserved.
//

#import "PayUStoredCardViewController.h"
#import "PayUConstant.h"
#import "SharedDataManager.h"
#import "Utils.h"
#import "PayUPaymentResultViewController.h"
#import "PayUCardProcessViewController.h"

#define USER_CARD       @"user_cards"
#define CARD_NUMBER     @"card_no"
#define CARD_NAME       @"card_name"
#define CARD_TOKEN      @"card_token"

@interface PayUStoredCardViewController () <UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UIActionSheetDelegate>

@property (nonatomic,strong) NSURLConnection *connection;
@property (nonatomic,strong) NSURLConnection *connectionForDeletingCard;

@property (nonatomic,strong) NSMutableData *connectionSpecificDataObject;
@property (nonatomic,strong) NSMutableData *receivedData;
@property (nonatomic,strong) NSMutableDictionary *allStoredCards;
@property (nonatomic,strong) NSMutableArray *cardList;
@property (unsafe_unretained, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *amountLbl;

@property (unsafe_unretained, nonatomic) IBOutlet UIView  *containerView;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *addNewCard;
@property (unsafe_unretained, nonatomic) IBOutlet UITableView *storedCardTableView;
@property (strong, nonatomic) UILabel *noCardFoundLbl;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *msgLbl;

@property (nonatomic,assign) NSUInteger selectedCardNumber;
@property (nonatomic,assign) NSUInteger cardToDelete;

@property (nonatomic,strong) UIButton *dismissButton;
@property (nonatomic,strong) UIButton *okButton;
@property (nonatomic,strong) UITextField *cvvTextField;
@property (unsafe_unretained, nonatomic) int cvvlength;

@property (unsafe_unretained, nonatomic) IBOutlet UIButton *useNewCardBtn;

-(void) getStoredCard;
-(void) makePaymentWithSelectedStoredCard:(NSString *)cvvStr;
-(IBAction) makePaymentWIthNewCard :(UIButton *) newCardBtn;

-(void) hideShowTableView:(BOOL) aFlag;

@end

@implementation PayUStoredCardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [_addNewCard setBackgroundColor:[UIColor colorWithRed:89.0/255.0 green:193/255.0 blue:0 alpha:1]];
    _addNewCard.layer.cornerRadius = 10.0f;
    _storedCardTableView.dataSource = self;
    _storedCardTableView.delegate   = self;
    
    
    _storedCardTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _storedCardTableView.backgroundView = nil;
    
    _storedCardTableView.layer.borderColor = [UIColor redColor].CGColor;
    
    SharedDataManager *sharedManager = [SharedDataManager sharedDataManager];
    
    if(sharedManager.storedCard)
    {
        _allStoredCards = [NSMutableDictionary dictionaryWithDictionary:sharedManager.storedCard];
        
        [self listAllStoredCard];
        if(_cardList.count > 0){
            [self hideShowTableView:YES];
            [_storedCardTableView reloadData];
        }
        else{
            [self hideShowTableView:NO];
        }
        
    }else{
        _activityIndicator.center=self.view.center;
        [_activityIndicator startAnimating];
        [self getStoredCard];
    }

    _amountLbl.text = [NSString stringWithFormat:@"Rs. %.2f",[[[[SharedDataManager sharedDataManager] allInfoDict] objectForKey:PARAM_TOTAL_AMOUNT] floatValue]];

}

- (void) viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) listAllStoredCard{
    NSDictionary *allCard = [_allStoredCards objectForKey:USER_CARD];
    if(allCard){
        if(!_cardList){
            _cardList = [[NSMutableArray alloc] init];
        }
        for(NSString *aKey in allCard){
            [_cardList addObject:[allCard objectForKey:aKey]];
        }
    }
}

-(void) getStoredCard{
    
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
    
    
    NSMutableString *postData = [[NSMutableString alloc] init];
    for(NSString *aKey in [paramDict allKeys]){
        [postData appendFormat:@"%@=%@",aKey,[paramDict valueForKey:aKey]];
        [postData appendString:@"&"];
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

// custom alert view for CVV.
- (void)displayCustomAlert
{
    UIView *customAlertView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300,150)];
    [customAlertView setBackgroundColor:[UIColor whiteColor]];
    [customAlertView setAlpha:0.0f];
    customAlertView.layer.cornerRadius = 0.0f;
    customAlertView.layer.cornerRadius = 8;
    customAlertView.layer.masksToBounds = YES;
    customAlertView.backgroundColor = [UIColor lightGrayColor];
    
    _dismissButton = [UIButton buttonWithType:UIButtonTypeSystem];
//    _dismissButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 109, 150, 40)];
    _dismissButton.frame = CGRectMake(0, 109, 150, 40);
    //[_dismissButton setFrame:CGRectMake(0, 109, 150, 40)];
    [_dismissButton setTitle:@"Cancel" forState:UIControlStateNormal];
    _dismissButton.layer.borderColor = [UIColor whiteColor].CGColor;
    _dismissButton.layer.borderWidth = 0.5f;
    [_dismissButton addTarget:self action:@selector(customAlertViewButtonClicked:) forControlEvents:UIControlEventTouchUpInside];

    [customAlertView addSubview:_dismissButton];
    
    _okButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_okButton setTitle:@"Ok" forState:UIControlStateNormal];
    [_okButton setFrame:CGRectMake(150, 109, 150, 40)];
    [_okButton addTarget:self action:@selector(customAlertViewButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    _okButton.layer.borderColor = [UIColor whiteColor].CGColor;
    _okButton.layer.borderWidth = 0.5f;
    
    if ([[_cardList[_selectedCardNumber] objectForKey:@"card_brand"] isEqualToString:@"MAESTRO"]){
            _okButton.enabled = YES;
    } else{
        _okButton.enabled = NO;
    }
    
    [customAlertView addSubview:_okButton];
    
    UILabel *msgLbl = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 260,25)];
    msgLbl.text = @"Enter cvv";
    msgLbl.textAlignment = NSTextAlignmentCenter;
    [customAlertView addSubview:msgLbl];
    
    
    _cvvTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 55, 260, 30)];
    [_cvvTextField setBorderStyle:UITextBorderStyleRoundedRect];
    _cvvTextField.placeholder = @"CVV";
    _cvvTextField.keyboardType = UIKeyboardTypeNumberPad;
    _cvvTextField.secureTextEntry = YES;
    _cvvTextField.delegate = self;
    [customAlertView addSubview:_cvvTextField];
    
    customAlertView.center = self.view.center;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        CGSize result = [[UIScreen mainScreen] bounds].size;
        if(result.height == IPHONE_3_5)
        {
            CGRect frame = customAlertView.frame;
            frame.origin.y = frame.origin.y - 50;
            customAlertView.frame = frame;
        }
    }
    
    [self.view addSubview:customAlertView];
    
    [UIView animateWithDuration:0.2f animations:^{
        [customAlertView setAlpha:1.0f];
    }];
}

// Custom AlertView button get clicked.
- (void)customAlertViewButtonClicked:(UIButton *)sender
{
    [_cvvTextField  resignFirstResponder];
    [UIView animateWithDuration:0.2f animations:^{
        [sender.superview setAlpha:0.0f];
    }completion:^(BOOL done){
        [sender.superview removeFromSuperview];
    }];
    [_storedCardTableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:_selectedCardNumber inSection:0] animated:YES];
    
    if([sender isEqual:_okButton]){
        NSString *cvvStr = _cvvTextField.text;
        if([[_cardList[_selectedCardNumber] objectForKey:@"card_brand"] isEqualToString:@"MAESTRO"])
        {
            cvvStr = @"999";
        }
        NSLog(@"Pay With CVV =%@",cvvStr);
        [self makePaymentWithSelectedStoredCard:cvvStr];
    }
    else{
        _useNewCardBtn.enabled = YES;
        _storedCardTableView.userInteractionEnabled = YES;
    }
    
}

-(void) makePaymentWithSelectedStoredCard:(NSString *)cvvStr {
    
    _storedCardTableView.userInteractionEnabled = YES;
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
        if(/*!([aKey isEqualToString:PARAM_SALT]) && */!([aKey isEqualToString:PARAM_FIRST_NAME])){
            [postData appendFormat:@"%@=%@",aKey,[paramDict valueForKey:aKey]];
            [postData appendString:@"&"];
        }
    }
    
    NSDictionary *selectedStoredCardDict = _cardList[_selectedCardNumber];
    
    if([selectedStoredCardDict objectForKey:@"card_type"]){
        [postData appendFormat:@"%@=%@",PARAM_PG,[selectedStoredCardDict objectForKey:@"card_type"]];
        [postData appendString:@"&"];
    }
    //    if([selectedStoredCardDict objectForKey:@"card_type"]){
    //        [postData appendFormat:@"%@=%@",PARAM_PG,[selectedStoredCardDict objectForKey:@"card_type"]];
    //        [postData appendString:@"&"];
    //    }
    if([selectedStoredCardDict objectForKey:@"card_token"]){
        [postData appendFormat:@"%@=%@",PARAM_CARD_TOKEN,[selectedStoredCardDict objectForKey:@"card_token"]];
        [postData appendString:@"&"];
    }
    //user_credentials name_on_card
    if([selectedStoredCardDict objectForKey:@"name_on_card"]){
        [postData appendFormat:@"%@=%@",PARAM_FIRST_NAME,[selectedStoredCardDict objectForKey:@"name_on_card"]];
        [postData appendString:@"&"];
    }
    if(cvvStr){
        [postData appendFormat:@"%@=%@",PARAM_CARD_CVV,cvvStr];
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
    // create the connection with the request
    // and start loading the data
    /* _connection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
     if (_connection) {
     _receivedData=[NSMutableData data];
     } else {
     // inform the user that the download could not be made
     }
     [_connection start];*/
    
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

-(IBAction) makePaymentWIthNewCard :(UIButton *) newCardBtn{
    
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
    if(_appTitle){
        cardProcessCV.appTitle = _appTitle;
    }
    cardProcessCV.storeThisCard = YES;
    [self.navigationController pushViewController:cardProcessCV animated:YES];
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if(2 != buttonIndex){
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
        if(_appTitle){
            cardProcessCV.appTitle = _appTitle;
        }
        
        cardProcessCV.CCDCFlag = (int)buttonIndex+1;
        cardProcessCV.storeThisCard = YES;
        [self.navigationController pushViewController:cardProcessCV animated:YES];
    }
}

-(void) hideShowTableView:(BOOL) aFlag{
    _storedCardTableView.hidden = !aFlag;
    _msgLbl.hidden = !aFlag;
    
    if(!aFlag){
        _noCardFoundLbl = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2-(120/2),((_containerView.frame.size.height/2)-35), 150, 21)];
        _noCardFoundLbl.textColor = [UIColor lightGrayColor];
        _noCardFoundLbl.text = @"No Card Found!";
        [_containerView addSubview:_noCardFoundLbl];
    }
}

- (void) deleteStoredCard :(NSInteger)cardNun{
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
    
    
    NSMutableString *postData = [[NSMutableString alloc] init];
    [postData appendFormat:@"%@=%@",PARAM_KEY,[paramDict valueForKey:PARAM_KEY]];
    [postData appendString:@"&"];
    
    [postData appendFormat:@"%@=%@",PARAM_DEVICE_TYPE,IOS_SDK];
    [postData appendString:@"&"];
    
    [postData appendFormat:@"%@=%@",PARAM_COMMAND,PARAM_DELETE_STORED_CARD];
    [postData appendString:@"&"];
    
    [postData appendFormat:@"%@=%@",PARAM_VAR1,[paramDict valueForKey:PARAM_VAR1]];
    [postData appendString:@"&"];
    
    [postData appendFormat:@"%@=%@",PARAM_VAR2,[_cardList[cardNun] objectForKey:CARD_TOKEN]];
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
    NSLog(@"STORED CARD POST DATA = %@",postData);
    //set request content type we MUST set this value.
    [theRequest setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    //set post data of request
    [theRequest setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
    // create the connection with the request
    // and start loading the data
    _connectionForDeletingCard = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    if (_connectionForDeletingCard) {
        _receivedData=[NSMutableData data];
    } else {
        // inform the user that the download could not be made
    }
    [_connectionForDeletingCard start];

}

#pragma mark - TableView DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _cardList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellIdentifier = @"cellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        //cell.backgroundColor = [UIColor colorWithRed:240.0f green:240.0f blue:240.0f alpha:1.0f];
    }
    cell.textLabel.text =  [_cardList[indexPath.row] objectForKey:CARD_NUMBER];
    cell.detailTextLabel.text = [_cardList[indexPath.row] objectForKey:CARD_NAME];
    return cell;
}

#pragma mark - TableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    _selectedCardNumber = indexPath.row;
    _useNewCardBtn.enabled = NO;
    _storedCardTableView.userInteractionEnabled = NO;
    if([[_cardList[indexPath.row] objectForKey:@"card_brand"] isEqualToString:@"AMEX"]){
        _cvvlength = 4;
    }
    else if ([[_cardList[indexPath.row] objectForKey:@"card_brand"] isEqualToString:@"MAESTRO"]){
        
        _cvvlength = 3;
        if([[SharedDataManager sharedDataManager] isSBIMaestro:[_cardList[indexPath.row] objectForKey:@"card_bin"]])
            NSLog(@"It is SBI Maestro with no CVV");
        _cvvlength = 3;
    }
    else{
        _cvvlength = 3;
    }
    [self displayCustomAlert];
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor colorWithRed:240.0/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:1.0f];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        _cardToDelete = indexPath.row;
        [self deleteStoredCard:_cardToDelete];
    }
    
    
    [tableView reloadData];
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return YES;
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
    else if (connection == _connectionForDeletingCard){
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
            _allStoredCards = [NSJSONSerialization JSONObjectWithData:_connectionSpecificDataObject options:kNilOptions error:&errorJson];
            NSLog(@"responseDict=%@ error = %@",_allStoredCards,errorJson);
            [self listAllStoredCard];
            if(_cardList.count > 0){
                [self hideShowTableView:YES];
                [_storedCardTableView reloadData];
            }
            else{
                [self hideShowTableView:NO];
            }
        }
    }
    else
    if(connection == _connectionForDeletingCard){
        if(_connectionSpecificDataObject){
            NSError *errorJson=nil;
            NSLog(@"_Coonection Deleting SpecificDataObject=%@",_connectionSpecificDataObject);
            _allStoredCards = [NSJSONSerialization JSONObjectWithData:_connectionSpecificDataObject options:kNilOptions error:&errorJson];
            NSLog(@"responseDict=%@",_allStoredCards);
            if(1 == [[_allStoredCards objectForKey:@"status"] integerValue]){
               [_cardList removeObjectAtIndex:_cardToDelete];
               [_storedCardTableView reloadData];
            }
        }
    }
    [_activityIndicator stopAnimating];
}

#pragma mark - UITextField Delegate methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    BOOL shouldChangeCharacters = YES;
    if (textField.text.length == _cvvlength && ![string isEqualToString:@""])
        return NO;
    
    //NSString *cvv = [NSString stringWithFormat:@"%@%@",textField.text,string];
    NSString *cvv = nil;
    if([string isEqualToString:@""]){
        cvv = [textField.text substringToIndex:textField.text.length-1];
    }
    else{
        cvv  = [NSString stringWithFormat:@"%@%@",textField.text,string];
    }
    NSLog(@"CVV code = %@",cvv);
    if(_cvvlength == cvv.length && ![string isEqualToString:@""]){
        _okButton.enabled = YES;
    }
    else if([string isEqualToString:@""]){
        _okButton.enabled = NO;
    }
    return shouldChangeCharacters;
}
@end
