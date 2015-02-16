//
//  PayUCCDCProcessViewController.m
//  PayU_iOS_SDK
//
//  Created by Suryakant Sharma on 12/12/14.
//  Copyright (c) 2014 PayU, India. All rights reserved.
//

#import "PayUCardProcessViewController.h"
#import "CardValidation.h"
#import "PayUConstant.h"
#import "SharedDataManager.h"
#import "Utils.h"
#import "PayUPaymentResultViewController.h"


#define DEBIT_CARD   @"Please enter debit card details"
#define CREDIT_CARD  @"Please enter credit card details"

#define ALPHA_HALF   0.5
#define ALPHA_FULL   1.0

#define CARD_TYPE_CC @"CC"
#define CARD_TYPE_DC @"DC"



@interface PayUCardProcessViewController () <UIPickerViewDelegate,UIPickerViewDataSource,UITextFieldDelegate>{
    
    CGRect payBtnFrame;
}

@property (retain, nonatomic) UIButton *checkbox;
@property (assign, nonatomic) BOOL checkBoxSelected;
@property (retain, nonatomic) UITextField *cardNameToStore;

@property (nonatomic,strong) NSURLConnection *connection;
@property (nonatomic,strong) NSMutableData *connectionSpecificDataObject;
@property (nonatomic,strong) NSMutableData *receivedData;

@property (unsafe_unretained, nonatomic) IBOutlet UILabel *viewTitle;
@property (strong, nonatomic) UIPickerView *datePicker;
@property (strong, nonatomic) UIView *datePickerContainerView;
@property (strong, nonatomic) NSMutableArray *years;
@property (strong, nonatomic) NSMutableArray *months;

@property (nonatomic,assign) NSInteger expMonth;
@property (nonatomic,assign) NSInteger expYear;
@property (nonatomic,assign) BOOL isDatePickerOnScreen;
//@property (nonatomic,assign) BOOL isDateSelected;

@property (nonatomic,assign) BOOL isCardNumberValid;
@property (nonatomic,assign) BOOL isNameOnCardValid;
@property (nonatomic,assign) BOOL isExpiryDateValid;
@property (nonatomic,assign) BOOL isCvvNumberValid;

@property (nonatomic,assign) BOOL isCardSBIMestro;


@property (weak, nonatomic) IBOutlet UIView *containerView1;
@property (weak, nonatomic) IBOutlet UIView *containerView2;
@property (nonatomic,strong) IBOutlet UILabel *amountLbl;

@property (nonatomic,strong) IBOutlet UILabel *storedCardMsg;
@property (assign,nonatomic) NSInteger cvvLength;



@property (strong, nonatomic) NSDateComponents* currentDateComponents;

@property (nonatomic,assign) CGPoint originalCenter;


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

@property (weak, nonatomic) IBOutlet UIButton *payNowBtn;


-(IBAction) displayDatePicketView :(UIPickerView *) pickerView;

-(void) resignAllFromFirstRespon;

-(void) enableDisablePayNowButton;

-(void) toggleCardDetailsImages:(UITextField *)textField withString:(NSString *)str;

-(IBAction) payNow:(UIButton *)btn;

@end

@implementation PayUCardProcessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _cvvLength = 3;
    _months = nil;
    _years  = nil;
    
    _isCardNumberValid = NO;
    _isCvvNumberValid  = NO;
    _isExpiryDateValid = NO;
    _isNameOnCardValid = NO;
    _isCardSBIMestro   = NO;
//    _isDateSelected    = NO;
    
    payBtnFrame = _payNowBtn.frame;
    _originalCenter = [[[[UIApplication sharedApplication] delegate] window] center];
    
    _cardNumber.delegate = self;
    _nameOnCard.delegate = self;
    _cardCVV.delegate = self;
    

    
    if(1 == _CCDCFlag){
        _viewTitle.text = CREDIT_CARD;
        _cardType = CARD_TYPE_CC;
        
    }else{
        _viewTitle.text = DEBIT_CARD;
        _cardType = CARD_TYPE_DC;
    }
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        CGSize result = [[UIScreen mainScreen] bounds].size;
        if(result.height == IPHONE_3_5)
        {
            _payNowBtn.layer.cornerRadius = 7.0f;
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
        }
        else
        {
            _payNowBtn.layer.cornerRadius = 10.0f;
            
        }
    }
    SharedDataManager *manager = [SharedDataManager sharedDataManager];
    // Stored card option will be dislpayed if user_credentials has been provided.
    NSDictionary *paramDict = [[SharedDataManager sharedDataManager] allInfoDict];
    if(0 == paramDict.allKeys.count){
        manager.allInfoDict = [self createDictionaryWithAllParam];
    }
    
    //Set app title if provide by user
    if(_appTitle)
        self.navigationController.navigationItem.title = _appTitle;
    
    _amountLbl.text = [NSString stringWithFormat:@"Rs. %.2f",[[paramDict objectForKey:PARAM_TOTAL_AMOUNT] floatValue]];
    if([paramDict valueForKey:PARAM_USER_CREDENTIALS] || _storeThisCard){
        [self displayStoreCardOption];
        if(_storeThisCard){
            [self checkboxSelected:nil];
        }
    }

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(IBAction) payNow:(UIButton *)btn{
    
    if (_connectionSpecificDataObject) {
        _connectionSpecificDataObject = nil;
    }
    _connectionSpecificDataObject = [[NSMutableData alloc] init];
    
    NSURL *restURL = [NSURL URLWithString:PAYU_PAYMENT_BASE_URL_PRODUCTION];
    
    // create the request
    NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:restURL
                                                            cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                        timeoutInterval:60.0];
    // Specify that it will be a POST request
    theRequest.HTTPMethod = @"POST";
    
    NSDictionary *paramDict = [[SharedDataManager sharedDataManager] allInfoDict];
    
    NSMutableString *postData = [[NSMutableString alloc] init];
    for(NSString *aKey in [paramDict allKeys]){
        [postData appendFormat:@"%@=%@",aKey,[paramDict valueForKey:aKey]];
        [postData appendString:@"&"];
    }
    
    if(_storeThisCard || [paramDict objectForKey:PARAM_USER_CREDENTIALS]){
        [postData appendFormat:@"%@=%@",PARAM_STORE_YOUR_CARD,[NSNumber numberWithInt:1]];
        [postData appendString:@"&"];
        if(![_storedCardMsg.text isEqualToString:@""]){
            [postData appendFormat:@"%@=%@",PARAM_STORE_CARD_NAME,_cardNameToStore.text];
            [postData appendString:@"&"];
        }
    }
    
    if(_cardType){
        [postData appendFormat:@"%@=%@",PARAM_PG,_cardType];
        [postData appendString:@"&"];
    }
    if(_cardNumber.text){
        [postData appendFormat:@"%@=%@",PARAM_CARD_NUMBER,_cardNumber.text];
        [postData appendString:@"&"];
    }
    if(_nameOnCard.text){
        [postData appendFormat:@"%@=%@",PARAM_CARD_NAME,_nameOnCard.text];
        [postData appendString:@"&"];
    }
    if(_cardCVV.text){
        [postData appendFormat:@"%@=%@",PARAM_CARD_CVV,_cardCVV.text];
        [postData appendString:@"&"];
    }
    if(_expMonth){
        [postData appendFormat:@"%@=%ld",PARAM_CARD_EXPIRY_MONTH,(long)_expMonth];
        [postData appendString:@"&"];
    }
    if(_expYear){
        [postData appendFormat:@"%@=%ld",PARAM_CARD_EXPIRY_YEAR,(long)_expYear];
        [postData appendString:@"&"];
    }
    if([_cardType isEqualToString:@"DC"]){
        [postData appendFormat:@"%@=%@",PARAM_BANK_CODE,@"VISA"];
    }
    else{
        [postData appendFormat:@"%@=%@",PARAM_BANK_CODE,@"CC"];
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
    else{
        
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

-(void) resignAllFromFirstRespon{
    [_cardNumber resignFirstResponder];
    [_nameOnCard resignFirstResponder];
    [_cardExpiryDate resignFirstResponder];
    [_cardCVV resignFirstResponder];
    [_cardNameToStore resignFirstResponder];
}

//-(void) toggleCardDetailsImages:(UITextField *)textField withString:(NSString *)str
//{
//    ALog(@"");
//    NSString *trimmedText = [CardValidation removeEmptyCharsFromString:textField.text];
//    
////    if([str isEqualToString:@""] && (1 <= trimmedText.length)){
////        str = [trimmedText substringToIndex:[trimmedText length]-1];
////    }
////    NSString *textStr = nil;
////    if(![str isEqualToString:@""]){
////        textStr = [NSString stringWithFormat:@"%@%@",trimmedText,str];
////    }
////    else{
////        textStr = [trimmedText substringToIndex:trimmedText.length -1];
////    }
//    if([textField isEqual:_cardNumber]){
////        _cardNum = textStr;
////        _isCardSBIMestro = NO;
//        if((_isCardNumberValid = [CardValidation luhnCheck:_cardNum])){// && _cardNum.length > 11){
//            int cardBrand = [CardValidation checkCardBrandWithNumber:_cardNum];
//            NSLog(@"cardBrand ohlala = %d",cardBrand);
//            if(0 == cardBrand){
//                _ccImageView.image = [UIImage imageNamed:@"visa.png"];
//                _cvvLength = 3;
//            }
//            else if(1 == cardBrand){
//                _ccImageView.image = [UIImage imageNamed:@"master.png"];
//                _cvvLength = 3;
//            }
//            else if(2 == cardBrand){
//                _ccImageView.image = [UIImage imageNamed:@"diner.png"];
//                _cvvLength = 3;
//            }
//            else if(3 == cardBrand){
//                _ccImageView.image = [UIImage imageNamed:@"amex.png"];
//                _cvvLength = 4;
//            }
//            else if(4 == cardBrand){
//                _ccImageView.image = [UIImage imageNamed:@"discover.png"];
//                _cvvLength = 3;
//            }
//            else if(5 == cardBrand){
//                _ccImageView.image = [UIImage imageNamed:@"maestro.png"];
//                _cvvLength = 0;
////                _isCardSBIMestro = YES;
//            }
//            _ccImageView.alpha = ALPHA_FULL;
//        }
//        else{
//            _ccImageView.image = [UIImage imageNamed:@"card.png"];
//            _ccImageView.alpha = ALPHA_HALF;
//            _isCardNumberValid = NO;
//        }
//    }
//    else if([textField isEqual:_nameOnCard]){
//        
////        _cardName = textStr;
//        if(1 < [_cardName length]){
//            _userImageView.alpha = ALPHA_FULL;
//            _isNameOnCardValid = YES;
//        }
//        else{
//            _userImageView.alpha = ALPHA_HALF;
//            _isNameOnCardValid = NO;
//        }
//        _userImageView.image = [UIImage imageNamed:@"user.png"];
//        
//    }
//    else if([textField isEqual:_cardCVV]){
////        _cvvNum = textStr;
//        if(!_isCardSBIMestro){
//            if(3 <= [_cvvNum length]){
//                _cvvImageView.alpha = ALPHA_FULL;
//                _isCvvNumberValid = YES;
//            }
//            else{
//                _cvvImageView.alpha = ALPHA_HALF;
//                _isCvvNumberValid = NO;
//            }
//        }
//        else{
//            if ([_cvvNum length] == 0) {
//                _cvvImageView.alpha = ALPHA_FULL;
//                _isCvvNumberValid = YES;
//            } else {
//                _cvvImageView.alpha = ALPHA_HALF;
//                _isCvvNumberValid = NO;
//            }
//            
//        }
//        _cvvImageView.image = [UIImage imageNamed:@"lock.png"];
//        
//    }
//    
//}

//-(void) checkEnteredInfo:(UITextField *)textField withString:(NSString *)str {
//    
//}

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
//    if(![str isEqualToString:@""]){
//        textStr = [NSString stringWithFormat:@"%@%@",trimmedText,str];
//    }
//    else if (str){
//        textStr = [trimmedText substringToIndex:trimmedText.length -1];
//    } else {
//        textStr = trimmedText;
//    }

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
        
        // uipickerview for date check
//        if (!_isDateSelected) {
//            _isExpiryDateValid = NO;
//        }
        
        int cardBrand = 100;
        
        _isCardSBIMestro = NO;
        _isCardNumberValid = NO;
        
        if (_cardNum.length == 0) {
            ALog(@"");
            _ccImageView.image = [UIImage imageNamed:@"card.png"];
            _ccImageView.alpha = ALPHA_HALF;
            _cvvLength = 3;
        } else {
            _isCardNumberValid = [CardValidation luhnCheck:_cardNum];
            
            if (_isCardNumberValid) {
                ALog(@"");
                cardBrand = [CardValidation checkCardBrandWithNumber:_cardNum];
                //            NSLog(@"checkEnderedInfo = %d",cardBrand);
                _isCardNumberValid = YES;
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
                    _isCardSBIMestro = YES;
                    _ccImageView.image = [UIImage imageNamed:@"maestro.png"];
                    _cvvLength = 0;
                    
                    // cvv and expiry not needed for maestro
                    _isCvvNumberValid = YES;
//                    _isExpiryDateValid = YES;
                }
                else {
                    _isCardNumberValid = NO;
                    _cvvLength = 3;
                    if (bIsFocused) {
                        _ccImageView.image = [UIImage imageNamed:@"card.png"];
                    } else {
                        _ccImageView.image = [UIImage imageNamed:@"error_icon.png"];
                    }
                }
                _ccImageView.alpha = ALPHA_FULL;
            }
            else {
                ALog(@"");
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
        if(1 < [_cardName length]){
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
        }

    }
    else if([textField isEqual:_cardCVV]){
        ALog(@"cvvNum %@, cvvLength %ld", _cvvNum, _cvvLength);
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

-(void) enableDisablePayNowButton{
    ALog(@"");
    if(_isCardNumberValid && _isNameOnCardValid && _isExpiryDateValid && _isCvvNumberValid){
        _payNowBtn.enabled = YES;
        [_payNowBtn setBackgroundColor:[UIColor colorWithRed:89.0/255.0 green:193/255.0 blue:0 alpha:1]];
    } else if (_isCardNumberValid && _isNameOnCardValid && _isCardSBIMestro){
        _payNowBtn.enabled = YES;
        [_payNowBtn setBackgroundColor:[UIColor colorWithRed:89.0/255.0 green:193/255.0 blue:0 alpha:1]];
    }
    else{
        _payNowBtn.userInteractionEnabled = YES;
        _payNowBtn.exclusiveTouch = YES;
        _payNowBtn.enabled = NO;
        [_payNowBtn setBackgroundColor:[UIColor lightGrayColor]];
    }
}

-(IBAction) displayDatePicketView :(UIPickerView *) pickerView{
    
    ALog(@"yes");
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
//    _isExpiryDateValid = YES;
    
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        [self resignAllFromFirstRespon];
    } completion:^(BOOL finished) {
        [self.view addSubview:_datePickerContainerView];
    }];
}

- (void) doneButtonClick{
    ALog(@"");
//    _isDateSelected = YES;
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        [_datePickerContainerView removeFromSuperview];
        [self resignAllFromFirstRespon];
    } completion:^(BOOL finished) {
        [self removeDatePickerAndSetDate];
    }];
}

// dismiss the keyboard when click on View
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self resignAllFromFirstRespon];
    //[self removeDatePickerAndSetDate];
    
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

//TODO: Display Card store Option
-(void) displayStoreCardOption{
    
    CGSize result = [[UIScreen mainScreen] bounds].size;
    CGRect checkBoxFrame = CGRectZero;
    CGRect lblBoxFrame = CGRectZero;

    if(result.height == IPHONE_3_5)
    {
        checkBoxFrame = CGRectMake(8, 174+40, 18, 18);
        lblBoxFrame   = CGRectMake(8+18+5, 174+40, 120, 18);
    }
    else
    {
        checkBoxFrame = CGRectMake(8,5,18,18);
        lblBoxFrame   = CGRectMake(26+5,5,120,18);
    }
    _checkbox = [[UIButton alloc] initWithFrame:checkBoxFrame];
    
    [_checkbox setBackgroundImage:[UIImage imageNamed:@"unchecked.png"] forState:UIControlStateNormal];
    [_checkbox setBackgroundImage:[UIImage imageNamed:@"checkbox.png"]  forState:UIControlStateSelected];
    [_checkbox setBackgroundImage:[UIImage imageNamed:@"checkbox.png"]
                         forState:UIControlStateHighlighted];
    _checkbox.adjustsImageWhenHighlighted=YES;
    //[_checkbox addTarget:self action:@selector(checkboxSelected:) forControlEvents:UIControlEventTouchUpInside];
   
    _storedCardMsg = [[UILabel alloc] initWithFrame:lblBoxFrame];
    _storedCardMsg.font = [UIFont systemFontOfSize:12.0];
    _storedCardMsg.text = @"Store this Card";
    //[_containerView1 removeConstraints:_containerView1.constraints];
    _checkbox.alpha = 0.5;
    _storedCardMsg.alpha = 0.5;
    
    CGRect frame = checkBoxFrame;
    frame.size.width = frame.size.width + lblBoxFrame.size.width;
    frame.size.height = frame.size.height + 2;
    frame.origin.x = 5;
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button addTarget:self action:@selector(checkboxSelected:) forControlEvents:UIControlEventTouchUpInside];
    button.backgroundColor = [UIColor clearColor];
    [button setTitle:@"" forState:UIControlStateNormal];
    button.frame = frame;
    
    if(result.height == IPHONE_3_5)
    {
        [_containerView1 addSubview:_checkbox];
        [_containerView1 addSubview:_storedCardMsg];
        [_containerView1 addSubview:button];
    }
    else
    {
        [_containerView2 addSubview:_checkbox];
        [_containerView2 addSubview:_storedCardMsg];
        [_containerView2 bringSubviewToFront:_checkbox];
        [_containerView2 bringSubviewToFront:_storedCardMsg];
        [_containerView2 addSubview:button];
    }
}

-(void)checkboxSelected:(id)sender
{
    _checkBoxSelected = !_checkBoxSelected;
    [_checkbox setSelected:_checkBoxSelected];
    if(_checkBoxSelected){
        CGRect frame = CGRectZero;
        CGSize result = [[UIScreen mainScreen] bounds].size;
        if(result.height == IPHONE_3_5)
        {
            frame = CGRectMake(_checkbox.frame.origin.x, _checkbox.frame.origin.y+5+ _checkbox.frame.size.height, self.view.frame.size.width - 16, 20);
        }
        else
        {
            frame = CGRectMake(8, _checkbox.frame.size.height + 10, self.view.frame.size.width - 16, 20);
        }
        
        _cardNameToStore= [[UITextField alloc] initWithFrame:frame];
        _cardNameToStore.borderStyle = UITextBorderStyleNone;
        _cardNameToStore.font = [UIFont systemFontOfSize:12];
        _cardNameToStore.placeholder = @" enter Card Name";
        _cardNameToStore.autocorrectionType = UITextAutocorrectionTypeNo;
        _cardNameToStore.keyboardType = UIKeyboardTypeNamePhonePad;
        _cardNameToStore.returnKeyType = UIReturnKeyDone;
        _cardNameToStore.clearButtonMode = UITextFieldViewModeNever;
        _cardNameToStore.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        _cardNameToStore.backgroundColor = [UIColor whiteColor];
        _cardNameToStore.delegate = self;
        
        //[_containerView2 removeConstraints:_containerView2.constraints];
        //[_payNowBtn removeConstraints:_payNowBtn.constraints];
        _payNowBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        _payNowBtn.translatesAutoresizingMaskIntoConstraints = YES;
        
        frame = _payNowBtn.frame;
        frame.origin.y = frame.origin.y + _cardNameToStore.frame.size.height + 3;
        
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            _payNowBtn.frame = frame;
            if(result.height == IPHONE_3_5)
            {
                [_containerView1 addSubview:_cardNameToStore];
            }
            else{
                [_containerView2 addSubview:_cardNameToStore];
 
            }
        } completion:nil];
        
        
    }
    else{

        CGRect frame = _payNowBtn.frame;
        frame.origin.y = frame.origin.y - 3 - _cardNameToStore.frame.size.height;
        
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            _payNowBtn.frame = frame;
            [_cardNameToStore removeFromSuperview];
            
        } completion:nil];
        _cardName = nil;
    }
}

-(NSDictionary *) createDictionaryWithAllParam{
    
    NSMutableDictionary *allParamDict = [[NSMutableDictionary alloc] init];
    NSException *exeption = nil;
    
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
    /* if([[NSBundle mainBundle] objectForInfoDictionaryKey:PARAM_COMMAND]){
     _command = [[NSBundle mainBundle] objectForInfoDictionaryKey:PARAM_COMMAND];
     //[allParamDict setValue:_command forKey:PARAM_COMMAND];
     }
     else{
     exeption = [[NSException alloc] initWithName:@"Required Param missing" reason:@"KEY is not provided, this is one of required parameters." userInfo:nil];
     [exeption raise];
     }*/
    
    [allParamDict addEntriesFromDictionary:_parameterDict];
    
    
    NSLog(@"ALL PARAM DICT =%@",allParamDict);
    return allParamDict;
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
    NSLog(@"connectionSpecificDataObject =%@",_connectionSpecificDataObject);
    NSString* newStr = [[NSString alloc] initWithData:_connectionSpecificDataObject encoding:NSUTF8StringEncoding];
    NSLog(@"Str(connectionSpecificDataObject) =%@",newStr);
    
    if (connection == _connection)
    {
        NSLog(@"connectionDidFinishLoading");
        if(_connectionSpecificDataObject){
            NSError *errorJson=nil;
            id allPaymentOption = [NSJSONSerialization JSONObjectWithData:_connectionSpecificDataObject options:kNilOptions error:&errorJson];
            NSLog(@"%@",allPaymentOption);
        }
        
    }
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

#pragma mark - UIPickerView Delegate

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    ALog(@"");
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
    ALog(@"");
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

#pragma mark - UITextField Delegate

- (void)textFieldDidEndEditing:(UITextField *)textField{
//    NSString *trimmedText = textField.text;
//    [CardValidation removeEmptyCharsFromString:trimmedText];
//    [textField setText:trimmedText];
//    ALog(@"");
    
//    [self toggleCardDetailsImages:textField withString:nil];
    ALog(@"%@",textField.text);
    [self updateVarsForTextField:textField withString:nil];
    [self checkEnteredInfo:textField isFocused:NO];
    [self enableDisablePayNowButton];
//    [self checkEnteredInfo:textField];
//    [self enableDisablePayNowButton];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    ALog(@"");
    if(_datePickerContainerView){
        [_datePickerContainerView removeFromSuperview];
        _cardExpiryDate.enabled = YES;
    }
    
    CGSize result = [[UIScreen mainScreen] bounds].size;
    if((![textField isEqual:_cardNumber]) || (result.height == IPHONE_3_5))
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    
//    if(textField.text.length > 0)
//        [self toggleCardDetailsImages:textField withString:nil];
//    [self enableDisablePayNowButton];
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}


- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    ALog(@"");
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    
//    [self toggleCardDetailsImages:textField withString:nil];
//    [self checkEnteredInfo:textField];
//    [self enableDisablePayNowButton];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{

    NSString *trimmedText = [CardValidation removeEmptyCharsFromString:textField.text];
    BOOL isValid = YES;
    // cvv
    if (trimmedText.length >= _cvvLength && [textField isEqual:_cardCVV] && ![string isEqualToString:@""]) {
//        _isCvvNumberValid = NO;
        isValid = NO;
    } else if (trimmedText.length > 19 && [textField isEqual:_cardNumber] && ![string isEqualToString:@""]) {
        isValid = NO;
    } else if (trimmedText.length > 29 && [textField isEqual:_nameOnCard] && ![string isEqualToString:@""]) {
        isValid = NO;
    }
    
//    if(trimmedText.length > 0)
    if (isValid) {
        if ([textField isEqual:_cardNumber]) {
            // checks for removing existing cvv in case of card change
            _cardCVV.text = @"";
            _isCvvNumberValid = NO;
        }
        [self updateVarsForTextField:textField withString:string];
        [self checkEnteredInfo:textField isFocused:true];
        
        //    [self toggleCardDetailsImages:textField withString:string];
        [self enableDisablePayNowButton];
    }
    
    return isValid;
}


#pragma mark - UIView movement on KB appearance
- (void)keyboardDidShow:(NSNotification *)notification
{
    float sizeToDiscreaseFromCenter = 0.0;
    CGSize result = [[UIScreen mainScreen] bounds].size;
    if(result.height == IPHONE_3_5)
    {
        sizeToDiscreaseFromCenter = 140;
    }
    else if(IPHONE_4 == result.height)
    {
        sizeToDiscreaseFromCenter = 170;
    }
    else if(IPHONE_4_7 == result.height){
        sizeToDiscreaseFromCenter = 100;
    }
    else{
        sizeToDiscreaseFromCenter = 80;
    }
    // Assign new center to your view
    [UIView animateWithDuration:0.2
                          delay:0
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.view.center = CGPointMake(_originalCenter.x, _originalCenter.y - sizeToDiscreaseFromCenter);
                     }
                     completion:nil];
    
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


@end
