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
//#import "CustomActivityIndicator.h"

// ------------------- CB Import ----------------
//#import "PayU_CB_SDK.h"


@interface PayUPaymentResultViewController () <UIWebViewDelegate>

@property (unsafe_unretained, nonatomic) IBOutlet UIWebView *resultWebView;
//@property (strong,nonatomic) UIView *transparentView;
//@property (nonatomic,strong) NSArray *pgUrlList;
//@property (nonatomic,strong) NSString *loadingUrl;
//@property (nonatomic,strong) CustomActivityIndicator *customIndicator;
//@property (nonatomic,assign) float y;
//@property (nonatomic,assign) BOOL isBankFound;
//@property (nonatomic,assign) BOOL isWebViewLoadFirstTime;
@property (nonatomic,strong) UIAlertView *alertView;
//@property (strong,nonatomic) CBConnection *CBC;

@end

@implementation PayUPaymentResultViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
//    self.navigationItem.title = @"UIWebView";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appGoingInBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    
    // Reachability
    [ReachabilityManager sharedManager];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityDidChange:) name:payUReachabilityChangedNotification object:nil];
    
//    if(_flag){
//        
//        _y = 64;
//        NSLog(@"UI SHould be according to 3_5 inch");
//        [self.view removeConstraints:self.view.constraints];
//        [_resultWebView removeConstraints:_resultWebView.constraints];
//        _resultWebView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
//        _resultWebView.translatesAutoresizingMaskIntoConstraints = YES;
//        CGRect frame = [[UIScreen mainScreen] bounds];
//        frame.origin.y = _y;
//        frame.size.height = frame.size.height - _y;
////        _resultWebView.frame = frame;
//        
//    }
    
//    _resultWebView.backgroundColor = [UIColor clearColor];    
    [_resultWebView loadRequest:_request];
    
    //to display contant in webview from top.
//    [[_resultWebView scrollView] setContentInset:UIEdgeInsetsMake(-64, 0, 0, 0)];
    
//    _CBC = [[CBConnection alloc]init:self.view webView:_resultWebView];
//    _CBC.isWKWebView = NO;
//    _CBC.cbServerID = CB_SERVER_ID;
//    [_CBC payUActivityIndicator];
//    [_CBC initialSetup];
}

- (void)dealloc {
}

- (void)viewWillAppear:(BOOL)animated {
    
//    // Reachability
//    [ReachabilityManager sharedManager];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityDidChange:) name:payUReachabilityChangedNotification object:nil];
    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [_resultWebView loadRequest:_request];
//    });
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
//    [_CBC deallocHandler];
    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
        [Utils startPayUNotificationForKey:PAYU_ERROR intValue:PBackButtonPressed object:nil];
    }
}

/*
- (void)viewDidLayoutSubviews{
    ALog(@"");
}
*/

-(void) appGoingInBackground:(NSNotification *)notification{
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - WebView delegate

-(void)webViewDidStartLoad:(UIWebView *)webView{
    NSLog(@"webViewDidStartLoad---------%@",webView.request.URL);
}

- (void)webViewDidFinishLoad:(UIWebView *)webView;
{
    NSLog(@"webViewDidFinishLoad---------%@",webView.request.URL);
    
//    [_CBC payUwebViewDidFinishLoad:webView];

}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"didFailLoadWithError---------%@",webView.request.URL);
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)naavigationType {
    NSLog(@"shouldStartLoadWithRequest---------%@",request.URL);
    
//    [_CBC payUwebView:webView shouldStartLoadWithRequest:request];
    
    
//    if([url.absoluteString rangeOfString:CB_RETRY_PAYMENT_OPTION_URL options:NSCaseInsensitiveSearch].location != NSNotFound){
//        //        [_handler removeIntermidiateLoader];
//        //        [_handler closeCB];
//        //        [_customIndicator removeFromSuperview];
//        //        [_transparentView removeFromSuperview];
//        
//        
//    }   
    
    return true;
}



//-(void)navigateToRootViewController{
//    NSLog(@"");
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