//
//  PreferrwedPaymentMethodCustomeCell.h
//  PayU_iOS_SDK
//
//  Created by Suryakant Sharma on 11/12/14.
//  Copyright (c) 2014 PayU, India. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PreferredPaymentMethodCustomeCell : UITableViewCell

@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *paymentImage;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *preferredPaymentOption;

@end
