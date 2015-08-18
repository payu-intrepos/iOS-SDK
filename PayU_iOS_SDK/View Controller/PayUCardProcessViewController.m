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


#define DEBIT_CARD   @"Enter your card details"
#define CREDIT_CARD  @"Enter your card details"

#define ALPHA_HALF   0.5
#define ALPHA_FULL   1.0

#define CARD_TYPE @"CC"
#define CITI_REWARD_PG @"CASH"
#define CITI_REWARD_BANK_CODE @"CPMC"

#define DOWN_TIME_MESSAGE @"We are experiencing high failures for %@ card at this time. We recommend you to pay using any other means of payment."

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

//down time message will be displays here in this UILabel
@property (nonatomic,strong) UILabel *downTimeMsgLbl;


@property (nonatomic,assign) BOOL isCardNumberValid;
@property (nonatomic,assign) BOOL isNameOnCardValid;
@property (nonatomic,assign) BOOL isExpiryDateValid;
@property (nonatomic,assign) BOOL isCvvNumberValid;
@property (nonatomic,assign) BOOL isCardBrandDetected;

@property (nonatomic,assign) BOOL isCardSBIMestro;


@property (weak, nonatomic) IBOutlet UIView *containerView1;
@property (weak, nonatomic) IBOutlet UIView *containerView2;
@property (nonatomic,strong) IBOutlet UILabel *amountLbl;

@property (nonatomic,strong) IBOutlet UILabel *storedCardMsg;
@property (assign,nonatomic) NSInteger cvvLength;



@property (strong, nonatomic) NSDateComponents* currentDateComponents;

@property (nonatomic,assign) CGPoint originalCenter;

@property (nonatomic,strong) UITextField *firstResponderTextField;


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

@property (strong, nonatomic) UILabel *msgLbl;
@property (strong, nonatomic) UIButton *button;

@property (strong,nonatomic) NSDictionary *paramDict;

-(IBAction) displayDatePicketView :(UIPickerView *) pickerView;

-(void) resignAllFromFirstRespon;

-(void) enableDisablePayNowButton;

//-(void) toggleCardDetailsImages:(UITextField *)textField withString:(NSString *)str;

-(IBAction) payNow:(UIButton *)btn;

@end

@implementation PayUCardProcessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _paramDict = [[SharedDataManager sharedDataManager] allInfoDict];
    _cvvLength = 3;
    _months = nil;
    _years  = nil;
    
    _isCardNumberValid = NO;
    _isCvvNumberValid  = NO;
    _isExpiryDateValid = NO;
    _isNameOnCardValid = YES;
    _isCardSBIMestro   = NO;
    _isCardBrandDetected = NO;
    _isCardSBIMestro = NO;
    _checkBoxSelected  = NO;
//    _isDateSelected    = NO;
    
    payBtnFrame = _payNowBtn.frame;
    _originalCenter = [[[[UIApplication sharedApplication] delegate] window] center];
    
    _cardNumber.delegate = self;
    _nameOnCard.delegate = self;
    _cardCVV.delegate = self;
    
    
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
    
    if(nil == manager.listOfDownCardBins){
        [manager makeVasApiCall];
    }

    // Stored card option will be dislpayed if user_credentials has been provided.
    NSDictionary *paramDict = [[SharedDataManager sharedDataManager] allInfoDict];
    if(0 == paramDict.allKeys.count){
        manager.allInfoDict = [self createDictionaryWithAllParam];
    }
    
    //Set app title if provide by user
    if(_appTitle)
        self.navigationController.navigationItem.title = _appTitle;
    
/*    if([paramDict valueForKey:PARAM_USER_CREDENTIALS] || _storeThisCard){
        [self displayStoreCardOption];
        if(_storeThisCard){
            [self checkboxSelected:nil];
        }
    }*/

    
}
-(void)viewWillAppear:(BOOL)animated{
    NSDictionary *paramDict = [[SharedDataManager sharedDataManager] allInfoDict];
    _amountLbl.text = [NSString stringWithFormat:@"Rs. %.2f",[[paramDict objectForKey:PARAM_TOTAL_AMOUNT] floatValue]];
}


- (void) viewDidAppear:(BOOL)animated{
    if([[[SharedDataManager sharedDataManager] allInfoDict] valueForKey:PARAM_USER_CREDENTIALS] || _storeThisCard){
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
    if([paramDict objectForKey:PARAM_OFFER_KEY]){
        [postData appendFormat:@"%@=%@",PARAM_OFFER_KEY,[paramDict objectForKey:PARAM_OFFER_KEY]];
        [postData appendString:@"&"];
    }
    
    if(_checkBoxSelected){
        [postData appendFormat:@"%@=%@",PARAM_STORE_YOUR_CARD,[NSNumber numberWithInt:1]];
        [postData appendString:@"&"];
        if(![_storedCardMsg.text isEqualToString:@""]){
            [postData appendFormat:@"%@=%@",PARAM_STORE_CARD_NAME,_cardNameToStore.text];
            [postData appendString:@"&"];
        }
    }
    if(_isPaymentBeingDoneByRewardPoints){
        [postData appendFormat:@"%@=%@",PARAM_PG,CITI_REWARD_PG];
    }else{
        [postData appendFormat:@"%@=%@",PARAM_PG,CARD_TYPE];

    }
    [postData appendString:@"&"];
    
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
    if(![_cardCVV.text isEqualToString:@""]){
        [postData appendFormat:@"%@=%@",PARAM_CARD_CVV,_cardCVV.text];
        [postData appendString:@"&"];
    }
    else{
        [postData appendFormat:@"%@=%@",PARAM_CARD_CVV,@"999"];
        [postData appendString:@"&"];
    }
    if(_expMonth){
        [postData appendFormat:@"%@=%ld",PARAM_CARD_EXPIRY_MONTH,(long)_expMonth];
        [postData appendString:@"&"];
    }
    else{
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

    if(_isPaymentBeingDoneByRewardPoints){
        [postData appendFormat:@"%@=%@",PARAM_BANK_CODE,CITI_REWARD_BANK_CODE];
    }else{
        [postData appendFormat:@"%@=%@",PARAM_BANK_CODE,CARD_TYPE];
        
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


- (void) checkOfferKey:(NSString *) cardNumber{
    
    NSURL *restURL = [NSURL URLWithString:PAYU_PAYMENT_ALL_AVAILABLE_PAYMENT_OPTION];
    NSDictionary *paramDict = [[SharedDataManager sharedDataManager] allInfoDict];
    
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
        NSString *checkSumStr = [NSString stringWithFormat:@"%@|%@|%@|%@",[[[SharedDataManager sharedDataManager] allInfoDict] objectForKey:PARAM_KEY],PARAM_CHECK_OFFER_STATUS,[[[SharedDataManager sharedDataManager] allInfoDict] objectForKey:PARAM_OFFER_KEY],[[[SharedDataManager sharedDataManager] allInfoDict] objectForKey:PARAM_SALT]];
        checkSum = [Utils createCheckSumString:checkSumStr];

    NSString *postData = [NSString stringWithFormat:@"key=%@&command=%@&var1=%@&var2=%@&var3=%@&var4=%@&var5=%@&var6=%@&var7=%@&var8=%@&device_type=%@&hash=%@",[paramDict valueForKey:PARAM_KEY],PARAM_CHECK_OFFER_STATUS,[paramDict valueForKey:PARAM_OFFER_KEY],[paramDict valueForKey:PARAM_TOTAL_AMOUNT],CARD_TYPE, CARD_TYPE, cardNumber,@"",@"",@"",PARAM_DEVICE_TYPE,checkSum];
    
    //set request content type we MUST set this value.
    [theRequest setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    //set post data of request
    [theRequest setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSOperationQueue *networkQueue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:theRequest queue:networkQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSError *errorJson = nil;
        if(data){
            NSDictionary *offerResponse = [[NSDictionary alloc]init];
            offerResponse = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&errorJson];
            NSLog(@"Offer Response : %@",offerResponse);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self displayNewTxnAmount:offerResponse];
            });
        }
    }];
}


-(void) displayNewTxnAmount:(NSDictionary *)offerResponse{
    
    NSDictionary *paramDict = [[SharedDataManager sharedDataManager] allInfoDict];
    
    if(offerResponse && [offerResponse valueForKey:PARAM_OFFER_DISCOUNT]){
        
        NSAttributedString * title =
        [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"Rs. %.2f",[[paramDict objectForKey:PARAM_TOTAL_AMOUNT] floatValue]]
                                        attributes:@{NSStrikethroughStyleAttributeName:@(NSUnderlineStyleSingle),NSStrikethroughColorAttributeName: [UIColor redColor]}];
        [_amountLbl setAttributedText:title];
        
        float transactionAmoundAfterDiscount = [[paramDict valueForKey:PARAM_TOTAL_AMOUNT] floatValue];
        transactionAmoundAfterDiscount = transactionAmoundAfterDiscount - [[offerResponse valueForKey:PARAM_OFFER_DISCOUNT] floatValue];
        //[paramDict setValue:[NSString stringWithFormat:@"%f",transactionAmoundAfterDiscount] forKey:PARAM_TOTAL_AMOUNT];
        
        CGRect frame = _amountLbl.frame;
        
        //frame = _amountLbl.frame;
        frame.origin.y = frame.origin.y + frame.size.height;
        self.DiscountedAmntLbl = [[UILabel alloc] initWithFrame:frame];
        self.DiscountedAmntLbl.text = [NSString stringWithFormat:@"Rs. %.2f",transactionAmoundAfterDiscount];
        self.DiscountedAmntLbl.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:self.DiscountedAmntLbl];
        
    }
    
}
-(void) removeDiscountedAmntLbl
{
    _amountLbl.text = [NSString stringWithFormat:@"Rs. %.2f",[[_paramDict objectForKey:PARAM_TOTAL_AMOUNT] floatValue]];
    //[self.view addSubview:self.DiscountedAmntLbl];
    [self.DiscountedAmntLbl removeFromSuperview];
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
            [self removeDiscountedAmntLbl];
        } else {
            _isCardNumberValid = [CardValidation luhnCheck:_cardNum];
            
            if (_isCardNumberValid) {
                NSString *bankName = [[SharedDataManager sharedDataManager] checkCardDownTime:[_cardNum substringToIndex:6]];
                if(bankName)
                {
                    NSLog(@"List Of down bank bins =%@",[[SharedDataManager sharedDataManager] listOfDownCardBins]);
                    CGRect frame =  CGRectMake(_amountLbl.frame.origin.x, (_containerView1.frame.origin.y )-(_amountLbl.frame.size.height+15), self.view.frame.size.width-16,_amountLbl.frame.size.height+30);
                    _downTimeMsgLbl = [Utils customLabelWithString:[NSString stringWithFormat:DOWN_TIME_MESSAGE,bankName] andFrame:frame];
                    [self.view addSubview:_downTimeMsgLbl];
                }
                NSDictionary *paramDict = [[SharedDataManager sharedDataManager] allInfoDict];
                if([paramDict valueForKey:PARAM_OFFER_KEY]){
                    [self checkOfferKey:_cardNum];
                }
              }
            else {
                [self removeDiscountedAmntLbl];
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
        NSLog(@"Name on Card = %@",_cardName);
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

-(void) enableDisablePayNowButton{
    if(_isCardNumberValid && _isNameOnCardValid && _isExpiryDateValid && _isCvvNumberValid){
        NSLog(@"Card No, Name on card, expiry and cvv entered valid, payNow button is enable");
        _payNowBtn.enabled = YES;
        [_payNowBtn setBackgroundColor:[UIColor colorWithRed:89.0/255.0 green:193/255.0 blue:0 alpha:1]];
    } else if (_isCardNumberValid && _isNameOnCardValid && _isCardSBIMestro){
        NSLog(@"Card No, Name on card entered valid and it is a SBI Maestro, payNow button is enable");
        _payNowBtn.enabled = YES;
        [_payNowBtn setBackgroundColor:[UIColor colorWithRed:89.0/255.0 green:193/255.0 blue:0 alpha:1]];
    }
    else{
        NSLog(@"Something CardNum = %@ or Card Name = %@ is not valid , payNow button is disable _isCardNumberValid = %d, _isNameOnCardValid = %d _isCardSBIMestro = %d",_cardNum,_cardName,_isCardNumberValid,_isNameOnCardValid,_isCardSBIMestro);
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
//    _isExpiryDateValid = YES;
    
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        [self resignAllFromFirstRespon];
    } completion:^(BOOL finished) {
        [self.view addSubview:_datePickerContainerView];
    }];
}

- (void) doneButtonClick{
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
        CGRect frame = _payNowBtn.frame;
        CGSize result = [[UIScreen mainScreen] bounds].size;
        if(result.height == IPHONE_3_5)
        {
            frame = CGRectMake(_checkbox.frame.origin.x, _checkbox.frame.origin.y+5+ _checkbox.frame.size.height, self.view.frame.size.width - 16, 30);
        }
        else
        {
            frame = CGRectMake(8, _checkbox.frame.size.height + 10, result.width - 16, 30);
        }
        
        _cardNameToStore= [[UITextField alloc] initWithFrame:frame];
        _cardNameToStore.borderStyle = UITextBorderStyleNone;
        _cardNameToStore.font = [UIFont systemFontOfSize:12];
        _cardNameToStore.placeholder = @" Enter Card Name";
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
        if(result.height == IPHONE_3_5){
            frame.origin.y = frame.origin.y + _cardNameToStore.frame.size.height + 5;
        }
        else{
            frame.origin.y = frame.origin.y + _cardNameToStore.frame.size.height + 3;
        }
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            _payNowBtn.frame = frame;
            
        } completion:^(BOOL finished) {
            if(result.height == IPHONE_3_5)
            {
                [_containerView1 addSubview:_cardNameToStore];
            }
            else{
                [_containerView2 addSubview:_cardNameToStore];
                
            }
        }];
        
        
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
    [_containerView1 addSubview:_msgLbl];
    [_containerView1 addSubview:_button];
}

- (void) buttonClicked :(UIButton *) aButton{
    [self hideAndShowView:NO];
    _cvvLength = 3;
    _msgLbl.hidden = YES;
    _button.hidden = YES;
    _button.enabled = NO;
    //_cardCVV.enabled = YES;
    _msgLbl = nil;
    _button = nil;
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
        
    [self updateVarsForTextField:textField withString:nil];
    [self checkEnteredInfo:textField isFocused:NO];
    [self enableDisablePayNowButton];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if(_datePickerContainerView){
        [_datePickerContainerView removeFromSuperview];
        _cardExpiryDate.enabled = YES;
    }
    
    if([textField isEqual:_cardNumber] && _downTimeMsgLbl)
    [_downTimeMsgLbl removeFromSuperview];
    
    CGSize result = [[UIScreen mainScreen] bounds].size;
    if((![textField isEqual:_cardNumber]) || (result.height == IPHONE_3_5))
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
    
    if([textField isEqual:_cardNameToStore]){
        _firstResponderTextField = textField;
        NSLog(@"textFieldShouldReturn : Its IPHONE 5 device");
    }
    else{
        _firstResponderTextField = nil;
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
     NSLog(@"textFieldShouldReturn");
    if (textField == _cardNumber) {
        [_nameOnCard becomeFirstResponder];
    }
    else if (textField == _nameOnCard) {
        [_cardCVV becomeFirstResponder];
    }
    else if (textField == _cardCVV) {
        [textField resignFirstResponder];
    }
    else if(textField == _cardNameToStore){
        [textField resignFirstResponder];
    }
    return YES;
}


- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{

    NSString *trimmedText = [CardValidation removeEmptyCharsFromString:textField.text];
    BOOL isValid = YES;
    
    if([string isEqualToString:@""]){
        trimmedText = [textField.text substringToIndex:textField.text.length-1];
    }
    else{
        trimmedText  = [NSString stringWithFormat:@"%@%@",textField.text,string];
    }
    
    // cvv
    if (trimmedText.length > _cvvLength && [textField isEqual:_cardCVV] && ![string isEqualToString:@""]) {
        isValid = NO;
    } else if (trimmedText.length > 19 && [textField isEqual:_cardNumber] && ![string isEqualToString:@""]) {
        isValid = NO;
    } else if (trimmedText.length > 29 && [textField isEqual:_nameOnCard] && ![string isEqualToString:@""]) {
        isValid = NO;
    }
    
    NSString *cardNumStr = nil;
    if([string isEqualToString:@""]){
        cardNumStr = [textField.text substringToIndex:textField.text.length-1];
    }
    else{
        cardNumStr  = [NSString stringWithFormat:@"%@%@",textField.text,string];
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
    
    if(cardNumStr.length < 5)
//    if(trimmedText.length > 0)
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
        if([_cardNameToStore isEqual:_firstResponderTextField]){
            sizeToDiscreaseFromCenter = 200.0f;
        }
        else{
            sizeToDiscreaseFromCenter = 140.0f;
        }
    }
    else if(IPHONE_4 == result.height)
    {
        if([_cardNameToStore isEqual:_firstResponderTextField]){
            sizeToDiscreaseFromCenter = 200.0f;
            NSLog(@"Its IPHONE 5 device");
        }
        else{
            sizeToDiscreaseFromCenter = 170.0f;
        }
    }
    else if(IPHONE_4_7 == result.height){
        sizeToDiscreaseFromCenter = 100.0f;
    }
    else{
        sizeToDiscreaseFromCenter = 80.0f;
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
    
}


@end
