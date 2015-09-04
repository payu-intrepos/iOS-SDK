//
//  PayUCashCardViewController.m
//  PayU_iOS_SDK
//
//  Created by Suryakant Sharma on 20/01/15.
//  Copyright (c) 2015 PayU, India. All rights reserved.
//

#import "PayUCashCardViewController.h"
#import "PayUConstant.h"
#import "SharedDataManager.h"
#import "PayUPaymentResultViewController.h"
#import "Utils.h"
#import "PayUCardProcessViewController.h"

#define PG_TYPE @"CASH"


@interface PayUCashCardViewController () <UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,unsafe_unretained) IBOutlet UIButton *selectCashCard;
@property(nonatomic,unsafe_unretained) IBOutlet UIButton *payNow;

@property(nonatomic,unsafe_unretained) IBOutlet UIView *containerView;
@property(nonatomic,strong) UITableView *listOfBank;

@property (nonatomic,strong) NSURLConnection *connection;
@property (nonatomic,strong) NSMutableData *connectionSpecificDataObject;
@property (nonatomic,strong) NSMutableData *receivedData;

@property (nonatomic,assign) NSUInteger selectedBankIndex;
@property (nonatomic,strong) IBOutlet UILabel *amountLbl;


- (IBAction) payNow :(UIButton *)sender;


@end

@implementation PayUCashCardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //_payNow.enabled = NO;
    
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
    _selectedBankIndex = -1;
    
    _amountLbl.text = [NSString stringWithFormat:@"Rs. %.2f",[[[[SharedDataManager sharedDataManager] allInfoDict] objectForKey:PARAM_TOTAL_AMOUNT] floatValue]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(IBAction) selectCashCard :(UIButton *)sender{
    _payNow.hidden = YES;
    
    if(nil == _listOfBank){
        _listOfBank = [[UITableView alloc] initWithFrame:CGRectMake(sender.frame.origin.x, sender.frame.origin.y, sender.frame.size.width, sender.frame.size.height*4) style:UITableViewStylePlain];
        
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

- (IBAction) payNow :(UIButton *)sender{
    
    _payNow.enabled=NO;
    
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
    
    if([paramDict objectForKey:PARAM_FIRST_NAME]){
        [postData appendFormat:@"%@=%@",PARAM_FIRST_NAME,[paramDict objectForKey:PARAM_FIRST_NAME]];
        [postData appendString:@"&"];
    }
    if([paramDict objectForKey:PARAM_EMAIL]){
        [postData appendFormat:@"%@=%@",PARAM_EMAIL,[paramDict objectForKey:PARAM_EMAIL]];
        [postData appendString:@"&"];
    }
    
    if([_cashCardDetail[_selectedBankIndex] objectForKey:PARAM_BANK_CODE]){
        [postData appendFormat:@"%@=%@",PARAM_BANK_CODE,[_cashCardDetail[_selectedBankIndex] objectForKey:PARAM_BANK_CODE]];
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
    if([paramDict objectForKey:PARAM_OFFER_KEY]){
        [postData appendFormat:@"%@=%@",PARAM_OFFER_KEY,[paramDict objectForKey:PARAM_OFFER_KEY]];
        [postData appendString:@"&"];
    }
    
    /// user defined fields
    if([paramDict objectForKey:PARAM_UDF_1]){
        [postData appendFormat:@"%@=%@",PARAM_UDF_1,[paramDict objectForKey:PARAM_UDF_1]];
        [postData appendString:@"&"];
    }
    else{
        [postData appendFormat:@"%@=%@",PARAM_UDF_1,@""];
        [postData appendString:@"&"];
    }
    if([paramDict objectForKey:PARAM_UDF_2]){
        [postData appendFormat:@"%@=%@",PARAM_UDF_2,[paramDict objectForKey:PARAM_UDF_2]];
        [postData appendString:@"&"];
    }
    else{
        [postData appendFormat:@"%@=%@",PARAM_UDF_2,@""];
        [postData appendString:@"&"];
    }
    if([paramDict objectForKey:PARAM_UDF_3]){
        [postData appendFormat:@"%@=%@",PARAM_UDF_3,[paramDict objectForKey:PARAM_UDF_3]];
        [postData appendString:@"&"];
    }
    else{
        [postData appendFormat:@"%@=%@",PARAM_UDF_3,@""];
        [postData appendString:@"&"];
    }
    if([paramDict objectForKey:PARAM_UDF_4]){
        [postData appendFormat:@"%@=%@",PARAM_UDF_4,[paramDict objectForKey:PARAM_UDF_4]];
        [postData appendString:@"&"];
    }
    else{
        [postData appendFormat:@"%@=%@",PARAM_UDF_4,@""];
        [postData appendString:@"&"];
    }
    if([paramDict objectForKey:PARAM_UDF_5]){
        [postData appendFormat:@"%@=%@",PARAM_UDF_5,[paramDict objectForKey:PARAM_UDF_5]];
        [postData appendString:@"&"];
    }
    else{
        [postData appendFormat:@"%@=%@",PARAM_UDF_5,@""];
        [postData appendString:@"&"];
    }

    
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
        checkSum = [Utils createCheckSumString:hashValue];
        NSLog(@"Hash String = %@ hashvalue = %@",hashValue,checkSum);
    }
    else{
        if ([[[SharedDataManager sharedDataManager] hashDict] valueForKey:PAYMENT_HASH_OLD]) {
            checkSum = [[[SharedDataManager sharedDataManager] hashDict] valueForKey:PAYMENT_HASH_OLD];
        } else {
            checkSum = [[[SharedDataManager sharedDataManager] hashDict] valueForKey:PAYMENT_HASH];
        }
    }
    
    [postData appendFormat:@"%@=%@",PARAM_HASH,checkSum];
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
        
        
        _payNow.hidden=YES;

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

#pragma mark - TableView DataSource


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if((_cashCardDetail.count==1)||(_cashCardDetail.count==2)||(_cashCardDetail.count==3)||(_cashCardDetail.count==4)||(_cashCardDetail.count==5)||(_cashCardDetail.count==6))
    {
        
        _payNow.hidden=YES;
    }

    
    
    return 44.0;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _cashCardDetail.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellIdentifier = @"cellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text = [[_cashCardDetail objectAtIndex:indexPath.row] valueForKey:@"title"];
    
    return cell;
}

#pragma mark - TableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    _payNow.enabled = YES;
   // _payNow.backgroundColor = [UIColor colorWithRed:89.0/255.0 green:193/255.0 blue:0 alpha:1];
    _selectedBankIndex = indexPath.row;
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        _listOfBank.alpha = 0.0f;
        [_selectCashCard setTitle:[[_cashCardDetail objectAtIndex:indexPath.row] valueForKey:@"title"] forState:UIControlStateNormal];
    } completion:^(BOOL finished) {
        [_listOfBank removeFromSuperview];
        
        // In case of Citi reward points launch credit card payment option.
        if([[[_cashCardDetail objectAtIndex:indexPath.row] valueForKey:@"title"] isEqualToString:@"Citibank Reward Points"]){
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
            cardProcessCV.isPaymentBeingDoneByRewardPoints = YES;
            cardProcessCV.appTitle = _appTitle;
            _payNow.hidden=NO;

            [self.navigationController pushViewController:cardProcessCV animated:YES];
        }
    }];
    
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor colorWithRed:240.0/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:1.0f];
}


@end
