//
//  Utils.m
//  Magazine
//
//  Created by Myongsok Kim on 8/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Utils.h"
#import "AppConstants.h"
#import "ZipArchive.h"
#import "UIDevice+IdentifierAddition.h"

static Utils * singletonUtils = nil;

@implementation Utils

#pragma mark -
#pragma mark Life Cycle
+ (Utils *)sharedUtils
{
    if( singletonUtils == nil )
        singletonUtils = [[Utils alloc] init];
    
    return singletonUtils;
}

+ (void)destroyUtils
{
    if( singletonUtils != nil )
        [singletonUtils release];
}

- (void)dealloc
{
    [sDeviceId release];
    [super dealloc];
}

#pragma mark - Public Methods
- (CGFloat)heightOfText:(NSString *)sText font:(UIFont *)font width:(CGFloat)width
{
	CGSize labelSize = [sText sizeWithFont:font constrainedToSize:CGSizeMake(width,1000) lineBreakMode:UILineBreakModeWordWrap];
    
    return labelSize.height;
}

- (void)alertMessage:(NSString *)msg
{
    UIAlertView * alertView = [[[UIAlertView alloc] initWithTitle:@"Warning" 
                                                          message:@"Fail to loading from store" 
                                                         delegate:@"nil" 
                                                cancelButtonTitle:nil 
                                                otherButtonTitles:@"OK", nil] autorelease];
    [alertView show];    
}

- (NSInteger)getSystemVersionAsInteger
{
    int index = 0;
    NSInteger version = 0;
    
    NSArray * digits = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
    NSEnumerator * enumer = [digits objectEnumerator];
    NSString * number = nil;
    
    while( (number = [enumer nextObject]) )
    {
        if( index > 2 )
            break;
        
        NSInteger multipler = powf(100, 2-index);
        
        version += [number intValue] * multipler;
        
        index ++;
    }
    
    return version;
    
    /*
     
     You can use this version as follows.
     
     if( [[Utils sharedUtils] getSystemVersionAsInteger] >= __IPHONE_4_0 )
     {
     
     }
     else if( [[Utils sharedUtils] getSystemVersionAsInteger] > 40300 ) //iOS 4.3
     {
     
     }
     
     */
}

- (NSString *)getDeviceId
{
    NSString * deviceToken = [[NSUserDefaults standardUserDefaults] objectForKey:kDeviceToken];
    if( deviceToken != nil )
        return deviceToken;
    
    if( sDeviceId != nil )
        return sDeviceId;
    
    sDeviceId = [[NSString alloc] initWithString:[[UIDevice currentDevice] uniqueGlobalDeviceIdentifier]];    
    return sDeviceId;
}


- (NSString *)pathOfDocument
{
    NSArray * searchPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    if( searchPath == nil || [searchPath count] == 0 )
        return nil;
    
    NSString * documentDirectory = [searchPath objectAtIndex:0];
    
    return documentDirectory;
}

- (NSString *)pathForPDFFolder
{
    NSString * documentDirectory = [self pathOfDocument];
    NSString * retPath = [documentDirectory stringByAppendingPathComponent:PDF_FOLDER];
    
    NSFileManager * fileManager = [NSFileManager defaultManager];
    BOOL bDir = YES;
    if( [fileManager fileExistsAtPath:retPath isDirectory:&bDir] == NO )
    {
        [fileManager createDirectoryAtPath:retPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return retPath;    
}

- (NSString *)pathForThumbFolder
{
    NSString * documentDirectory = [self pathOfDocument];
    NSString * retPath = [documentDirectory stringByAppendingPathComponent:THUMB_FOLDER];
    
    NSFileManager * fileManager = [NSFileManager defaultManager];
    BOOL bDir = YES;
    if( [fileManager fileExistsAtPath:retPath isDirectory:&bDir] == NO )
    {
        [fileManager createDirectoryAtPath:retPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return retPath;        
}

- (NSString *)pathForTempFolder
{
    NSString * documentDirectory = [self pathOfDocument];
    NSString * retPath = [documentDirectory stringByAppendingPathComponent:TEMP_FOLDER];
    
    NSFileManager * fileManager = [NSFileManager defaultManager];
    BOOL bDir = YES;
    if( [fileManager fileExistsAtPath:retPath isDirectory:&bDir] == NO )
    {
        [fileManager createDirectoryAtPath:retPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return retPath;            
}

- (NSString *)extractPDFFromZipFile:(NSString *)zipFilePath toSubFolderOfTemp:(NSString *)sTemp
{
    NSString * tempFolder = [self pathForTempFolder];
    NSString * zipTempFolder = [tempFolder stringByAppendingPathComponent:sTemp];    
    BOOL bDir = YES;
    if( [[NSFileManager defaultManager] fileExistsAtPath:zipTempFolder isDirectory:&bDir] == NO )
        [[NSFileManager defaultManager] createDirectoryAtPath:zipTempFolder withIntermediateDirectories:YES attributes:nil error:nil];
    
    // extract zip to /document/Temp/IssueId/
    ZipArchive * zipArchive = [[ZipArchive alloc] init];
    [zipArchive UnzipOpenFile:zipFilePath];
    [zipArchive UnzipFileTo:zipTempFolder overWrite:YES];    
    [zipArchive UnzipCloseFile];
    [zipArchive release];
    
    
    //  Find *.pdf
    NSString * sPDFPath = nil;
    NSEnumerator * enumer = [[NSFileManager defaultManager] enumeratorAtPath:zipTempFolder];
    NSString * sPath = nil;
    while( (sPath = [enumer nextObject]) )
    {
        if( [sPath hasSuffix:@".pdf"] || [sPath hasSuffix:@".PDF"] )
        {
            sPDFPath = [zipTempFolder stringByAppendingPathComponent:sPath];
            
            break;
        }
    }
    
    return sPDFPath;    
}

@end
