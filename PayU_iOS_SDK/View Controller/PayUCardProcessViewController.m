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
@property (retain, nonatomic) UITextField *textField;

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

@property (nonatomic,assign) BOOL isCardNumberValid;
@property (nonatomic,assign) BOOL isNameOnCardValid;
@property (nonatomic,assign) BOOL isExpiryDateValid;
@property (nonatomic,assign) BOOL isCvvNumberValid;

@property (nonatomic,assign) BOOL isCardSBIMestro;


@property (weak, nonatomic) IBOutlet UIView *containerView1;
@property (weak, nonatomic) IBOutlet UIView *containerView2;

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
    
    payBtnFrame = _payNowBtn.frame;
    _originalCenter = self.view.center;
    
    _cardNumber.delegate = self;
    _nameOnCard.delegate = self;
    _cardCVV.delegate = self;
    
    //Set app title if provide by user
    if(_appTitle)
    self.navigationController.navigationItem.title = _appTitle;

    if(0 == _CCDCFlag){
        _viewTitle.text = DEBIT_CARD;
        _cardType = CARD_TYPE_DC;

    }else{
        _viewTitle.text = CREDIT_CARD;
        _cardType = CARD_TYPE_CC;
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
    NSDictionary *paramDict = [[SharedDataManager sharedDataManager] allInfoDict];
    if([paramDict valueForKey:PARAM_USER_CREDENTIALS]){
        [self displayStoreCardOption];
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
    
    NSURL *restURL = [NSURL URLWithString:PAYU_PAYMENT_BASE_URL_TEST];
    
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

-(void) resignAllFromFirstRespon{
    [_cardNumber resignFirstResponder];
    [_nameOnCard resignFirstResponder];
    [_cardExpiryDate resignFirstResponder];
    [_cardCVV resignFirstResponder];
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
            NSLog(@"cardBrand = %d",cardBrand);
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
                _isCardSBIMestro = YES;
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
        if(!_isCardSBIMestro){
            if(3 <= [_cvvNum length]){
                _cvvImageView.alpha = ALPHA_FULL;
                _isCvvNumberValid = YES;
            }
            else{
                _cvvImageView.alpha = ALPHA_HALF;
                _isCvvNumberValid = NO;
            }
        }
        else{
            _isCvvNumberValid = YES;
        }
        _cvvImageView.image = [UIImage imageNamed:@"lock.png"];

    }

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
    else if([textField isEqual:_nameOnCard] && textField.text.length < 2){
        _userImageView.image = [UIImage imageNamed:@"error_icon.png"];
        _userImageView.alpha = ALPHA_FULL;
    }
    else if([textField isEqual:_cardCVV]){
        _cvvNum = textField.text;
        if(_cvvLength != [_cvvNum length]){
            _cvvImageView.image = [UIImage imageNamed:@"error_icon.png"];
            _cvvImageView.alpha = ALPHA_FULL;
        }
    }
}

-(void) enableDisablePayNowButton{
    
    if(_isCardNumberValid && _isNameOnCardValid && _isExpiryDateValid && _isCvvNumberValid){
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
        [self resignAllFromFirstRespon];
    } completion:^(BOOL finished) {
        [self removeDatePickerAndSetDate];
    }];
}

// dismiss the keyboard when click on View
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self resignAllFromFirstRespon];
    [self removeDatePickerAndSetDate];
    
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
#warning Display Card store Option
-(void) displayStoreCardOption{
    
    _checkbox = [[UIButton alloc] initWithFrame:CGRectMake(_cardCVV.frame.origin.x,(_cardCVV.frame.origin.y+_cardCVV.frame.size.height + 8),20,20)];
    
    [_checkbox setBackgroundImage:[UIImage imageNamed:@"unchecked.png"] forState:UIControlStateNormal];
    [_checkbox setBackgroundImage:[UIImage imageNamed:@"checkbox.png"]  forState:UIControlStateSelected];
    [_checkbox setBackgroundImage:[UIImage imageNamed:@"checkbox.png"]
                        forState:UIControlStateHighlighted];
    _checkbox.adjustsImageWhenHighlighted=YES;
    [_checkbox addTarget:self action:@selector(checkboxSelected:) forControlEvents:UIControlEventTouchUpInside];
    
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(_checkbox.frame.origin.x + _checkbox.frame.size.width+5,(_cardCVV.frame.origin.y+_cardCVV.frame.size.height +8),120,21)];
    label.text = @"Store this Card";
    
    _checkbox.alpha = 0.5;
    label.alpha = 0.5;
    CGRect frame =_payNowBtn.frame;
    frame.origin.y = _checkbox.frame.origin.y + _checkbox.frame.size.height + 8;
    
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        _payNowBtn.frame = frame;
        [_containerView2 addSubview:_checkbox];
        [_containerView2 addSubview:label];
    } completion:nil];
}

-(void)checkboxSelected:(id)sender
{
    _checkBoxSelected = !_checkBoxSelected;
    [_checkbox setSelected:_checkBoxSelected];
    if(_checkBoxSelected){
        _textField= [[UITextField alloc] initWithFrame:CGRectMake(_checkbox.frame.origin.x, _checkbox.frame.origin.y+10+ _checkbox.frame.size.height, 300, 50)];
        _textField.borderStyle = UITextBorderStyleNone;
        _textField.font = [UIFont systemFontOfSize:18];
        _textField.placeholder = @"enter Card Name";
        _textField.autocorrectionType = UITextAutocorrectionTypeNo;
        _textField.keyboardType = UIKeyboardTypeNamePhonePad;
        _textField.returnKeyType = UIReturnKeyDone;
        _textField.clearButtonMode = UITextFieldViewModeNever;
        _textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        _textField.backgroundColor = [UIColor whiteColor];
        _textField.delegate = self;
        
        CGRect frame = _payNowBtn.frame;
        frame.origin.y = frame.origin.y + _textField.frame.size.height + 8;
        
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            _payNowBtn.frame = frame;
            [_containerView2 addSubview:_textField];
        } completion:nil];

        
    }
    else{
        
        CGRect frame = _payNowBtn.frame;
        frame.origin.y = frame.origin.y + 8 - _textField.frame.size.height;
        
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            _payNowBtn.frame = frame;
            [_containerView2 removeFromSuperview];

        } completion:nil];
        _textField = nil;
    }
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

#pragma mark - UITextField Delegate

- (void)textFieldDidEndEditing:(UITextField *)textField{
    [self toggleCardDetailsImages:textField withString:nil];
    [self checkEnteredInfo:textField];
    [self enableDisablePayNowButton];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    if(_datePickerContainerView)
    [_datePickerContainerView removeFromSuperview];
    
    CGSize result = [[UIScreen mainScreen] bounds].size;
    if((![textField isEqual:_cardNumber]) || (result.height == IPHONE_3_5))
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    
    if(textField.text.length > 0)
    [self toggleCardDetailsImages:textField withString:nil];
    [self enableDisablePayNowButton];

    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self toggleCardDetailsImages:textField withString:nil];
    [self enableDisablePayNowButton];

    return YES;
}


- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    
    [self toggleCardDetailsImages:textField withString:nil];
    [self checkEnteredInfo:textField];
    [self enableDisablePayNowButton];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    // cvv
    if (textField.text.length > _cvvLength-1 && [textField isEqual:_cardCVV] && ![string isEqualToString:@""])
        return NO;
    
    if (textField.text.length > 18 && [textField isEqual:_cardNumber] && ![string isEqualToString:@""])
        return NO;
    
    if (textField.text.length > 29 && [textField isEqual:_nameOnCard] && ![string isEqualToString:@""])
        return NO;
    
    if(textField.text.length > 0)
    [self toggleCardDetailsImages:textField withString:string];
    [self enableDisablePayNowButton];
    return YES;
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
    else
    {
        sizeToDiscreaseFromCenter = 100;
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
