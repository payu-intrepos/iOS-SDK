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
#import "SharedDataManager.h"
#import "Reachability.h"
#import "ReachabilityManager.h"

// ------------------- CB Import ----------------
#import "CBApproveView.h"
#import "CustomActivityIndicator.h"
#import "CBConstant.h"
#import "PayU_CB_SDK.h"
#define DETECT_BANK_KEY @"detectBank"
#define INIT  @"init"


@interface PayUPaymentResultViewController () <UIWebViewDelegate,CBConnectionHandlerDelegate>

@property (unsafe_unretained, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *processingLbl;
@property (unsafe_unretained, nonatomic) IBOutlet UIWebView *resultWebView;

@property (strong,nonatomic) UIView *transparentView;
@property (nonatomic,strong) NSArray *pgUrlList;
@property (nonatomic,strong) CBConnectionHandler *handler;
@property (nonatomic,strong) NSString *loadingUrl;

@property (nonatomic,strong) CustomActivityIndicator *customIndicator;

@property (nonatomic,assign) float y;

@property (nonatomic,assign) BOOL isBankFound;
@property (nonatomic,assign) BOOL isWebViewLoadFirstTime;


@end

@implementation PayUPaymentResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
        
        //_y = 64;
        NSLog(@"UI SHould be according to 3_5 inch");
        [self.view removeConstraints:self.view.constraints];
        [_resultWebView removeConstraints:_resultWebView.constraints];
        _resultWebView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        _resultWebView.translatesAutoresizingMaskIntoConstraints = YES;
        
        [_processingLbl removeConstraints:_processingLbl.constraints];
        _processingLbl.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        _processingLbl.translatesAutoresizingMaskIntoConstraints = YES;
        
        
        CGRect frame = [[UIScreen mainScreen] bounds];
        frame.origin.y = _y;
        frame.size.height = frame.size.height - _y;
        _resultWebView.frame = frame;
        
        /*frame = _activityIndicator.frame;
         frame.origin.x = self.view.frame.size.width/2  - frame.size.width+10;
         frame.origin.y = self.view.frame.size.height/2 - frame.size.height-100;
         _activityIndicator.frame = frame;*/
        
        frame = _processingLbl.frame;
        frame.origin.x = self.view.frame.size.width/2  - frame.size.width + 60;
        frame.origin.y = self.view.frame.size.height/2 - frame.size.height - 80;
        _processingLbl.frame = frame;
        
    }
    [_activityIndicator removeConstraints:_activityIndicator.constraints];
    _activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    _activityIndicator.translatesAutoresizingMaskIntoConstraints = YES;
    //_activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _activityIndicator.center=self.view.center;
    _activityIndicator.hidden = NO;
    
    _activityIndicator.center=self.view.center;
    
    CGRect frame = [[ UIScreen mainScreen] bounds];

    _customIndicator = [[CustomActivityIndicator alloc] initWithFrame:CGRectMake((frame.size.width-250)/2,(frame.size.height-200)/2, 250, 200)];
    
    _transparentView = [[UIView alloc] initWithFrame:frame];
    _transparentView.backgroundColor = [UIColor grayColor];
    _transparentView.alpha = 0.5f;
    _transparentView.opaque = NO;
    [self.view addSubview:_transparentView];
    
    [self.view addSubview:_customIndicator];
    [self.view bringSubviewToFront:_customIndicator];
    //[self startStopIndicator:YES];
    [self loadJavascript];
    _resultWebView.scalesPageToFit = NO;
//    _resultWebView.layer.borderWidth = 1;
//    _resultWebView.layer.borderColor = [UIColor redColor].CGColor;

    _resultWebView.opaque = NO;
    _resultWebView.backgroundColor = [UIColor clearColor];

    //to display contant in webview from top.
    [[_resultWebView scrollView] setContentInset:UIEdgeInsetsMake(-64, 0, 0, 0)];

}

- (void)dealloc {
}

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"");
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
    NSLog(@"");
    [super viewWillDisappear:animated];
    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
        // back button was pressed.  We know this is true because self is no longer
        // in the navigation stack.
        [Utils startPayUNotificationForKey:PAYU_ERROR intValue:PBackButtonPressed object:nil];
    }
    
//    [[NSNotificationCenter defaultCenter] removeObserver:_handler forKeyPath:UIKeyboardDidHideNotification];
//    [[NSNotificationCenter defaultCenter] removeObserver:_handler forKeyPath:UIKeyboardDidShowNotification];
   _handler = nil;
}

- (void)viewDidLayoutSubviews{
    
}

/*- (void)sendMessage:(id)sender {
 [_bridge send:@"A string sent from ObjC to JS" responseCallback:^(id response) {
 NSLog(@"sendMessage got response: %@", response);
 }];
 }
 
 - (void)callHandler:(id)sender {
 id data = @{ @"greetingFromObjC": @"Hi there, JS!" };
 [_bridge callHandler:@"testJavascriptHandler" data:data responseCallback:^(id response) {
 NSLog(@"testJavascriptHandler responded: %@", response);
 }];
 }
 */

-(void) appGoingInBackground:(NSNotification *)notification{
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) startStopIndicator:(BOOL) aFlag{
//    NSLog(@"");
    if(aFlag){
        [self.view bringSubviewToFront:_activityIndicator];
        [_activityIndicator startAnimating];
    }
    else
        [_activityIndicator stopAnimating];
    
    _processingLbl.hidden = !aFlag;
}

-(void) getPGUrlList{
    NSString *pgUrlListStr = [_handler.initializeJavascriptDict valueForKey:PG_URL_LIST];
    _pgUrlList = [pgUrlListStr componentsSeparatedByString:@"||"];
    NSLog(@"PG URL LIST = %@",_pgUrlList);
}

-(void) matchUrl:(NSString *)urlStr{
    BOOL isUrlMatchFound = NO;
    for(NSString *pgUrl in _pgUrlList){
        if([urlStr isEqualToString:pgUrl] || [urlStr containsString:pgUrl]){
            isUrlMatchFound = YES;
        }
    }
    
    if(!isUrlMatchFound && _pgUrlList && !_resultWebView.loading){
        NSLog(@"URL Match Found not Found");
        [_customIndicator removeFromSuperview];
        [_transparentView removeFromSuperview];
    }
}


#pragma mark - WebView delegate

- (void)webViewDidFinishLoad:(UIWebView *)webView;
{
    NSLog(@"");
//    _resultWebView.scalesPageToFit = NO;
    [self startStopIndicator:NO];
    
    if(!_isBankFound){
        [self getPGUrlList];
        [_handler runIntializeJSOnWebView];
    }
    else{
        [_handler runBankSpecificJSOnWebView];
    }
   
    if(!_isWebViewLoadFirstTime){
        // KB Notification
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
//        
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
//        _isWebViewLoadFirstTime = YES;
    }
    
    [self matchUrl:_loadingUrl];
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error;
{
    NSLog(@"");
    [self startStopIndicator:NO];
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (_handler) {
        NSLog(@"_handler closeCB");
        [_handler closeCB];
    } else {
        NSLog(@"Error: _handler NIL");
    }
    
    //[self startStopIndicator:YES];
    
    NSURL *url = request.URL;
    NSLog(@"finallyCalled = %@",url);
    
    //[self matchUrl:url.absoluteString];
    _loadingUrl = url.absoluteString;
    
    if ([[url scheme] isEqualToString:@"ios"]) {
        [self startStopIndicator:NO];
        
        NSString *responseStr = [url  absoluteString];
        NSString *search = @"success";
        
        if([responseStr localizedCaseInsensitiveContainsString:search]){
            NSDictionary *InfoDict = [NSDictionary dictionaryWithObject:responseStr forKey:INFO_DICT_RESPONSE];
            [[NSNotificationCenter defaultCenter] postNotificationName:PAYMENT_SUCCESS_NOTIFICATION object:InfoDict];
            NSLog(@"success block with infoDict = %@",InfoDict);
            
        }
        
        search = @"failure";
        if([responseStr localizedCaseInsensitiveContainsString:search]){
            NSDictionary *InfoDict = [NSDictionary dictionaryWithObject:responseStr forKey:INFO_DICT_RESPONSE];;
            [[NSNotificationCenter defaultCenter] postNotificationName:PAYMENT_FAILURE_NOTIFICATION object:InfoDict];
            NSLog(@"failure block with infoDict = %@",InfoDict);
            
        }
        search = @"cancel";
        
        if([responseStr localizedCaseInsensitiveContainsString:search]){
            NSDictionary *InfoDict = [NSDictionary dictionaryWithObject:responseStr forKey:INFO_DICT_RESPONSE];;
            [[NSNotificationCenter defaultCenter] postNotificationName:PAYMENT_CANCEL_NOTIFICATION object:InfoDict];
            NSLog(@"cancel block with infoDict = %@",InfoDict);
            
        }
    }
    
    
    if([url.absoluteString containsString:CB_RETRY_PAYMENT_OPTION_URL]){
        [_handler removeIntermidiateLoader];
        [_customIndicator removeFromSuperview];
        [_transparentView removeFromSuperview];

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


#pragma mark - JavaScript delegate

-(void) runIntializeJSOnWebView{
    NSLog(@"");
    /****-------------Setting JavScript Context-----------***/
    /*if(!_isBankFound){
        // get JSContext from UIWebView instance
        JSContext *context = [_resultWebView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
        
        // enable error logging
        [context setExceptionHandler:^(JSContext *context, JSValue *value) {
            NSLog(@"WEB JS: %@", value);
        }];
        
        // give JS a handle to our PayUPaymentResultViewController(self) instance
        context[@"PayU"] = _handler;
        
//        [context evaluateScript:[_handler.initializeJavascriptDict valueForKey:DETECT_BANK_KEY]];
        NSString *initializeJSStr = [[_handler.initializeJavascriptDict valueForKey:DETECT_BANK_KEY]
                                     stringByReplacingOccurrencesOfString:@"\\" withString:@""];
        initializeJSStr = [initializeJSStr stringByReplacingOccurrencesOfString:@"\"" withString:@"'"];
        [initializeJSStr stringByAppendingString:@";"];
        NSLog(@"initializeJSStr = %@",[initializeJSStr stringByAppendingString:@";"]);
        [context evaluateScript:[initializeJSStr stringByAppendingString:@";"]];
//        [context evaluateScript:initializeJSStr];
    }*/
    if(!_isBankFound)
    [_handler runIntializeJSOnWebView];

    
}


-(void) loadJavascript{
    
    // create Connection handler
    if(!_handler){
        _handler = [[CBConnectionHandler alloc] init];
        _handler.connectionHandlerDelegate = self;
        _handler.resultView = self.view;
        _handler.resultWebView = _resultWebView;
        _handler.resultViewController = self;
    }
    [_handler downloadInitializeJS];
}

#pragma mark - CBConnectionHandler Delegate

- (void) bankSpecificJSDownloded{
    NSLog(@"");
}

- (void) bankNameFound:(NSString *) bankName{
    NSLog(@"BankName = %@ ",bankName);
    _isBankFound = YES;
}

- (void) adjustWebViewHeight:(BOOL) upOrDown
{
    NSLog(@"upOrDown: %d",upOrDown);
    //__block CGRect webViewFrame = CGRectZero;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if(upOrDown){
            CGRect webViewFrame = CGRectZero;
            NSLog(@"WebViewFrame without updates = %@",NSStringFromCGRect(_resultWebView.frame));
            [_resultWebView removeConstraints:_resultWebView.constraints];
            //_resultWebView.scalesPageToFit = YES;
            webViewFrame = _resultWebView.frame;
            webViewFrame.size.height = webViewFrame.size.height - 227;
            _resultWebView.frame = webViewFrame;
            NSLog(@"WebViewFrame when CB is on Screen = %@",NSStringFromCGRect(_resultWebView.frame));
        }
        else{
            CGRect webViewFrame = CGRectZero;
            NSLog(@"WebViewFrame without updates = %@",NSStringFromCGRect(_resultWebView.frame));
            [_resultWebView removeConstraints:_resultWebView.constraints];
            //_resultWebView.scalesPageToFit = NO;
            webViewFrame = _resultWebView.frame;
            webViewFrame.size.height = webViewFrame.size.height + 227;
            _resultWebView.frame = webViewFrame;
            NSLog(@"WebViewFrame when CB is off Screen = %@",NSStringFromCGRect(_resultWebView.frame));

        }
    });
}

- (void) addViewInResultView:(UIView *) aView{
    NSLog(@"");
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view addSubview:aView];
        [aView setNeedsDisplay];
    });

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
