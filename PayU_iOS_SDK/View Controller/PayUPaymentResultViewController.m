//
//  PayUPaymentResultViewController.m
//  PayU_iOS_SDK
//
//  Created by Suryakant Sharma on 17/12/14.
//  Copyright (c) 2014 PayU, India. All rights reserved.
//

#import "PayUPaymentResultViewController.h"
#import "PayUConstant.h"
#import "Utils.h"
//#import "WebViewJavascriptBridge.h"
#import "SharedDataManager.h"
#import "Reachability.h"
#import "ReachabilityManager.h"

// ------------------- CB Import ----------------
//#import "CBConstant.h"
//#import "PayU_CB_SDK.h"
#define DETECT_BANK_KEY @"detectBank"
#define INIT  @"init"
#define CB_RETRY_PAYMENT_OPTION_URL @"https://secure.payu.in/_payment_options"
//#import "CBApproveView.h"
#import "CustomActivityIndicator.h"


#import "WebViewJavascriptBridge.h"


@interface PayUPaymentResultViewController () <UIWebViewDelegate>
@property WebViewJavascriptBridge* PayU;
@property (unsafe_unretained, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (unsafe_unretained, nonatomic) IBOutlet UIWebView *resultWebView;
@property (strong,nonatomic) UIView *transparentView;
@property (nonatomic,strong) NSArray *pgUrlList;
@property (nonatomic,strong) NSString *loadingUrl;
@property (nonatomic,strong) CustomActivityIndicator *customIndicator;
@property (nonatomic,assign) float y;
@property (nonatomic,assign) BOOL isBankFound;
@property (nonatomic,assign) BOOL isWebViewLoadFirstTime;
@property (nonatomic,strong) UIAlertView *alertView;
@end

@implementation PayUPaymentResultViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    _pgUrlList = @[@"https://mobiletest.payu.in/paytxn", @"https://test.payu.in/paytxn",@"https://test.payu.in/_seamless_payment", @"https://secure.payu.in/_seamless_payment", @"https://secure.payu.in/paytxn", @"https://secure.payu.in/paytxn", @"https://mpi.onlinesbi.com/electraSECURE/vbv/MPIEntry.jsp", @"https://mpi.onlinesbi.com/electraSECURE/vbv/MPIEntry.jsp", @"https://www.citibank.co.in/servlets/TransReq", @"https://www.citibank.co.in/servlets/PgTransResp", @"https://vpos.amxvpos.com/vpcpay", @"https://ubimpi.electracard.com/electraSECURE/vbv/MPIEntry.jsp", @"https://ubimpi.electracard.com/electraSECURE/vbv/MPIEntry.jsp", @"https://ubimpi.electracard.com/electraSECURE/vbv/MPIACSResponse.jsp", @"https://secure.payu.in/ubi_pg_response.php"];
    
    _activityIndicator.stopAnimating;
    _activityIndicator.hidden=true;
    
    _isBankFound = NO;
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    
    if(_flag){
        
        _y = 64;
        NSLog(@"UI SHould be according to 3_5 inch");
        [self.view removeConstraints:self.view.constraints];
        [_resultWebView removeConstraints:_resultWebView.constraints];
        _resultWebView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        _resultWebView.translatesAutoresizingMaskIntoConstraints = YES;
        CGRect frame = [[UIScreen mainScreen] bounds];
        frame.origin.y = _y;
        frame.size.height = frame.size.height - _y;
        _resultWebView.frame = frame;
        
    }
    CGRect frame = [[ UIScreen mainScreen] bounds];
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        NSLog(@"iOS :8");
        _customIndicator = [[CustomActivityIndicator alloc] initWithFrame:CGRectMake((frame.size.width-250)/2,(frame.size.height-200)/2, 250, 200)];
        
        _transparentView = [[UIView alloc] initWithFrame:frame];
        _transparentView.backgroundColor = [UIColor grayColor];
        _transparentView.alpha = 0.5f;
        _transparentView.opaque = NO;
        [self.view addSubview:_transparentView];
        
        [self.view addSubview:_customIndicator];
        [self.view bringSubviewToFront:_customIndicator];
    }
    _resultWebView.scalesPageToFit = NO;
    _resultWebView.opaque = NO;
    _resultWebView.backgroundColor = [UIColor clearColor];
    [[_resultWebView scrollView] setContentInset:UIEdgeInsetsMake(-64, 0, 0, 0)];
}
- (void)dealloc {
}
- (void)viewWillAppear:(BOOL)animated {
    ALog(@"");
    _y = 0.0;
    if ([self isBeingPresented]) {
        // being presented
        _y = 20;
        
    } else if ([self isMovingToParentViewController]) {
        // being pushed
        _y = 64;
    }
    _isWebViewLoadFirstTime = NO;
    //[self startStopIndicator:YES];
    
    // Reachability
    [ReachabilityManager sharedManager];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityDidChange:) name:payUReachabilityChangedNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appGoingInBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    _resultWebView.delegate = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [_resultWebView loadRequest:_request];
    });
    
    _PayU = [WebViewJavascriptBridge bridgeForWebView:_resultWebView webViewDelegate:self handler:^(id data, WVJBResponseCallback responseCallback)
             
             {
                 NSLog(@"ObjC received message from JS: %@", data);
                 if(data)
                 {
                     [[NSNotificationCenter defaultCenter] postNotificationName:@"passData" object:[NSMutableData dataWithData:data ]];
                     responseCallback(@"Response for message from ObjC");
                 }
                 
             }];
}
- (void)viewWillDisappear:(BOOL)animated {
    ALog(@"");
    [super viewWillDisappear:animated];
    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
        [Utils startPayUNotificationForKey:PAYU_ERROR intValue:PBackButtonPressed object:nil];
    }
}
- (void)viewDidLayoutSubviews{
    ALog(@"");
}
-(void) appGoingInBackground:(NSNotification *)notification{
    [self.view endEditing:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - WebView delegate
-(void)webViewDidStartLoad:(UIWebView *)webView{
    NSLog(@"webviewstart zxc %@",webView.request.HTTPBody);
    NSLog(@"webviewstart zxc %@",webView.request.URL);
}
- (void)webViewDidFinishLoad:(UIWebView *)webView;
{
    
    NSLog(@"webViewDidFinishLoad zxc %@",webView.request.URL);
    NSCachedURLResponse *resp = [[NSURLCache sharedURLCache] cachedResponseForRequest:webView.request];
    NSLog(@"status code: %ld", (long)[(NSHTTPURLResponse*)resp.response statusCode]);
    NSLog(@"");
    
    BOOL isUrlMatchFound = NO;
    for(NSString *pgUrl in _pgUrlList){
        if([_loadingUrl isEqualToString:pgUrl] || [_loadingUrl rangeOfString:pgUrl options:NSCaseInsensitiveSearch].location != NSNotFound){
            isUrlMatchFound = YES;
        }
    }
    if (!isUrlMatchFound && _pgUrlList && !webView.isLoading)
    {
        [_customIndicator removeFromSuperview];
        [_transparentView removeFromSuperview];
    }
    
    if ([[webView stringByEvaluatingJavaScriptFromString:@"document.readyState"] isEqualToString:@"complete"]) {
        NSLog(@"Pageloaded completely-------");
        
        // UIWebView object has fully loaded.
    }
    if (!webView.isLoading) {
        NSLog(@"webView.isLoading-------");
        
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error;
{
    NSLog(@"webViewdidFailLoadWithError zxc");
    
    NSLog(@"%@",webView.request.URL);
    NSLog(@"%@",error);
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)naavigationType {
    NSLog(@"webViewshouldStartLoadWithRequest zxc");
    NSURL *url = request.URL;
    NSLog(@"finallyCalled = %@",url);
    _loadingUrl = url.absoluteString;
    if ([[url scheme] isEqualToString:@"ios"]) {
        NSString *responseStr = [url  absoluteString];
        NSString *search = @"success";
        
        if([responseStr rangeOfString:search options:NSCaseInsensitiveSearch].location != NSNotFound){
            [self.alertView dismissWithClickedButtonIndex:0 animated:true];
            NSDictionary *InfoDict = [NSDictionary dictionaryWithObject:responseStr forKey:INFO_DICT_RESPONSE];
            [[NSNotificationCenter defaultCenter] postNotificationName:PAYMENT_SUCCESS_NOTIFICATION object:InfoDict];
            NSLog(@"success block with infoDict = %@",InfoDict);
            
        }
        search=@"success";
        if([responseStr rangeOfString:search options:NSCaseInsensitiveSearch].location != NSNotFound){
            [self.alertView dismissWithClickedButtonIndex:0 animated:true];
            NSDictionary *InfoDict = [NSDictionary dictionaryWithObject:responseStr forKey:INFO_DICT_RESPONSE];;
            [[NSNotificationCenter defaultCenter] postNotificationName:PAYMENT_FAILURE_NOTIFICATION object:InfoDict];
            NSLog(@"failure block with infoDict = %@",InfoDict);
        }
        search = @"cancel";
        if([responseStr rangeOfString:search options:NSCaseInsensitiveSearch].location != NSNotFound){
            [self.alertView dismissWithClickedButtonIndex:0 animated:true];
            NSDictionary *InfoDict = [NSDictionary dictionaryWithObject:responseStr forKey:INFO_DICT_RESPONSE];;
            [[NSNotificationCenter defaultCenter] postNotificationName:PAYMENT_CANCEL_NOTIFICATION object:InfoDict];
            NSLog(@"cancel block with infoDict = %@",InfoDict);
            
        }
    }
    if([url.absoluteString rangeOfString:CB_RETRY_PAYMENT_OPTION_URL options:NSCaseInsensitiveSearch].location != NSNotFound){
        //        [_handler removeIntermidiateLoader];
        //        [_handler closeCB];
        //        [_customIndicator removeFromSuperview];
        //        [_transparentView removeFromSuperview];
        
        
    }
    
    return YES;
}
-(void)navigateToRootViewController{
    NSLog(@"");
    [self.navigationController popToRootViewControllerAnimated:YES];
}
- (void)reachabilityDidChange:(NSNotification *)notification {
    Reachability *reach = [notification object];
    if ([reach isReachable]) {
    } else {
        [Utils startPayUNotificationForKey:PAYU_ERROR intValue:PInternetNotReachable object:self];
    }
}
#pragma mark - Back Button Handling

-(BOOL) navigationShouldPopOnBackButton
{
    self.alertView = [[UIAlertView alloc]initWithTitle:@"Confirmation" message:@"Do you want to cancel this transaction?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil] ;
    [self.alertView show];
    return NO;
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==1) {
        NSDictionary *InfoDict = [NSDictionary dictionaryWithObject:@"Transaction canceled due to back button pressed!" forKey:INFO_DICT_RESPONSE];
        [Utils startPayUNotificationForKey:PAYU_ERROR intValue:PBackButtonPressed object:InfoDict];
        NSLog(@"cancel block with infoDict = %@",InfoDict);
    }
}
@end