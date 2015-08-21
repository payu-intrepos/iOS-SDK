//
//  PayUEMIOptionViewController.m
//  PayU_iOS_SDK
//
//  Created by Suryakant Sharma on 14/01/15.
//  Copyright (c) 2015 PayU, India. All rights reserved.
//

#import "PayUEMIOptionViewController.h"
#import "PayUPaymentResultViewController.h"
#import "Utils.h"
#import "SharedDataManager.h"
#import "PayUConstant.h"
#import "CardValidation.h"

#define BANK_TABLEVIEW_TAG 100
#define EMI_TABLEVIEW_TAG  200
#define TABLEVIEW_CELL_HEIGHT 44

#define EMI_BUTTON_TITLE @"Select EMI Duration"

#define DEBIT_CARD   @"Please enter debit card details"
#define CREDIT_CARD  @"Please enter credit card details"

#define ALPHA_HALF   0.5
#define ALPHA_FULL   1.0

#define CARD_TYPE_CC @"CC"
#define CARD_TYPE_DC @"DC"

#define MAX_DIGIT_CARD_NUMBER 19
#define MAX_CHAR_CARD_NAME 29


@interface PayUEMIOptionViewController () <UITableViewDataSource,UITableViewDelegate,UIPickerViewDelegate,UIPickerViewDataSource,UITextFieldDelegate>

@property(nonatomic,unsafe_unretained) IBOutlet UIButton *selectBank;
@property(nonatomic,unsafe_unretained) IBOutlet UIButton *selectEMITime;

@property(nonatomic,unsafe_unretained) IBOutlet UIButton *payNow;

@property(nonatomic,unsafe_unretained) IBOutlet UIView *containerView;
@property(nonatomic,strong) UITableView *listOfEMIBank;

@property (strong, nonatomic) NSDateComponents* currentDateComponents;


@property (nonatomic,strong) NSURLConnection *connection;
@property (nonatomic,strong) NSMutableData *connectionSpecificDataObject;
@property (nonatomic,strong) NSMutableData *receivedData;

@property (nonatomic,assign) NSUInteger selectedBankIndex;

@property (nonatomic,assign) BOOL isBankTableOnScreen;
@property (nonatomic,assign) BOOL isBankForEMISelected;
@property (nonatomic,assign) BOOL isTimeForEMISelected;



@property (nonatomic,strong) NSMutableDictionary *bankEmiOption;
@property (nonatomic,strong) NSMutableArray *emiMonths;
@property (nonatomic,strong) NSMutableArray *emiBank;


@property (nonatomic,assign) NSUInteger numberOfRow;

@property (nonatomic,strong) IBOutlet UILabel *amountLbl;

@property (unsafe_unretained, nonatomic) IBOutlet UILabel *viewTitle;
@property (strong, nonatomic) UIPickerView *datePicker;
@property (strong, nonatomic) UIView *datePickerContainerView;
@property (strong, nonatomic) NSMutableArray *years;
@property (strong, nonatomic) NSMutableArray *months;

@property (nonatomic,assign) NSInteger expMonth;
@property (nonatomic,assign) NSInteger expYear;
@property (nonatomic,assign) BOOL isDatePickerOnScreen;

@property (nonatomic,assign) BOOL isCardNumberValid;
@property (nonatomic,assign) BOOL isNameOnCardValid;
@property (nonatomic,assign) BOOL isExpiryDateValid;
@property (nonatomic,assign) BOOL isCvvNumberValid;
@property (nonatomic,assign) BOOL isBankSelected;
@property (nonatomic,assign) BOOL isEMIPeriodSelected;
@property (nonatomic,assign) BOOL isCardBrandDetected;

@property (nonatomic,assign) BOOL isCardSBIMestro;

@property (strong, nonatomic) UILabel *msgLbl;
@property (strong, nonatomic) UIButton *button;


//Card details
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *cardNumber;
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *ccImageView;
@property (nonatomic,copy) NSString *cardNum;

@property (unsafe_unretained, nonatomic) IBOutlet UITextField *nameOnCard;
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *userImageView;
@property (nonatomic,copy) NSString *cardName;


@property (unsafe_unretained, nonatomic) IBOutlet UIButton *cardExpiryDate;
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *calenderImageView;


@property (unsafe_unretained, nonatomic) IBOutlet UITextField *cardCVV;
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *cvvImageView;
@property (nonatomic,copy) NSString *cvvNum;

@property (nonatomic,assign) CGPoint originalCenter;

- (IBAction) payNow :(UIButton *)sender;
-(IBAction) displayDatePicketView :(UIPickerView *) pickerView;


@property (assign,nonatomic) NSInteger cvvLength;

@end

@implementation PayUEMIOptionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _cvvLength = 3;
    _selectEMITime.enabled = NO;
    _months = nil;
    _years  = nil;
    
    _isCardNumberValid = NO;
    _isCvvNumberValid  = NO;
    _isExpiryDateValid = NO;
    _isNameOnCardValid = YES;
    _isCardSBIMestro   = NO;
    _isCardBrandDetected = NO;
    
    
    _originalCenter = self.view.center;
    
    _cardNumber.delegate = self;
    _nameOnCard.delegate = self;
    _cardCVV.delegate = self;
    
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        CGSize result = [[UIScreen mainScreen] bounds].size;
        if(result.height == IPHONE_3_5)
        {
            _payNow.layer.cornerRadius = 7.0f;
        }
        else
        {
            _payNow.layer.cornerRadius = 10.0f;
            
        }
    }
    
    
    [self extractAllBankAndEMIOptions];
    
    _amountLbl.text = [NSString stringWithFormat:@"Rs. %.2f",[[[[SharedDataManager sharedDataManager] allInfoDict] objectForKey:PARAM_TOTAL_AMOUNT] floatValue]];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) payNow :(UIButton *)sender{
    
    if (_connectionSpecificDataObject){
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
        
        /*if(([aKey isEqualToString:PARAM_FIRST_NAME]) || ([aKey isEqualToString:PARAM_EMAIL])){
            
            [postData appendFormat:@"%@=%@",aKey,@""];
            [postData appendString:@"&"];
            
        }
        else */if(![aKey isEqualToString:PARAM_SALT]){
            [postData appendFormat:@"%@=%@",aKey,[paramDict valueForKey:aKey]];
            [postData appendString:@"&"];
        }

    }
    if([paramDict objectForKey:PARAM_OFFER_KEY]){
        [postData appendFormat:@"%@=%@",PARAM_OFFER_KEY,[paramDict objectForKey:PARAM_OFFER_KEY]];
        [postData appendString:@"&"];
    }
    
    if(_paymentCategory){
        [postData appendFormat:@"%@=%@",PARAM_PG,_paymentCategory];
        [postData appendString:@"&"];
    }
    if(_cardNumber.text){
        [postData appendFormat:@"%@=%@",PARAM_CARD_NUMBER,_cardNumber.text];
        [postData appendString:@"&"];
    }
    if(0 != _nameOnCard.text.length){
        [postData appendFormat:@"%@=%@",PARAM_CARD_NAME,_nameOnCard.text];
        [postData appendString:@"&"];
    }
    else{
        [postData appendFormat:@"%@=%@",PARAM_CARD_NAME,@"PAYU"];
        [postData appendString:@"&"];
    }
    if(_cardCVV.text){
        [postData appendFormat:@"%@=%@",PARAM_CARD_CVV,_cardCVV.text];
        [postData appendString:@"&"];
    } else{
        [postData appendFormat:@"%@=%@",PARAM_CARD_CVV,@"999"];
        [postData appendString:@"&"];
    }
    if(_expMonth){
        [postData appendFormat:@"%@=%ld",PARAM_CARD_EXPIRY_MONTH,(long)_expMonth];
        [postData appendString:@"&"];
    }
    else{
        /*
         sending some value in case of maestro card, that doen't have CVV and expiry no.
         */
        [postData appendFormat:@"%@=%@",PARAM_CARD_EXPIRY_MONTH,@"05"];
        [postData appendString:@"&"];
    }
    if(_expYear){
        [postData appendFormat:@"%@=%ld",PARAM_CARD_EXPIRY_YEAR,(long)_expYear];
        [postData appendString:@"&"];
    }
    else{
        [postData appendFormat:@"%@=%@",PARAM_CARD_EXPIRY_YEAR,@"2027"];
        [postData appendString:@"&"];
    }


    [postData appendFormat:@"%@=%@",PARAM_BANK_CODE,@"CC"];
    [postData appendString:@"&"];
    [postData appendFormat:@"%@=%@",PARAM_DEVICE_TYPE,IOS_SDK];
    [postData appendString:@"&"];
    
    
    //checksum calculation.
    NSString *checkSum = nil;
    if(!HASH_KEY_GENERATION_FROM_SERVER){

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
        checkSum = [Utils createCheckSumString:hashValue];
        NSLog(@"Hash String = %@ hashvalue = %@",hashValue,checkSum);

    }
    else
    {
        if ([[[SharedDataManager sharedDataManager] hashDict] valueForKey:PAYMENT_HASH_OLD]) {
            checkSum = [[[SharedDataManager sharedDataManager] hashDict] valueForKey:PAYMENT_HASH_OLD];
        } else {
            checkSum = [[[SharedDataManager sharedDataManager] hashDict] valueForKey:PAYMENT_HASH];
        }
    }
    
//    NSLog(@"Hash String = %@ hashvalue = %@",hashValue,[Utils createCheckSumString:hashValue]);
    [postData appendFormat:@"%@=%@",PARAM_HASH,checkSum];
    //sha512(key|txnid|amount|productinfo|firstname|email|udf1|udf2|udf3|udf4|udf5||||||SALT)
    NSLog(@"POST DATA = %@",postData);
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

-(void) extractAllBankAndEMIOptions{
    
    _bankEmiOption = [[NSMutableDictionary alloc] init];
    for(NSDictionary *dict in _emiDetails){
        NSMutableDictionary *aDict1 = [[NSMutableDictionary alloc] initWithDictionary:dict];
        NSMutableDictionary *tempDict = [_bankEmiOption objectForKey:[aDict1 objectForKey:@"bank"]];
        if(tempDict){
            if([tempDict objectForKey:@"title"]){
                if(![tempDict objectForKey:@"title1"]){
                    [tempDict setValue:[aDict1 objectForKey:@"title"] forKey:@"title1"];
                }
                else if(![tempDict objectForKey:@"title2"]){
                    [tempDict setValue:[aDict1 objectForKey:@"title"] forKey:@"title2"];
                }
                else if(![tempDict objectForKey:@"title3"]){
                    [tempDict setValue:[aDict1 objectForKey:@"title"] forKey:@"title3"];
                }
            }
        }
        else{
            [_bankEmiOption setValue:aDict1 forKey:[dict objectForKey:@"bank"]];
        }
    }
    NSLog(@"aDict == %@",_bankEmiOption);
    _emiBank = nil;
    _emiBank = [[NSMutableArray alloc] initWithArray:[_bankEmiOption.allKeys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
    
}

- (void) extractEmiMonthsForBank{
    _emiMonths = [[NSMutableArray alloc] init];
    NSString *bankName = _emiBank[_selectedBankIndex];
    NSLog(@"Selected Bank Name : %@",bankName);
    for(NSString *akey in [[_bankEmiOption objectForKey:bankName] allKeys]){
        if([akey isEqualToString:@"title"] || [akey isEqualToString:@"title1"] || [akey isEqualToString:@"title2"] || [akey isEqualToString:@"title3"]){
            [_emiMonths addObject:[[_bankEmiOption objectForKey:bankName] objectForKey:akey]];
            NSLog(@"Month Key : %@ AND VALUE = %@",akey,[[_bankEmiOption objectForKey:bankName] objectForKey:akey]);
        }
    }
    _emiMonths = [[NSMutableArray alloc] initWithArray:[_emiMonths sortedArrayUsingComparator:^(NSString *str1, NSString *str2) {
        return [str1 compare:str2 options:NSNumericSearch];
    }]];
    NSLog(@"Months Key for selected Bank: %@",_emiMonths);
}

-(IBAction) displayDatePicketView :(UIPickerView *) pickerView{
    
    _cardExpiryDate.enabled = NO;
    _isExpiryDateValid = NO;
    _currentDateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    
    _expYear = [_currentDateComponents year];
    _expMonth = [_currentDateComponents month]+1;
    
    //Array for picker view
    _months=[[NSMutableArray alloc]initWithObjects:@"01",@"02",@"03",@"04",@"05",@"06",@"07",@"08",@"09",@"10",@"11",@"12",nil];
    _years=[[NSMutableArray alloc]init];
    NSString *yearString = [NSString stringWithFormat:@"%ld",(long)[_currentDateComponents year]];
    
    for (int i=0; i<13; i++)
    {
        [_years addObject:[NSString stringWithFormat:@"%d",[yearString intValue]+i]];
    }
    
    _datePicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 44, self.view.frame.size.width, 180)];
    _datePicker.delegate = self;
    //_datePicker.dataSource = self;
    _datePicker.showsSelectionIndicator = YES;
    _datePicker.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1.0f];
    [_datePicker selectRow:[_currentDateComponents month] inComponent:0 animated:YES];
    [_datePicker selectRow:[_years indexOfObject:[NSString stringWithFormat:@"%ld",(long)[_currentDateComponents year]]] inComponent:1 animated:YES];
    
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame: CGRectMake(0, 0, self.view.frame.size.width, 44)];
    toolbar.barStyle = UIBarStyleDefault;
    //toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle: @"Done" style: UIBarButtonItemStyleDone target: self action: @selector(doneButtonClick)];
    UIBarButtonItem* flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    toolbar.items = [NSArray arrayWithObjects:flexibleSpace, doneButton, nil];
    
    _datePickerContainerView   = [[UIView alloc] initWithFrame:CGRectMake(0, (self.view.frame.size.height-(toolbar.frame.size.height+_datePicker.frame.size.height)), self.view.frame.size.width, (toolbar.frame.size.height+_datePicker.frame.size.height))];
    [_datePickerContainerView addSubview:toolbar];
    [_datePickerContainerView addSubview:_datePicker];
    
    _isDatePickerOnScreen = YES;
    
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        [self resignAllFromFirstRespon];
    } completion:^(BOOL finished) {
        [self.view addSubview:_datePickerContainerView];
    }];
}

- (void) doneButtonClick{
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        [_datePickerContainerView removeFromSuperview];
    } completion:^(BOOL finished) {
        [self resignAllFromFirstRespon];
        [self removeDatePickerAndSetDate];
    }];
}


-(void) resignAllFromFirstRespon{
    [_cardNumber resignFirstResponder];
    [_nameOnCard resignFirstResponder];
    [_cardExpiryDate resignFirstResponder];
    [_cardCVV resignFirstResponder];
}


-(IBAction) selectBankAndMonthForEMI :(UIButton *)sender{
    
    [self resignAllFromFirstRespon];
    if([sender isEqual:_selectBank]){
        _isBankTableOnScreen = YES;
        _numberOfRow = _emiBank.count;
        [_selectEMITime setTitle:EMI_BUTTON_TITLE forState:UIControlStateNormal];
    }
    else if([sender isEqual:_selectEMITime]){
        _isBankTableOnScreen = NO;
        _numberOfRow = _emiMonths.count;
    }
    
    if(nil == _listOfEMIBank){
        _listOfEMIBank = [[UITableView alloc] initWithFrame:CGRectMake(sender.frame.origin.x, sender.frame.origin.y, sender.frame.size.width, TABLEVIEW_CELL_HEIGHT*(_numberOfRow )) style:UITableViewStylePlain];
        
        _listOfEMIBank.backgroundColor = [UIColor colorWithRed:240.0/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:1.0f];
        
        _listOfEMIBank.dataSource = self;
        _listOfEMIBank.delegate   = self;
        _listOfEMIBank.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    
    
    [_listOfEMIBank reloadData];
    _listOfEMIBank.alpha = 0.0f;
    
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        _listOfEMIBank.alpha = 1.0f;
        [self.containerView addSubview:_listOfEMIBank];
        
    } completion:^(BOOL finished) {
        
    }];
}

- (void) removeDatePickerAndSetDate {
    if(_isDatePickerOnScreen){
        _isDatePickerOnScreen = NO;
        if(_expMonth && _expYear){
            NSString *cardExpiryDate = [NSString stringWithFormat:@"%ld/%ld",(long)_expMonth,(long)_expYear];
            NSLog(@"%@",cardExpiryDate);
            [_cardExpiryDate setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [_cardExpiryDate setTitle:[NSString stringWithFormat:@"%@",cardExpiryDate] forState:UIControlStateNormal];
            _calenderImageView.alpha = ALPHA_FULL;
            _isExpiryDateValid = YES;
        }
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            [_datePickerContainerView removeFromSuperview];
        } completion:nil];
        _cardExpiryDate.enabled = YES;
        [self enableDisablePayNowButton];
    }
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    _cardExpiryDate.enabled = YES;
    [self resignAllFromFirstRespon];
    
//    [self removeDatePickerAndSetDate];
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        _listOfEMIBank.alpha = 0.0f;
    } completion:^(BOOL finished) {
        _isBankTableOnScreen = NO;
        [_listOfEMIBank removeFromSuperview];
        _listOfEMIBank = nil;
    }];
    
}

-(void) checkEnteredInfo :(UITextField *)textField{
    if([textField isEqual:_cardNumber]){
        _cardNum = textField.text;
        int cardBrand = 100;
        if(_cardNum.length > 11)
            cardBrand = [CardValidation checkCardBrandWithNumber:_cardNum];
        NSLog(@"checkEnderedInfo = %d",cardBrand);
        
        if(0 == cardBrand){
            _ccImageView.image = [UIImage imageNamed:@"visa.png"];
            _cvvLength = 3;
        }
        else if(1 == cardBrand){
            _ccImageView.image = [UIImage imageNamed:@"master.png"];
            _cvvLength = 3;
        }
        else if(2 == cardBrand){
            _ccImageView.image = [UIImage imageNamed:@"diner.png"];
            _cvvLength = 3;
        }
        else if(3 == cardBrand){
            _ccImageView.image = [UIImage imageNamed:@"amex.png"];
            _cvvLength = 4;
        }
        else if(4 == cardBrand){
            _ccImageView.image = [UIImage imageNamed:@"discover.png"];
            _cvvLength = 3;
        }
        else if(5 == cardBrand){
            _ccImageView.image = [UIImage imageNamed:@"maestro.png"];
            _cvvLength = 3;
        }
        else {
            _ccImageView.image = [UIImage imageNamed:@"error_icon.png"];
            _cvvLength = 3;
        }
        _ccImageView.alpha = ALPHA_FULL;
    }
//    else if([textField isEqual:_nameOnCard] && textField.text.length < 2){
//        _userImageView.image = [UIImage imageNamed:@"error_icon.png"];
//        _userImageView.alpha = ALPHA_FULL;
//    }
    else if([textField isEqual:_cardCVV]){
        _cvvNum = textField.text;
        if(_cvvLength != [_cvvNum length]){
            _cvvImageView.image = [UIImage imageNamed:@"error_icon.png"];
            _cvvImageView.alpha = ALPHA_FULL;
        }
    }
}

-(void) toggleCardDetailsImages:(UITextField *)textField withString:(NSString *)str
{
    if([str isEqualToString:@""] && (1 <= textField.text.length)){
        str = [textField.text substringToIndex:[textField.text length]-1];
    }
    NSString *textStr = nil;
    if(str){
        textStr = [NSString stringWithFormat:@"%@%@",textField.text,str];
    }
    else{
        textStr = [NSString stringWithString:textField.text];
    }
    if([textField isEqual:_cardNumber]){
        _cardNum = textStr;
        if((_isCardNumberValid = [CardValidation luhnCheck:_cardNum]) && _cardNum.length > 11){
            int cardBrand = [CardValidation checkCardBrandWithNumber:_cardNum];
            if(0 == cardBrand){
                _ccImageView.image = [UIImage imageNamed:@"visa.png"];
                _cvvLength = 3;
            }
            else if(1 == cardBrand){
                _ccImageView.image = [UIImage imageNamed:@"master.png"];
                _cvvLength = 3;
            }
            else if(2 == cardBrand){
                _ccImageView.image = [UIImage imageNamed:@"diner.png"];
                _cvvLength = 3;
            }
            else if(3 == cardBrand){
                _ccImageView.image = [UIImage imageNamed:@"amex.png"];
                _cvvLength = 4;
            }
            else if(4 == cardBrand){
                _ccImageView.image = [UIImage imageNamed:@"discover.png"];
                _cvvLength = 3;
            }
            else if(5 == cardBrand){
                _ccImageView.image = [UIImage imageNamed:@"maestro.png"];
                _cvvLength = 3;
            }
            _ccImageView.alpha = ALPHA_FULL;
        }
        else{
            _ccImageView.image = [UIImage imageNamed:@"card.png"];
            _ccImageView.alpha = ALPHA_HALF;
            _isCardNumberValid = NO;
        }
    }
    else if([textField isEqual:_nameOnCard]){
        
        _cardName = textStr;
        if(1 < [_cardName length]){
            _userImageView.alpha = ALPHA_FULL;
            _isNameOnCardValid = YES;
        }
        else{
            _userImageView.alpha = ALPHA_HALF;
            _isNameOnCardValid = NO;
        }
        _userImageView.image = [UIImage imageNamed:@"user.png"];
        
    }
    else if([textField isEqual:_cardCVV]){
        _cvvNum = textStr;
        if(3 <= [_cvvNum length]){
            _cvvImageView.alpha = ALPHA_FULL;
            _isCvvNumberValid = YES;
        }
        else{
            _cvvImageView.alpha = ALPHA_HALF;
            _isCvvNumberValid = NO;
        }
        _cvvImageView.image = [UIImage imageNamed:@"lock.png"];
        
    }
    
}

-(void) enableDisablePayNowButton{
    
    if(_isCardNumberValid && _isNameOnCardValid && _isExpiryDateValid && _isCvvNumberValid && _isBankSelected && _isEMIPeriodSelected){
        _payNow.enabled = YES;
        [_payNow setBackgroundColor:[UIColor colorWithRed:89.0/255.0 green:193/255.0 blue:0 alpha:1]];
    }
    else if (_isCardNumberValid && _isNameOnCardValid && _isCardSBIMestro && _isBankSelected && _isEMIPeriodSelected) {
        _payNow.userInteractionEnabled = YES;
        _payNow.exclusiveTouch = YES;
        _payNow.enabled = YES;
        [_payNow setBackgroundColor:[UIColor colorWithRed:89.0/255.0 green:193/255.0 blue:0 alpha:1]];
    }
    else{
        NSLog(@"Something CardNum = %@ or Card Name = %@ is not valid , payNow button is disable _isCardNumberValid = %d, _isNameOnCardValid = %d _isCardSBIMestro = %d",_cardNum,_cardName,_isCardNumberValid,_isNameOnCardValid,_isCardSBIMestro);
        _payNow.userInteractionEnabled = YES;
        _payNow.exclusiveTouch = YES;
        _payNow.enabled = NO;
        [_payNow setBackgroundColor:[UIColor lightGrayColor]];
    }
}

- (void) findCardBrand:(NSString *) cardNumber {
    
    int cardBrand = 100;
    cardBrand = [CardValidation checkCardBrandWithNumber:cardNumber];
    
    if(0 <= cardBrand && 7 >= cardBrand){
        _isCardBrandDetected = YES;
    }
    else{
        _isCardBrandDetected = NO;
    }
    
    if(0 == cardBrand){
        _ccImageView.image = [UIImage imageNamed:@"visa.png"];
        _cvvLength = 3;
    }
    else if(1 == cardBrand){
        _ccImageView.image = [UIImage imageNamed:@"master.png"];
        _cvvLength = 3;
    }
    else if(2 == cardBrand){
        _ccImageView.image = [UIImage imageNamed:@"diner.png"];
        _cvvLength = 3;
    }
    else if(3 == cardBrand){
        _ccImageView.image = [UIImage imageNamed:@"amex.png"];
        _cvvLength = 4;
    }
    else if(4 == cardBrand){
        _ccImageView.image = [UIImage imageNamed:@"discover.png"];
        _cvvLength = 3;
    }
    else if(5 == cardBrand){
        _ccImageView.image = [UIImage imageNamed:@"jcb.png"];
        _cvvLength = 3;
    }
    else if(6 == cardBrand){
        _ccImageView.image = [UIImage imageNamed:@"laser.png"];
        _cvvLength = 3;
    }
    else if(7 == cardBrand){
        _ccImageView.image = [UIImage imageNamed:@"maestro.png"];
        _cvvLength = 3;
        
        if([[SharedDataManager sharedDataManager] isSBIMaestro:cardNumber]) {
            // cvv and expiry not needed for maestro
            _cvvLength = 0;
            _isCvvNumberValid = YES;
            _isExpiryDateValid = YES;
            _isCardSBIMestro = YES;
            [self hideAndShowView:YES];
            [self hideAndShowClickButton:YES];
            
        }
    }
    else {
        _cvvLength = 3;
        _ccImageView.image = [UIImage imageNamed:@"card.png"];
    }
    _ccImageView.alpha = ALPHA_FULL;
}

// for checkEnteredInfo
- (void) updateVarsForTextField:(UITextField *)textField withString:(NSString *)str {
    NSString *trimmedText = nil;
    if ([textField isEqual:_cardNumber]) {
        trimmedText = textField.text;
    } else {
        trimmedText= [CardValidation removeEmptyCharsFromString:textField.text];
    }
    
    NSString *textStr = nil;
    if (str == nil) {
        textStr = trimmedText;
    } else if ([str isEqualToString:@""]){
        textStr = [trimmedText substringToIndex:trimmedText.length -1];
    } else {
        textStr = [NSString stringWithFormat:@"%@%@",trimmedText,str];
    }
    
    
    if([textField isEqual:_cardNumber]){
        _cardNum = textStr;
    } else if ([textField isEqual:_nameOnCard]) {
        _cardName = textStr;
    } else if ([textField isEqual:_cardCVV]) {
        _cvvNum = textStr;
    }
    ALog(@"_cardNum: %@, _cardName: %@, _cvvNum:%@", _cardNum, _cardName, _cvvNum);
}

-(void) checkEnteredInfo :(UITextField *)textField isFocused:(BOOL)bIsFocused{
    if([textField isEqual:_cardNumber]){
        
        //_isCardSBIMestro = NO;
        _isCardNumberValid = NO;
        
        if (_cardNum.length == 0) {
            
            _ccImageView.image = [UIImage imageNamed:@"card.png"];
            _ccImageView.alpha = ALPHA_HALF;
            _cvvLength = 3;
        } else {
            _isCardNumberValid = [CardValidation luhnCheck:_cardNum];
            
            if (_isCardNumberValid) {
                                
                
            }
            else {
                _isCardBrandDetected = NO;
                _ccImageView.alpha = ALPHA_FULL;
                if (bIsFocused) {
                    _ccImageView.image = [UIImage imageNamed:@"card.png"];
                } else {
                    _ccImageView.image = [UIImage imageNamed:@"error_icon.png"];
                }
            }
        }
    }
    else if([textField isEqual:_nameOnCard]) {
        /*if(1 < [_cardName length]){
            _userImageView.image = [UIImage imageNamed:@"user.png"];
            _userImageView.alpha = ALPHA_FULL;
            _isNameOnCardValid = YES;
        } else {
            // in case of 0
            _isNameOnCardValid = NO;
            if (bIsFocused) {
                _userImageView.image = [UIImage imageNamed:@"user.png"];
                _userImageView.alpha = ALPHA_HALF;
            } else {
                _userImageView.image = [UIImage imageNamed:@"error_icon.png"];
                _userImageView.alpha = ALPHA_FULL;
            }
        }*/
        
    }
    else if([textField isEqual:_cardCVV]){
        ALog(@"cvvNum %@, cvvLength %ld", _cvvNum, (long)_cvvLength);
        if (_cardNum == nil) {
            _cvvLength = 3;
        }
        
        if(_cvvLength != [_cvvNum length]){
            _cvvImageView.alpha = ALPHA_HALF;
            _isCvvNumberValid = NO;
            if (bIsFocused) {
                _cvvImageView.image = [UIImage imageNamed:@"lock.png"];
            } else {
                _cvvImageView.image = [UIImage imageNamed:@"error_icon.png"];
            }
        } else {
            _isCvvNumberValid = YES;
            _cvvImageView.image = [UIImage imageNamed:@"lock.png"];
            _cvvImageView.alpha = ALPHA_FULL;
        }
    }
}

-(void) hideAndShowView:(BOOL) aFlag{
    
    _cardExpiryDate.hidden = aFlag;
    _calenderImageView.hidden = aFlag;
    _cardCVV.hidden = aFlag;
    _cvvImageView.hidden = aFlag;
}

-(void) hideAndShowClickButton :(BOOL) aFlag{
    
    if(nil == _msgLbl){
        UIFont * fontSize = [UIFont systemFontOfSize:12.0]; //custom font
        _msgLbl = [[UILabel alloc]initWithFrame:CGRectMake(_nameOnCard.frame.origin.x, _nameOnCard.frame.origin.y + _nameOnCard.frame.size.height + 8, 200, 21)];
        _msgLbl.text = @"if you have CVV and Epiry date, Click";
        _msgLbl.font = fontSize;
        _msgLbl.numberOfLines = 1;
        _msgLbl.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
        _msgLbl.adjustsFontSizeToFitWidth = YES;
        _msgLbl.adjustsLetterSpacingToFitWidth = YES;
        _msgLbl.minimumScaleFactor = 10.0f/12.0f;
        _msgLbl.clipsToBounds = YES;
        _msgLbl.backgroundColor = [UIColor clearColor];
        _msgLbl.textColor = [UIColor blackColor];
        _msgLbl.textAlignment = NSTextAlignmentLeft;
    }
    
    if(nil == _button){
        _button= [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [_button addTarget:self
                    action:@selector(buttonClicked:)
          forControlEvents:UIControlEventTouchUpInside];
        [_button setTitle:@"here" forState:UIControlStateNormal];
        _button.frame = CGRectMake(_nameOnCard.frame.origin.x + 200, _nameOnCard.frame.origin.y + _nameOnCard.frame.size.height + 8, 40.0, 21.0);
    }
    [_containerView addSubview:_msgLbl];
    [_containerView addSubview:_button];
}

- (void) buttonClicked :(UIButton *) aButton{
    [self hideAndShowView:NO];
    _cvvLength = 3;
    _msgLbl.hidden = YES;
    _button.hidden = YES;
    _button.enabled = NO;

    _cardCVV.enabled = YES;
    _msgLbl = nil;
    _button = nil;
}


#pragma mark - UIPickerView Delegate

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSInteger selectRowInFirstComponent = row;
    if ([pickerView selectedRowInComponent:0]+1<[_currentDateComponents month] && [[_years objectAtIndex:[pickerView selectedRowInComponent:1]] intValue]==[_currentDateComponents year])
    {
        [pickerView selectRow:[_currentDateComponents month]-1 inComponent:0 animated:YES];
        selectRowInFirstComponent = [_currentDateComponents month]-1;
        NSLog(@"Need to shift");
    }
    
    if (1 == component){
        [pickerView reloadComponent:0];
        _expYear = [[_years objectAtIndex:row] intValue];
    }
    else{
        _expMonth = [[_months objectAtIndex:selectRowInFirstComponent]intValue];
    }
}


- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 44)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor blackColor];
    label.font = [UIFont fontWithName:@"Arial-BoldMT" size:17];
    label.text = component==0?[_months objectAtIndex:row]:[_years objectAtIndex:row];
    
    if (component==0)
    {
        if (row+1<[_currentDateComponents month] && [[_years objectAtIndex:[pickerView selectedRowInComponent:1]] intValue]==[_currentDateComponents year])
        {
            label.textColor = [UIColor grayColor];
        }
    }
    return label;
}

#pragma mark - UIPickerView DataSource

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 2;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    
    NSInteger rowsInComponent;
    if (component==0)
    {
        rowsInComponent=[_months count];
    }
    else
    {
        rowsInComponent=[_years count];
    }
    return rowsInComponent;
}

// tell the picker the width of each row for a given component
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    CGFloat componentWidth ;
    
    if (component==0)
    {
        componentWidth = 100;
    }
    else  {
        componentWidth = 100;
    }
    
    return componentWidth;
}



#pragma mark - TableView DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSLog(@"Number of rows = %lu",(unsigned long)_numberOfRow);
    return _numberOfRow;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellIdentifier = @"cellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    if(_isBankTableOnScreen)
        cell.textLabel.text = [_emiBank objectAtIndex:indexPath.row];
    else{
        cell.textLabel.text = [_emiMonths objectAtIndex:indexPath.row];
    }
    return cell;
}

#pragma mark - TableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //_payNow.enabled = YES;
    //_payNow.backgroundColor = [UIColor colorWithRed:89.0/255.0 green:193/255.0 blue:0 alpha:1];
    _selectedBankIndex = indexPath.row;
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        _listOfEMIBank.alpha = 0.0f;
        if(_isBankTableOnScreen){
            [_selectBank setTitle:[_emiBank objectAtIndex:indexPath.row] forState:UIControlStateNormal];
            _isBankSelected = YES;
            
        }
        else{
            [_selectEMITime setTitle:[_emiMonths objectAtIndex:indexPath.row] forState:UIControlStateNormal];
            _isEMIPeriodSelected = YES;
        }
    } completion:^(BOOL finished) {
        if(_isBankTableOnScreen){
            [self extractEmiMonthsForBank];
            _numberOfRow = _emiMonths.count;
            _isBankTableOnScreen = NO;
            _selectEMITime.enabled = YES;
            [_selectEMITime setTitle:[_emiMonths objectAtIndex:_emiMonths.count-1] forState:UIControlStateNormal];
            _isEMIPeriodSelected = YES;
            [self enableDisablePayNowButton];
        }
        
        [_listOfEMIBank removeFromSuperview];
        _listOfEMIBank = nil;
    }];
    
    [self enableDisablePayNowButton];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor colorWithRed:240.0/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:1.0f];
}


#pragma mark - UITextField Delegate

- (void)textFieldDidEndEditing:(UITextField *)textField{
    /*[self toggleCardDetailsImages:textField withString:nil];
    [self checkEnteredInfo:textField];
    [self enableDisablePayNowButton];*/
    [self updateVarsForTextField:textField withString:nil];
    [self checkEnteredInfo:textField isFocused:NO];
    [self enableDisablePayNowButton];

}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    if(_datePickerContainerView)
        [_datePickerContainerView removeFromSuperview];
    
    CGSize result = [[UIScreen mainScreen] bounds].size;
    if((![textField isEqual:_cardNumber]) || (result.height == IPHONE_3_5))
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    
    if(result.height == IPHONE_4)
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    
    /// add toolbar for keyboard.
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    [toolbar setBarStyle:UIBarStyleDefault];
    [toolbar sizeToFit];
    
    UIButton *nextButton = [[UIButton alloc] init];
    nextButton.titleLabel.text = @"next";
    [nextButton setImage:[UIImage imageNamed:@"next.png"] forState:UIControlStateNormal];
    [nextButton addTarget:self action:@selector(nextButtonClicked:)
         forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *nextBarButton =[[UIBarButtonItem alloc] initWithCustomView:nextButton];
    
    UIButton *prevButton = [[UIButton alloc] init];
    prevButton.titleLabel.text = @"Prev";
    [prevButton setImage:[UIImage imageNamed:@"prev.png"] forState:UIControlStateNormal];
    [prevButton addTarget:self action:@selector(previousButtonClicked:)
         forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *prevBarButton =[[UIBarButtonItem alloc] initWithCustomView:prevButton];
    prevButton.titleLabel.text = @"Prev";
    UIBarButtonItem *flexButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *doneButton =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(resignKeyboard:)];
    
    [toolbar setItems:[NSArray arrayWithObjects:prevBarButton,nextBarButton,flexButton, doneButton, nil]];
    
    [textField setInputAccessoryView:toolbar];
    
    flexButton = nil;
    doneButton = nil;
    nextBarButton = nil;
    prevButton = nil;
    prevBarButton = nil;
    nextButton = nil;
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    //[self toggleCardDetailsImages:textField withString:nil];
    //[self enableDisablePayNowButton];
    [textField resignFirstResponder];
    return YES;
}


- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    
    /*[self toggleCardDetailsImages:textField withString:nil];
    [self checkEnteredInfo:textField];
    [self enableDisablePayNowButton];*/
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (textField.keyboardType == UIKeyboardTypeNumberPad) {
        if([string rangeOfCharacterFromSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]].location !=NSNotFound)
        {
            return NO;
        }
    }
    
    NSString *trimmedText = [CardValidation removeEmptyCharsFromString:textField.text];
    BOOL isValid = YES;
    
    if([string isEqualToString:@""]){
        trimmedText = [textField.text substringToIndex:textField.text.length-1];
    }
    else{
        trimmedText  = [textField.text stringByReplacingCharactersInRange:range withString:string];
    }

    
    if (trimmedText.length > _cvvLength && [textField isEqual:_cardCVV] && ![string isEqualToString:@""])
        isValid = NO;
    
    if (trimmedText.length > MAX_DIGIT_CARD_NUMBER && [textField isEqual:_cardNumber] && ![string isEqualToString:@""])
        isValid = NO;
    
    if (trimmedText.length > MAX_CHAR_CARD_NAME && [textField isEqual:_nameOnCard] && ![string isEqualToString:@""])
        isValid = NO;
    
    NSString *cardNumStr = nil;
    if([string isEqualToString:@""]){
        cardNumStr = [textField.text substringToIndex:textField.text.length-1];
    }
    else{
        cardNumStr  = [textField.text stringByReplacingCharactersInRange:range withString:string];
    }
    
    if(6 > cardNumStr.length && [textField isEqual:_cardNumber]){
        _isCardBrandDetected = NO;
        _cvvLength = 3;
        _ccImageView.image = [UIImage imageNamed:@"card.png"];
        _ccImageView.alpha = ALPHA_HALF;
    }
    
    if([textField isEqual:_cardNumber] && cardNumStr.length < 19 && !_isCardBrandDetected && cardNumStr.length > 5){
        [self findCardBrand:cardNumStr];
    }

    if (isValid) {
        if ([textField isEqual:_cardNumber]) {
            // checks for removing existing cvv in case of card change
            _cardCVV.text = @"";
            _isCvvNumberValid = NO;
        }
        if(![textField isEqual:_cardNumber]){
            [self updateVarsForTextField:textField withString:string];
            [self checkEnteredInfo:textField isFocused:true];
        }
        
        [self enableDisablePayNowButton];
    }
    
    if([textField isEqual:_cardCVV])
        NSLog(@"String in field = %@ _cvvlength = %ld isValid = %d trimmedText = %@",cardNumStr,(long)_cvvLength,isValid,trimmedText);

    
    return isValid;
}


#pragma mark - UIView movement on KB appearance
- (void)keyboardDidShow:(NSNotification *)notification
{
    __block float sizeToDiscreaseFromCenter = 0.0;
    CGSize result = [[UIScreen mainScreen] bounds].size;

    if(result.height == IPHONE_3_5)
    {
        sizeToDiscreaseFromCenter = 200.0f;
    }
    else if(IPHONE_4 == result.height)
    {
            sizeToDiscreaseFromCenter = 170.0f;
    }
    else if(IPHONE_4_7 == result.height){
        sizeToDiscreaseFromCenter = 150.0f;
    }
    else{
        sizeToDiscreaseFromCenter = 130.0f;
    }
    // Assign new center to your view
    [UIView animateWithDuration:0.2
                          delay:0
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.view.center = CGPointMake(_originalCenter.x, _originalCenter.y - sizeToDiscreaseFromCenter);
                     }
                     completion:^(BOOL finished) {
                         sizeToDiscreaseFromCenter = 0.0f;
                     }];
    
}

-(void)keyboardDidHide:(NSNotification *)notification
{
    // Assign original center to your view
    [UIView animateWithDuration:0.2
                          delay:0
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.view.center = _originalCenter;
                     }
                     completion:nil];
}

- (void) resignKeyboard :(UITextField *) textField{
    [self.view endEditing:YES];
}

-(void) nextButtonClicked :(UITextField *) textField{
    if (textField == _cardNumber) {
        [_nameOnCard becomeFirstResponder];
    }
    else if (textField == _nameOnCard) {
        [_cardCVV becomeFirstResponder];
    }
    else if (textField == _cardCVV) {
        [textField resignFirstResponder];
    }
}
-(void) previousButtonClicked :(UITextField *) textField{
    NSLog(@"previousButtonClicked");
}


@end
