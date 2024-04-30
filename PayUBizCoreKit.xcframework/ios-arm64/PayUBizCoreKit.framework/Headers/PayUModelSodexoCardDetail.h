//
//  PayUModelSodexoCardDetail.h
//  PayUBizCoreKit
//
//  Created by Amit Salaria on 11/10/21.
//  Copyright © 2021 PayU. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PayUModelSodexoCardDetail : NSObject

@property (nonatomic, strong) NSString * status;
@property (nonatomic, strong) NSString * cardNo;
@property (nonatomic, strong) NSString * cardBalance;
@property (nonatomic, strong) NSString * cardName;
@property (nonatomic, strong) NSString * msg;

@end



/*
 {"status":1,"cardNo":"637513XXXXXX3212","cardBalance":"17150.83","cardName":"test","msg":"success"}
 */
