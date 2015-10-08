//
//  WKPayUPaymentResultViewController.m
//  PayUTestApp
//
//  Created by Sharad Goyal on 27/07/15.
//  Copyright (c) 2015 PayU, India. All rights reserved.
//
#import "WKPayUPaymentResultViewController.h"
#import <WebKit/WebKit.h>
#import "PayUConstant.h"
#import "Utils.h"
#import "SharedDataManager.h"
#import "Reachability.h"
#import "ReachabilityManager.h"

// ------------------- CB Import ----------------
//#import "PayU_CB_SDK.h"

@interface WKPayUPaymentResultViewController () <UIWebViewDelegate, WKNavigationDelegate, WKScriptMessageHandler, WKUIDelegate>

@property (strong, nonatomic)  WKWebView *resultWebView;
//@property (nonatomic, strong) CBWKConnection *CBCWK;

@end

@implementation WKPayUPaymentResultViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.navigationItem.title = @"WKWebView";
    
    WKUserContentController *controller = [[WKUserContentController alloc]
                                           init];
    [controller addScriptMessageHandler:self name:@"observe"];
    
//    NSString *jScript = @"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);";
    
//    WKUserScript *userScript = [[WKUserScript alloc] initWithSource:jScript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
//    [controller addUserScript:userScript];
    
    WKWebViewConfiguration *myConfiguration = [[WKWebViewConfiguration alloc]init];
    myConfiguration.userContentController = controller;
    
     _resultWebView = [[WKWebView alloc]initWithFrame:self.view.frame configuration:myConfiguration];
    
    _resultWebView.navigationDelegate = self;
    _resultWebView.UIDelegate = self;
    
    [self.view addSubview:_resultWebView];
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    
    [ReachabilityManager sharedManager];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityDidChange:) name:payUReachabilityChangedNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appGoingInBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
//    [self loadJavascript];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"html"];
    NSString *html = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    [_resultWebView loadHTMLString:html baseURL:[NSURL URLWithString:self.urlString]];
    
//    _CBCWK = [[CBWKConnection alloc]init:self.view webView:_resultWebView];
//    _CBCWK.isWKWebView = YES;
//    _CBCWK.cbServerID = CB_SERVER_ID;
//    _CBCWK.postData = _postData;
//    _CBCWK.urlString = _urlString;
//    _CBCWK.wkVC = self;
//    [_CBCWK payUActivityIndicator];
//    [_CBCWK initialSetup];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
        // back button was pressed.  We know this is true because self is no longer
        // in the navigation stack.
        [Utils startPayUNotificationForKey:PAYU_ERROR intValue:PBackButtonPressed object:nil];
    }
}

- (void)viewWillLayoutSubviews
{
    CGRect wkWebViewFrame = _resultWebView.frame;
    if(wkWebViewFrame.origin.y < 64)
    {
        CGRect frm = self.view.frame;
        frm.origin.y += 64;
        frm.size.height -= 64;
        _resultWebView.frame = frm;
    }
    else
    {
        _resultWebView.frame = wkWebViewFrame;
    }
}

-(void) appGoingInBackground:(NSNotification *)notification{
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//-(void)navigateToRootViewController{
////    NSLog(@"");
//    [self.navigationController popToRootViewControllerAnimated:YES];
//}

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

#pragma mark - WebView delegate

- (void)userContentController:(WKUserContentController *)userContentController
      didReceiveScriptMessage:(WKScriptMessage *)message
{
//    [_CBCWK payUuserContentController:userContentController didReceiveScriptMessage:message];
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
//    [_CBCWK payUwebView:webView didStartProvisionalNavigation:navigation];
}

- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation
{
//    [_CBCWK payUwebView:webView didReceiveServerRedirectForProvisionalNavigation:navigation];
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
//    [_CBCWK payUwebView:webView didFailProvisionalNavigation:navigation withError:error];
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation;
{
//    [_CBCWK payUwebView:webView didCommitNavigation:navigation];
}

-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
//    [_CBCWK payUwebView:webView didFinishNavigation:navigation];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
//    [_CBCWK payUwebView:webView didFailNavigation:navigation withError:error];
}

#pragma mark - WKUIDelegate

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)())completionHandler
{
//    [_CBCWK payUwebView:webView runJavaScriptAlertPanelWithMessage:message initiatedByFrame:frame completionHandler:completionHandler];
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler
{
//    [_CBCWK payUwebView:webView runJavaScriptConfirmPanelWithMessage:message initiatedByFrame:frame completionHandler:completionHandler];
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString *result))completionHandler
{
//    [_CBCWK payUwebView:webView runJavaScriptTextInputPanelWithPrompt:prompt defaultText:defaultText initiatedByFrame:frame completionHandler:completionHandler];
}


@end
