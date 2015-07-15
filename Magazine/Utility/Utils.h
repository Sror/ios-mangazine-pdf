//
//  Utils.h
//  Magazine
//
//  Created by Myongsok Kim on 8/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#if !defined (__IPHONE_5_0)
#define __IPHONE_5_0    50000
#endif

@interface Utils : NSObject
{
    NSString * sDeviceId;
}

#pragma mark -
#pragma mark Life Cycle
+ (Utils *)sharedUtils;
+ (void)destroyUtils;

- (CGFloat)heightOfText:(NSString *)sText font:(UIFont *)font width:(CGFloat)width;
- (void)alertMessage:(NSString *)msg;
- (NSInteger)getSystemVersionAsInteger;
- (NSString *)getDeviceId;


- (NSString *)pathOfDocument;
- (NSString *)pathForPDFFolder;
- (NSString *)pathForThumbFolder;
- (NSString *)pathForTempFolder;
- (NSString *)extractPDFFromZipFile:(NSString *)zipFilePath toSubFolderOfTemp:(NSString *)sTemp;

@end
