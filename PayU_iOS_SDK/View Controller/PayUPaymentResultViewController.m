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
#import "WebViewJavascriptBridge.h"
#import "SharedDataManager.h"
#import "Reachability.h"
#import "ReachabilityManager.h"

@interface PayUPaymentResultViewController () <UIWebViewDelegate>

@property WebViewJavascriptBridge* bridge;

@property (unsafe_unretained, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *processingLbl;
@property (unsafe_unretained, nonatomic) IBOutlet UIWebView *resultWebView;

@property (nonatomic,assign) float y;

@end

@implementation PayUPaymentResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if(_isBackOrDoneNeeded){
        
        if(64 != _y){
            
            
        }
        else{
            //Dissable back button
            [self.navigationItem setHidesBackButton:YES animated:YES];
        }
    }
    
    if(_flag){
        [self.view removeConstraints:self.view.constraints];
        [_resultWebView removeConstraints:_resultWebView.constraints];
        _resultWebView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        _resultWebView.translatesAutoresizingMaskIntoConstraints = YES;
        
        [_activityIndicator removeConstraints:_activityIndicator.constraints];
        _activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        _activityIndicator.translatesAutoresizingMaskIntoConstraints = YES;
        
        [_processingLbl removeConstraints:_processingLbl.constraints];
        _processingLbl.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        _processingLbl.translatesAutoresizingMaskIntoConstraints = YES;
        
        
        CGRect frame = [[UIScreen mainScreen] bounds];
        frame.origin.y = _y;
        frame.size.height = frame.size.height - _y;
        _resultWebView.frame = frame;
        
        frame = _activityIndicator.frame;
        frame.origin.x = self.view.frame.size.width/2  - frame.size.width+10;
        frame.origin.y = self.view.frame.size.height/2 - frame.size.height-100;
        _activityIndicator.frame = frame;
        
        frame = _processingLbl.frame;
        frame.origin.x = self.view.frame.size.width/2  - frame.size.width + 60;
        frame.origin.y = self.view.frame.size.height/2 - frame.size.height - 80;
        _processingLbl.frame = frame;
        
    }
}

- (void)dealloc {
    ALog(@"");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    
    _y = 0.0;
    if ([self isBeingPresented]) {
        // being presented
        _y = 20;
        
    } else if ([self isMovingToParentViewController]) {
        // being pushed
        _y = 64;
    }
    
    
    // Reachability
    [ReachabilityManager sharedManager];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityDidChange:) name:payUReachabilityChangedNotification object:nil];
    
    
   /* if (_bridge) { return; }
    
    [WebViewJavascriptBridge enableLogging];
    
    _bridge = [WebViewJavascriptBridge bridgeForWebView:_resultWebView webViewDelegate:self handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"ObjC received message from JS: %@", data);
        responseCallback(@"Response for message from ObjC");
    }];
    
    [_bridge registerHandler:@"testObjcCallback" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"testObjcCallback called: %@", data);
        responseCallback(@"Response from testObjcCallback");
    }];
    
    [_bridge send:@"A string sent from ObjC before Webview has loaded." responseCallback:^(id responseData) {
        NSLog(@"objc got response! %@", responseData);
    }];
    
    [_bridge callHandler:@"testJavascriptHandler" data:@{ @"foo":@"before ready" }];
    [_bridge send:@"A string sent from ObjC after Webview has loaded."];*/

    
    [self startStopIndicator:YES];
    _resultWebView.delegate = self;
    [_resultWebView loadRequest:_request];
    
    
}


- (void)viewDidLayoutSubviews{
    
}

- (void)sendMessage:(id)sender {
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) startStopIndicator:(BOOL) aFlag{
    if(aFlag){
        [self.view bringSubviewToFront:_activityIndicator];
        [_activityIndicator startAnimating];
    }
    else
        [_activityIndicator stopAnimating];
    
    _processingLbl.hidden = !aFlag;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView;
{
    [self startStopIndicator:NO];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error;
{
    [self startStopIndicator:NO];
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSURL *url = request.URL;
    NSLog(@"finallyCalled = %@",url);
    
    if ([[url scheme] isEqualToString:@"ios"]) {
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
    return YES;
}



-(void)navigateToRootViewController{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

// Reachability methods
- (void)reachabilityDidChange:(NSNotification *)notification {
    Reachability *reach = [notification object];
    
    if ([reach isReachable]) {
        
    } else {
        ALog(@"");
        [Utils startPayUNotificationForKey:PAYU_ERROR intValue:PInternetNotReachable object:self];
    }
}


@end
