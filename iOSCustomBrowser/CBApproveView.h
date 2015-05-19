//
//  CBApproveView.h
//  iOSCustomBrowser
//
//  Created by Suryakant Sharma on 21/04/15.
//  Copyright (c) 2015 PayU, India. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CBConnectionHandler.h"

@interface CBApproveView : UIView

@property (nonatomic,weak) NSDictionary *bankJS;
//@property (nonatomic,weak) UIWebView *resultWebView;
//@property (nonatomic,weak) UIView *resultView;
@property (nonatomic,weak) CBConnectionHandler *handler;
@property (assign, nonatomic) BOOL isViewOnScreen;
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *otpTextField;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *timerLabel;

@property (nonatomic,strong) NSTimer *timer;


- (void) RegenerateOTP:(UIButton *) aButton;
- (void) startCountDown;

- (id)initWithFrame:(CGRect)frame andCBConnectionHandler:(CBConnectionHandler *)handler;
@end
