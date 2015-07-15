//
//  LibrayIssue.m
//  Magazine
//
//  Created by Myongsok Kim on 8/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LibraryIssue.h"
#import "Utils.h"
#import "AppConstants.h"

#define KEY_STATUS          @"status"
#define KEY_FILE_URL        @"file_url"
#define KEY_SERIES_ID       @"series_id"
#define KEY_SERIES_TITLE    @"series_title"
#define KEY_ISSUE_ID        @"issue_id"
#define KEY_ISSUE_TITLE     @"issue_title"
#define KEY_DATE            @"date"
#define KEY_PUBLISHER       @"publisher"
#define KEY_PUBLISHED_DATE  @"published_date"
#define KEY_READ_COUNT      @"read_count"


@implementation LibraryIssue
@synthesize nStatus;
@synthesize sFileURL;
@synthesize sSeriesId, sSeriesTitle;
@synthesize sIssueId, sIssueTitle;
@synthesize sDate;
@synthesize sPublisher, sPublishedDate;
@synthesize nReadCnt;

#pragma mark - Life Cycle;
- (id)initWithDictionary:(NSDictionary *)dic
{
    self = [super init];
    
    if( self )
    {
        self.nStatus        = [[dic objectForKey:KEY_STATUS] intValue];
        self.sFileURL       = [dic objectForKey:KEY_FILE_URL];
        self.sSeriesId      = [dic objectForKey:KEY_SERIES_ID];
        self.sSeriesTitle   = [dic objectForKey:KEY_SERIES_TITLE];
        self.sIssueId       = [dic objectForKey:KEY_ISSUE_ID];
        self.sIssueTitle    = [dic objectForKey:KEY_ISSUE_TITLE];
        self.sDate          = [dic objectForKey:KEY_DATE];
        self.sPublisher     = [dic objectForKey:KEY_PUBLISHER];
        self.sPublishedDate = [dic objectForKey:KEY_PUBLISHED_DATE];
        self.nReadCnt       = [[dic objectForKey:KEY_READ_COUNT] intValue];
    }
    
    return self;        
}

- (void)dealloc
{
    [sFileURL release];
    [sSeriesId release];
    [sSeriesTitle release];
    [sIssueId release];
    [sIssueTitle release];
    [sDate release];
    [sPublisher release];
    [sPublishedDate release];
    
    [super dealloc];
}

- (NSDictionary *)createDictionary
{
    NSMutableDictionary * dic = [NSMutableDictionary dictionary];
 
    if( sIssueId != nil )
        [dic setObject:sIssueId forKey:KEY_ISSUE_ID];    
    else
        return nil;
    
    if( sFileURL != nil )
        [dic setObject:sFileURL forKey:KEY_FILE_URL];
    
    if( sSeriesId != nil )
        [dic setObject:sSeriesId forKey:KEY_SERIES_ID];
    
    if( sSeriesTitle != nil )
        [dic setObject:sSeriesTitle forKey:KEY_SERIES_TITLE];
    
    if( sIssueTitle != nil )
        [dic setObject:sIssueTitle forKey:KEY_ISSUE_TITLE];
    
    if( sDate != nil )
        [dic setObject:sDate forKey:KEY_DATE];
    
    if( sPublisher != nil )
        [dic setObject:sPublisher forKey:KEY_PUBLISHER];
    
    if( sPublishedDate != nil )
        [dic setObject:sPublishedDate forKey:KEY_PUBLISHED_DATE];
    
    [dic setObject:[NSNumber numberWithInt:nReadCnt] forKey:KEY_READ_COUNT];
    [dic setObject:[NSNumber numberWithInt:nStatus] forKey:KEY_STATUS];
    
    return dic;
}

#pragma mark - Public Methods
- (BOOL)setThumbImageWithFile:(NSString *)strPath
{
    if( sIssueId == nil )
        return NO;
    
    NSFileManager * fileManager = [NSFileManager defaultManager];
    
    if( [fileManager fileExistsAtPath:strPath] )
    {
        NSString * sPDFPath = [[Utils sharedUtils] pathForThumbFolder];
        NSString * sFileName = [NSString stringWithFormat:@"%@.PNG", self.sIssueId];
        NSString * sFilePath = [sPDFPath stringByAppendingPathComponent:sFileName];
        return  [fileManager copyItemAtPath:strPath toPath:sFilePath error:nil];
    }
    
    return NO;
}

- (BOOL)setThumbImage:(UIImage *)image
{
    if( self.sIssueId == nil )
        return NO;
    
    NSData * data = UIImagePNGRepresentation(image);
 
    if( data != nil )
    {
        NSString * sPDFPath = [[Utils sharedUtils] pathForThumbFolder];
        NSString * sFileName = [NSString stringWithFormat:@"%@.PNG", self.sIssueId];
        NSString * sFilePath = [sPDFPath stringByAppendingPathComponent:sFileName]; 
        return [data writeToFile:sFilePath atomically:YES];
    }        
    
    return NO;
}

- (BOOL)setPDFFile:(NSString *)strPath
{
    if( sIssueId == nil || strPath == nil )
        return NO;
    
    NSFileManager * fileManager = [NSFileManager defaultManager];
    
    NSString * sPDFPath = [[Utils sharedUtils] pathForPDFFolder];
    NSString * sFileName = [NSString stringWithFormat:@"%@.PDF", self.sIssueId];
    NSString * sFilePath = [sPDFPath stringByAppendingPathComponent:sFileName];
    
    if( [fileManager fileExistsAtPath:sFilePath] )
        [fileManager removeItemAtPath:sFilePath error:nil];

    DLog(@"Move %@ to %@", strPath, sFilePath);
    NSError * error = nil;
    BOOL bFlag = [fileManager copyItemAtPath:strPath toPath:sFilePath error:&error];
    
    if( bFlag )
    {
        bFlag = [fileManager removeItemAtPath:strPath error:&error];
        if( bFlag == NO )
            NSLog(@"Remove file error: %@", error.description);
    }
    else
    {
        NSLog(@"Copy Error: %@", error.description);       
    }
        
    return bFlag;
}

- (BOOL)setPDFFileWithData:(NSData *)data
{
    if( sIssueId == nil )
        return NO;
    
    if( data != nil )
    {
        NSString * sPDFPath = [[Utils sharedUtils] pathForPDFFolder];
        NSString * sFileName = [NSString stringWithFormat:@"%@.PDF", self.sIssueId];
        NSString * sFilePath = [sPDFPath stringByAppendingPathComponent:sFileName];
        return [data writeToFile:sFilePath atomically:YES];
    }
    
    return NO;
}

@end
