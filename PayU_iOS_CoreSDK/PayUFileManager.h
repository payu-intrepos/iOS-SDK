//
//  FileManager.h
//  PayU_iOS_SDK_TestApp
//
//  Created by Sharad Goyal on 15/10/15.
//  Copyright (c) 2015 PayU, India. All rights reserved.
//

/*!
 * This class is used to read, write and send Device Analytica data.
 */

#import <Foundation/Foundation.h>

@interface PayUFileManager : NSObject

/*!
 * This method is used to send DeviceAnalyticsData to Server
 * @see [prepareDeviceAnalyticsDict]
 * @see [writeAnalyticsDataToFileWithName]
 */
+(void)sendDeviceAnalyticsData;

@end
