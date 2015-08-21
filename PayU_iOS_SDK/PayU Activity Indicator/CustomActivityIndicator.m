//
//  CustomActivityIndicator.m
//  CustomActivityIndicator
//
//  Created by Suryakant Sharma on 11/05/15.
//  Copyright (c) 2015 PayU, India. All rights reserved.
//

#import "CustomActivityIndicator.h"

@interface CustomActivityIndicator()

@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *indicatorImageView;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *msgLabel;

@end

@implementation CustomActivityIndicator

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(!self){
        return nil;
    }
    // replace 3 line with
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSArray *views = [mainBundle loadNibNamed:NSStringFromClass([self class]) owner:self options:nil];
    
    CALayer *layer = self.layer;

    layer.shadowOffset = CGSizeMake(1, 1);
    layer.shadowColor = [[UIColor blackColor] CGColor];
    layer.shadowRadius = 6.0f;
    layer.shadowOpacity = 0.80f;
    layer.shadowPath = [[UIBezierPath bezierPathWithRect:layer.bounds] CGPath];
    
    layer.borderColor = [UIColor whiteColor].CGColor;
    layer.borderWidth = 1.0f;
    layer.cornerRadius = 18.0f;
    layer.masksToBounds = YES;

    [self addSubview:views[0]];

    [self startImageAnimation];
    

    return self;
}

- (void) startImageAnimation{
    
    @autoreleasepool {
        NSArray *images = [NSArray arrayWithObjects:[UIImage imageNamed:@"l_icon1.png"],[UIImage imageNamed:@"l_icon2.png"],[UIImage imageNamed:@"l_icon3.png"],[UIImage imageNamed:@"l_icon4.png"], nil];
        _indicatorImageView.animationImages = images;
        _indicatorImageView.animationDuration = 1.5;
        [_indicatorImageView startAnimating];
    }

}

@end
