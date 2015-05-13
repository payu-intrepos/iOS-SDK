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
            //[self.navigationItem setHidesBackButton:YES animated:YES];

        }
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

    [self startStopIndicator:YES];

}

- (void)dealloc {
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
    
    [self startStopIndicator:YES];

    // Reachability
    [ReachabilityManager sharedManager];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityDidChange:) name:payUReachabilityChangedNotification object:nil];
    
    _resultWebView.delegate = self;
    [_resultWebView loadRequest:_request];
    
    
}

- (void)viewWillDisappear:(BOOL)animated {
    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
        // back button was pressed.  We know this is true because self is no longer
        // in the navigation stack.
        [Utils startPayUNotificationForKey:PAYU_ERROR intValue:PBackButtonPressed object:nil];
    }
    [super viewWillDisappear:animated];
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


#pragma mark - WebView delegate

- (void)webViewDidFinishLoad:(UIWebView *)webView;
{
    [self startStopIndicator:NO];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error;
{
    [self startStopIndicator:NO];
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    [self startStopIndicator:YES];

    NSURL *url = request.URL;
    NSLog(@"finallyCalled = %@",url);
    
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
        [Utils startPayUNotificationForKey:PAYU_ERROR intValue:PInternetNotReachable object:self];
    }
}


@end
