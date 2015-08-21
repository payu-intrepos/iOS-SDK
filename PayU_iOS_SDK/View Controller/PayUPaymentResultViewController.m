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




@interface PayUPaymentResultViewController () <UIWebViewDelegate>

//@property WebViewJavascriptBridge* bridge;

@property (unsafe_unretained, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
//@property (unsafe_unretained, nonatomic) IBOutlet UILabel *processingLbl;
@property (unsafe_unretained, nonatomic) IBOutlet UIWebView *resultWebView;

@property (strong,nonatomic) UIView *transparentView;
@property (nonatomic,strong) NSArray *pgUrlList;
//@property (nonatomic,strong) CBConnectionHandler *handler;
@property (nonatomic,strong) NSString *loadingUrl;

@property (nonatomic,strong) CustomActivityIndicator *customIndicator;

@property (nonatomic,assign) float y;

@property (nonatomic,assign) BOOL isBankFound;
@property (nonatomic,assign) BOOL isWebViewLoadFirstTime;


@end

@implementation PayUPaymentResultViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    _pgUrlList = @[@"https://mobiletest.payu.in/paytxn", @"https://mobiletest.payu.in/_payment", @"https://test.payu.in/paytxn",@"https://test.payu.in/_seamless_payment", @"https://secure.payu.in/_seamless_payment", @"https://secure.payu.in/paytxn", @"https://secure.payu.in/_payment", @"https://secure.payu.in/paytxn", @"https://mpi.onlinesbi.com/electraSECURE/vbv/MPIEntry.jsp", @"https://mpi.onlinesbi.com/electraSECURE/vbv/MPIEntry.jsp", @"https://www.citibank.co.in/servlets/TransReq", @"https://www.citibank.co.in/servlets/PgTransResp", @"https://vpos.amxvpos.com/vpcpay", @"https://ubimpi.electracard.com/electraSECURE/vbv/MPIEntry.jsp", @"https://ubimpi.electracard.com/electraSECURE/vbv/MPIEntry.jsp", @"https://ubimpi.electracard.com/electraSECURE/vbv/MPIACSResponse.jsp", @"https://secure.payu.in/ubi_pg_response.php"];
    
    _activityIndicator.stopAnimating;
    _activityIndicator.hidden=true;
    
    _isBankFound = NO;
    if(_isBackOrDoneNeeded){
        
        if(64 != _y){
            
            
        }
        else{
            //Dissable back button
            //[self.navigationItem setHidesBackButton:YES animated:YES];
            
        }
    }
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
        
        //        [_processingLbl removeConstraints:_processingLbl.constraints];
        //        _processingLbl.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        //        _processingLbl.translatesAutoresizingMaskIntoConstraints = YES;
        
        
        CGRect frame = [[UIScreen mainScreen] bounds];
        frame.origin.y = _y;
        frame.size.height = frame.size.height - _y;
        _resultWebView.frame = frame;
        
        /*frame = _activityIndicator.frame;
         frame.origin.x = self.view.frame.size.width/2  - frame.size.width+10;
         frame.origin.y = self.view.frame.size.height/2 - frame.size.height-100;
         _activityIndicator.frame = frame;*/
        
        //        frame = _processingLbl.frame;
        //        frame.origin.x = self.view.frame.size.width/2  - frame.size.width + 60;
        //        frame.origin.y = self.view.frame.size.height/2 - frame.size.height - 80;
        //        _processingLbl.frame = frame;
        
    }
    //    [_activityIndicator removeConstraints:_activityIndicator.constraints];
    //    _activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    //    _activityIndicator.translatesAutoresizingMaskIntoConstraints = YES;
    //    //_activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    //    _activityIndicator.center=self.view.center;
    //    _activityIndicator.hidden = YES;
    //
    //    _activityIndicator.center=self.view.center;
    
    CGRect frame = [[ UIScreen mainScreen] bounds];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        NSLog(@"iOS :8");
        //initializeJSStr = [initializeJSStr stringByReplacingOccurrencesOfString:@"[name=frmAcsOption]" withString:@""];
        _customIndicator = [[CustomActivityIndicator alloc] initWithFrame:CGRectMake((frame.size.width-250)/2,(frame.size.height-200)/2, 250, 200)];
        
        _transparentView = [[UIView alloc] initWithFrame:frame];
        _transparentView.backgroundColor = [UIColor grayColor];
        _transparentView.alpha = 0.5f;
        _transparentView.opaque = NO;
        [self.view addSubview:_transparentView];
        
        [self.view addSubview:_customIndicator];
        [self.view bringSubviewToFront:_customIndicator];
    }
    
    
    //[self startStopIndicator:YES];
    //    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")){
    //        [self loadJavascript];
    //    }
    _resultWebView.scalesPageToFit = NO;
    //    _resultWebView.layer.borderWidth = 1;
    //    _resultWebView.layer.borderColor = [UIColor redColor].CGColor;
    
    _resultWebView.opaque = NO;
    _resultWebView.backgroundColor = [UIColor clearColor];
    
    //to display contant in webview from top.
    [[_resultWebView scrollView] setContentInset:UIEdgeInsetsMake(-64, 0, 0, 0)];
    
}



//{
//    ALog(@"");
//    [super viewDidLoad];
//
//    _isBankFound = NO;
//    if(_isBackOrDoneNeeded){
//
//        if(64 != _y){
//
//
//        }
//        else{
//            //Dissable back button
//            //[self.navigationItem setHidesBackButton:YES animated:YES];
//
//        }
//    }
//    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
//        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
//    }
//
//    if(_flag){
//
//        _y = 64;
//        NSLog(@"UI SHould be according to 3_5 inch");
//        [self.view removeConstraints:self.view.constraints];
//        [_resultWebView removeConstraints:_resultWebView.constraints];
//        _resultWebView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
//        _resultWebView.translatesAutoresizingMaskIntoConstraints = YES;
//
//        [_processingLbl removeConstraints:_processingLbl.constraints];
//        _processingLbl.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
//        _processingLbl.translatesAutoresizingMaskIntoConstraints = YES;
//
//
//        CGRect frame = [[UIScreen mainScreen] bounds];
//        frame.origin.y = _y;
//        frame.size.height = frame.size.height - _y;
//        _resultWebView.frame = frame;
//
//        /*frame = _activityIndicator.frame;
//         frame.origin.x = self.view.frame.size.width/2  - frame.size.width+10;
//         frame.origin.y = self.view.frame.size.height/2 - frame.size.height-100;
//         _activityIndicator.frame = frame;*/
//
//        frame = _processingLbl.frame;
//        frame.origin.x = self.view.frame.size.width/2  - frame.size.width + 60;
//        frame.origin.y = self.view.frame.size.height/2 - frame.size.height - 80;
//        _processingLbl.frame = frame;
//
//    }
//    [_activityIndicator removeConstraints:_activityIndicator.constraints];
//    _activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
//    _activityIndicator.translatesAutoresizingMaskIntoConstraints = YES;
//    //_activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//    _activityIndicator.center=self.view.center;
//    _activityIndicator.hidden = NO;
//
//    _activityIndicator.center=self.view.center;
//
//    CGRect frame = [[ UIScreen mainScreen] bounds];
//
//    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
//        NSLog(@"iOS :8");
//        //initializeJSStr = [initializeJSStr stringByReplacingOccurrencesOfString:@"[name=frmAcsOption]" withString:@""];
//        _customIndicator = [[CustomActivityIndicator alloc] initWithFrame:CGRectMake((frame.size.width-250)/2,(frame.size.height-200)/2, 250, 200)];
//
//        _transparentView = [[UIView alloc] initWithFrame:frame];
//        _transparentView.backgroundColor = [UIColor grayColor];
//        _transparentView.alpha = 0.5f;
//        _transparentView.opaque = NO;
//        [self.view addSubview:_transparentView];
//
//        [self.view addSubview:_customIndicator];
//        [self.view bringSubviewToFront:_customIndicator];
//}
//
//
//    //[self startStopIndicator:YES];
////    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")){
////        [self loadJavascript];
////    }
//        _resultWebView.scalesPageToFit = NO;
////    _resultWebView.layer.borderWidth = 1;
////    _resultWebView.layer.borderColor = [UIColor redColor].CGColor;
//
//    _resultWebView.opaque = NO;
//    _resultWebView.backgroundColor = [UIColor clearColor];
//
//    //to display contant in webview from top.
//    [[_resultWebView scrollView] setContentInset:UIEdgeInsetsMake(-64, 0, 0, 0)];
//
//}

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
    
}

- (void)viewWillDisappear:(BOOL)animated {
    ALog(@"");
    [super viewWillDisappear:animated];
    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
        // back button was pressed.  We know this is true because self is no longer
        // in the navigation stack.
        [Utils startPayUNotificationForKey:PAYU_ERROR intValue:PBackButtonPressed object:nil];
    }
    
    //    [[NSNotificationCenter defaultCenter] removeObserver:_handler forKeyPath:UIKeyboardDidHideNotification];
    //    [[NSNotificationCenter defaultCenter] removeObserver:_handler forKeyPath:UIKeyboardDidShowNotification];
    //_handler = nil;
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

//-(void) startStopIndicator:(BOOL) aFlag{
////    NSLog(@"");
////    if(aFlag){
////        [self.view bringSubviewToFront:_activityIndicator];
////        [_activityIndicator startAnimating];
////    }
////    else
////        [_activityIndicator stopAnimating];
//
// //   _processingLbl.hidden = !aFlag;
//}

//-(void) getPGUrlList{
//
//    if(_handler){
//        NSString *pgUrlListStr = [_handler.initializeJavascriptDict valueForKey:PG_URL_LIST];
//        _pgUrlList = [pgUrlListStr componentsSeparatedByString:@"||"];
//        NSLog(@"PG URL LIST = %@",_pgUrlList);
//    }
//}

//- (void) removeCBOnRetryPage:(NSString *)urlStr
//{
//    NSRange range = [urlStr rangeOfString:CB_RETRY_PAYMENT_OPTION_URL options:NSCaseInsensitiveSearch];
//    if(range.location != NSNotFound){
//        [_handler closeCB];
//        [self adjustWebViewHeight:NO];
//    }
//}

//-(void) matchUrl:(NSString *)urlStr{
//    BOOL isUrlMatchFound = NO;
//    for(NSString *pgUrl in _pgUrlList){
//        if([urlStr isEqualToString:pgUrl] || [urlStr rangeOfString:pgUrl options:NSCaseInsensitiveSearch].location != NSNotFound){
//            isUrlMatchFound = YES;
//        }
//    }
//
////    if(!isUrlMatchFound && _pgUrlList && !_resultWebView.loading){
////        NSLog(@"URL Match Found not Found");
////        [_customIndicator removeFromSuperview];
////        [_transparentView removeFromSuperview];
////    }
//}


#pragma mark - WebView delegate

-(void)webViewDidStartLoad:(UIWebView *)webView{
    NSLog(@"webviewstart zxc %@",webView.request.HTTPBody);
    NSLog(@"webviewstart zxc %@",webView.request.URL);
}

- (void)webViewDidFinishLoad:(UIWebView *)webView;
{
    //int status = [[[webView request] valueForHTTPHeaderField:@"Status"] intValue];
    
    NSLog(@"webViewDidFinishLoad zxc %@",[[webView request] valueForHTTPHeaderField:@"Status"]);
    NSCachedURLResponse *resp = [[NSURLCache sharedURLCache] cachedResponseForRequest:webView.request];
    NSLog(@"status code: %ld", (long)[(NSHTTPURLResponse*)resp.response statusCode]);
    NSLog(@"");
    
    //if ((long)[(NSHTTPURLResponse*)resp.response statusCode] == 0)
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
    //    _resultWebView.scalesPageToFit = NO;
    //  [self startStopIndicator:NO];
    
    //    if(!_isBankFound){
    //        [self getPGUrlList];
    //        [_handler runIntializeJSOnWebView];
    //    }
    //    else{
    //        [_handler runBankSpecificJSOnWebView];
    //    }
    
    //    [self matchUrl:_loadingUrl];
    //[self removeCBOnRetryPage:_loadingUrl];
    
    if ([[webView stringByEvaluatingJavaScriptFromString:@"document.readyState"] isEqualToString:@"complete"]) {
        NSLog(@"Pageloaded completely-------");
        
        // UIWebView object has fully loaded.
    }
    if (!webView.isLoading) {
        NSLog(@"webView.isLoading-------");
        
    }
    
    //    if () {
    //        <#statements#>
    //    }
    //
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error;
{
    NSLog(@"webViewdidFailLoadWithError zxc");
    
    NSLog(@"%@",webView.request.URL);
    NSLog(@"%@",error);
    //[self startStopIndicator:NO];
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)naavigationType {
    NSLog(@"webViewshouldStartLoadWithRequest zxc");
    
    //    if (_handler) {
    //        NSLog(@"_handler closeCB");
    //        [_handler closeCB];
    //    } else {
    //        NSLog(@"Error: _handler NIL");
    //    }
    //
    //[self startStopIndicator:YES];
    
    NSURL *url = request.URL;
    NSLog(@"finallyCalled = %@",url);
    
    //[self matchUrl:url.absoluteString];
    _loadingUrl = url.absoluteString;
    
    if ([[url scheme] isEqualToString:@"ios"]) {
        // [self startStopIndicator:NO];
        
        NSString *responseStr = [url  absoluteString];
        NSString *search = @"success";
        
        if([responseStr rangeOfString:search options:NSCaseInsensitiveSearch].location != NSNotFound){
            NSDictionary *InfoDict = [NSDictionary dictionaryWithObject:responseStr forKey:INFO_DICT_RESPONSE];
            [[NSNotificationCenter defaultCenter] postNotificationName:PAYMENT_SUCCESS_NOTIFICATION object:InfoDict];
            NSLog(@"success block with infoDict = %@",InfoDict);
            
        }
        
        search = @"failure";
        if([responseStr rangeOfString:search options:NSCaseInsensitiveSearch].location != NSNotFound){
            NSDictionary *InfoDict = [NSDictionary dictionaryWithObject:responseStr forKey:INFO_DICT_RESPONSE];;
            [[NSNotificationCenter defaultCenter] postNotificationName:PAYMENT_FAILURE_NOTIFICATION object:InfoDict];
            NSLog(@"failure block with infoDict = %@",InfoDict);
            
        }
        search = @"cancel";
        
        if([responseStr rangeOfString:search options:NSCaseInsensitiveSearch].location != NSNotFound){
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

// Reachability methods
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
    [[[UIAlertView alloc] initWithTitle:@"Confirmation" message:@"Do you want to cancel this transaction?"
                               delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil] show];
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


#pragma mark - JavaScript delegate

//-(void) runIntializeJSOnWebView{
//    NSLog(@"");
//    /****-------------Setting JavScript Context-----------***/
//    /*if(!_isBankFound){
//        // get JSContext from UIWebView instance
//        JSContext *context = [_resultWebView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
//
//        // enable error logging
//        [context setExceptionHandler:^(JSContext *context, JSValue *value) {
//            NSLog(@"WEB JS: %@", value);
//        }];
//
//        // give JS a handle to our PayUPaymentResultViewController(self) instance
//        context[@"PayU"] = _handler;
//
////        [context evaluateScript:[_handler.initializeJavascriptDict valueForKey:DETECT_BANK_KEY]];
//        NSString *initializeJSStr = [[_handler.initializeJavascriptDict valueForKey:DETECT_BANK_KEY]
//                                     stringByReplacingOccurrencesOfString:@"\\" withString:@""];
//        initializeJSStr = [initializeJSStr stringByReplacingOccurrencesOfString:@"\"" withString:@"'"];
//        [initializeJSStr stringByAppendingString:@";"];
//        NSLog(@"initializeJSStr = %@",[initializeJSStr stringByAppendingString:@";"]);
//        [context evaluateScript:[initializeJSStr stringByAppendingString:@";"]];
////        [context evaluateScript:initializeJSStr];
//    }*/
//    if(!_isBankFound)
//    [_handler runIntializeJSOnWebView];
//
//
//}


//-(void) loadJavascript{
////    if (!PRODUCTION_OR_TEST_MODE) {
//        // create Connection handler
//        if(!_handler){
//            _handler = [[CBConnectionHandler alloc] init];
//            _handler.connectionHandlerDelegate = self;
//            _handler.resultView = self.view;
//            _handler.resultWebView = _resultWebView;
//            _handler.resultViewController = self;
//        }
//        [_handler downloadInitializeJS];
////    }
//}

#pragma mark - CBConnectionHandler Delegate

/* These are CBConnectionHandler Delegate methods
 - (void) bankSpecificJSDownloded;
 - (void) bankNameFound:(NSString *) bankName;
 - (void) adjustWebViewHeight:(BOOL) upOrDown;
 - (void) addViewInResultView:(UIView *) aView;
 - (void) removePayUActivityIndicator;
 */

//- (void)removePayUActivityIndicator{
//    [_customIndicator removeFromSuperview];
//}

//- (void) bankSpecificJSDownloded{
//    NSLog(@"bankSpecificJSDownloded");
//}

//- (void) bankNameFound:(NSString *) bankName{
//    NSLog(@"BankName = %@ ",bankName);
//    _isBankFound = YES;
//}
//
//- (void) adjustWebViewHeight:(BOOL) upOrDown
//{
//    NSLog(@"upOrDown: %d",upOrDown);
//    //__block CGRect webViewFrame = CGRectZero;
//
//    dispatch_async(dispatch_get_main_queue(), ^{
//
//        if(upOrDown){
//            CGRect webViewFrame = CGRectZero;
//            NSLog(@"WebViewFrame without updates = %@",NSStringFromCGRect(_resultWebView.frame));
//            [_resultWebView removeConstraints:_resultWebView.constraints];
//            //_resultWebView.scalesPageToFit = YES;
//            webViewFrame = _resultWebView.frame;
//            webViewFrame.size.height = webViewFrame.size.height - 227;
//            _resultWebView.frame = webViewFrame;
//            NSLog(@"WebViewFrame when CB is on Screen = %@",NSStringFromCGRect(_resultWebView.frame));
//        }
//        else{
//            CGRect webViewFrame = CGRectZero;
//            NSLog(@"WebViewFrame without updates = %@",NSStringFromCGRect(_resultWebView.frame));
//            [_resultWebView removeConstraints:_resultWebView.constraints];
//            //_resultWebView.scalesPageToFit = NO;
//            webViewFrame = _resultWebView.frame;
//            webViewFrame.size.height = webViewFrame.size.height + 227;
//            _resultWebView.frame = webViewFrame;
//            NSLog(@"WebViewFrame when CB is off Screen = %@",NSStringFromCGRect(_resultWebView.frame));
//
//        }
//    });
//}

//- (void) addViewInResultView:(UIView *) aView{
//    NSLog(@"");
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self.view addSubview:aView];
//        [aView setNeedsDisplay];
//    });
//
//}



#pragma mark - Keyboard Handling
/*- (void)keyboardDidShow:(NSNotification *)notification
 {
 _resultWebView.scalesPageToFit = NO;
 CGRect thisViewFrame = self.view.frame;
 thisViewFrame.origin.y = thisViewFrame.origin.y - 216;
 NSLog(@"ResultViewController : keyboardDidShow");
 
 // Assign new center to your view
 [UIView animateWithDuration:0.2
 delay:0
 options: UIViewAnimationOptionCurveEaseIn
 animations:^{
 self.view.frame = thisViewFrame;
 }
 completion:^(BOOL finished) {
 }];
 }
 
 -(void)keyboardDidHide:(NSNotification *)notification
 {
 CGRect thisViewFrame = self.view.frame;
 thisViewFrame.origin.y = thisViewFrame.origin.y + 216;
 NSLog(@"ResultViewController : keyboardDidHide");
 
 // Assign original center to your view
 [UIView animateWithDuration:0.2
 delay:0
 options: UIViewAnimationOptionCurveEaseIn
 animations:^{
 self.view.frame = thisViewFrame;
 }
 completion:nil];
 }
 */

@end