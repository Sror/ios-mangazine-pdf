//
//  Library.m
//  Magazine
//
//  Created by Myongsok Kim on 8/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Library.h"
#import "LibraryIssue.h"

#import "AppConstants.h"
#import "Utils.h"
#import "Feedback.h"

static Library * singletonLibrary = nil;

@implementation Library
@synthesize arrIssues;

#pragma mark - Init
+ (Library *)sharedLibrary
{
    if( singletonLibrary == nil )
        singletonLibrary = [[Library alloc] init];
    
    return singletonLibrary;
}

+ (void)destroyLibrary
{
    if( singletonLibrary != nil )
    {
        [singletonLibrary release];
        singletonLibrary = nil;
    }
}

- (id)init
{
    self = [super init];
    
    if( self != nil )
    {        
        arrIssues = [[NSMutableArray alloc] init];        
        
        NSString * documentDirectory = [[Utils sharedUtils] pathOfDocument];
        NSString * strLibraryFilePath = [documentDirectory stringByAppendingPathComponent:LIBRARY_FILE_NAME];
                
        if( [[NSFileManager defaultManager] fileExistsAtPath:strLibraryFilePath] )
        {
            NSArray * arr = [NSArray arrayWithContentsOfFile:strLibraryFilePath];
            for( NSDictionary * dic in arr )
            {
                LibraryIssue * libraryIssue = [[LibraryIssue alloc] initWithDictionary:dic];                
                if( libraryIssue.nStatus == STATUS_DOWNLOADING )
                    libraryIssue.nStatus = STATUS_PAUSED;
                [arrIssues addObject:libraryIssue];
                [libraryIssue release];
            }
        }
        
        dicFetchURIs = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (void)dealloc
{
    [self saveLibrary];
    
    [arrIssues release];
    [dicFetchURIs release];
    
    [super dealloc];
}

- (void)saveLibrary
{
    NSString * documentDirectory = [[Utils sharedUtils] pathOfDocument];
    NSString * strLibraryFilePath = [documentDirectory stringByAppendingPathComponent:LIBRARY_FILE_NAME];
    
    if( [[NSFileManager defaultManager] fileExistsAtPath:strLibraryFilePath] )
        [[NSFileManager defaultManager] removeItemAtPath:strLibraryFilePath error:nil];
    
    if( [arrIssues count] > 0 )
    {
        NSMutableArray * arr = [NSMutableArray array];
        
        for( LibraryIssue * libraryIssue in arrIssues )
        {
            NSDictionary * dic = [libraryIssue createDictionary];
            [arr addObject:dic];
        }
        
        [arr writeToFile:strLibraryFilePath atomically:YES];
    }
}

#pragma mark - Public Methods
- (BOOL)addNewIssue:(LibraryIssue *)libraryIssue
{
    if( libraryIssue.sIssueId == nil )
        return NO;
    
    BOOL bExist = NO;
    for( LibraryIssue * issue in arrIssues )
    {
        if( [issue.sIssueId isEqualToString:libraryIssue.sIssueId] )
        {
            bExist = YES;
            break;
        }
    }
    
    if( bExist == NO )
    {
        [arrIssues addObject:libraryIssue];
        [self saveLibrary];        
    }

    return YES;
}

- (void)removeIssue:(LibraryIssue *)libraryIssue
{
    if( libraryIssue.sIssueId == nil )
        return;
    
    for( LibraryIssue * aIssue in arrIssues )
    {
        if( [aIssue.sIssueId isEqualToString:libraryIssue.sIssueId] )
        {
            
            NSFileManager * fm = [NSFileManager defaultManager];
            //  Remove thumbnail
            NSString * sThumbPath = [[Utils sharedUtils] pathForThumbFolder];
            NSString * sThumbFile = [sThumbPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.PNG", libraryIssue.sIssueId]];
            [fm removeItemAtPath:sThumbFile error:nil];            
            
            FetchURI * fetchURI = nil;
            if( libraryIssue.nStatus == STATUS_DOWNLOADING )
            {
                fetchURI = [dicFetchURIs objectForKey:libraryIssue.sIssueId];
                if( fetchURI != nil )
                {
                    if( fetchURI.status == FETCH_STATUS_FETCHING )
                        [fetchURI stopFetch];
                    [fetchURI removeTempFile];
                    [dicFetchURIs removeObjectForKey:libraryIssue.sIssueId];
                }
            }
            else if( libraryIssue.nStatus == STATUS_PAUSED )
            {
                fetchURI = [FetchURI fetchFileWithURL:libraryIssue.sFileURL delegate:nil allowResume:NO];
                [fetchURI removeTempFile];
            }
            else if( libraryIssue.nStatus == STATUS_READABLE )
            {
                //  Remove PDF
                NSString * sPDFPath = [[Utils sharedUtils] pathForPDFFolder];
                NSString * sPDFFile = [sPDFPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.PDF", libraryIssue.sIssueId]];
                [fm removeItemAtPath:sPDFFile error:nil];                
            }
            
            [arrIssues removeObject:aIssue];
            [self saveLibrary];
            break;
        }
    }
}

- (void)downloadLibraryIssue:(LibraryIssue *)libraryIssue
{
    if( libraryIssue.nStatus == STATUS_READABLE )
        return;
    
    if( libraryIssue.nStatus == STATUS_DOWNLOADING )
    {
        if( [dicFetchURIs objectForKey:libraryIssue.sIssueId] != nil )
            return;
    }
        
    libraryIssue.nStatus = STATUS_DOWNLOADING;
    
    FetchURI * fetchURI = [FetchURI fetchFileWithURL:libraryIssue.sFileURL delegate:self allowResume:YES];
    fetchURI.userData = libraryIssue.sIssueId;
    [dicFetchURIs setObject:fetchURI forKey:libraryIssue.sIssueId];
    
    [fetchURI startFetch];
}

- (void)pauseDownloadingLibraryIssue:(LibraryIssue *)libraryIssue
{
    FetchURI * fetchURI = [dicFetchURIs objectForKey:libraryIssue.sIssueId];
    
    if( fetchURI != nil )
    {
        if( fetchURI.status == FETCH_STATUS_FETCHING )
            [fetchURI stopFetch];
        
        [dicFetchURIs removeObjectForKey:libraryIssue.sIssueId];
    }
    
    libraryIssue.nStatus = STATUS_PAUSED;        
    [self saveLibrary];    
}

- (LibraryIssue *)libraryIssueForId:(NSString *)sId
{
    for( LibraryIssue * libraryIssue in arrIssues )
    {
        if( [libraryIssue.sIssueId isEqualToString:sId] )
            return libraryIssue;
    }
    
    return nil;
}

#pragma mark - FetchDelegate
- (void)fetchDidFinished:(FetchURI *)fetch
{
    LibraryIssue * libraryIssue = [self libraryIssueForId:fetch.userData];
    
    if( libraryIssue != nil )
    {
            
        //  Increase downloaded count of issue on server database
        [[Feedback sharedFeedback] downloadedIssue:libraryIssue.sIssueId];
        
        NSString * fileName = [fetch.fetchURL lastPathComponent];
        
        BOOL bOK = NO;
        
        if( [fileName hasSuffix:@".zip"] || [fileName hasSuffix:@".ZIP"] )
        {
            NSString * zipFilePath = [fetch getFile];                
            NSString * pdfPath = [[Utils sharedUtils] extractPDFFromZipFile:zipFilePath toSubFolderOfTemp:libraryIssue.sIssueId];                    
            
            if( [libraryIssue setPDFFile:pdfPath] )
                bOK = YES;
        }
        else
        {
            if( [libraryIssue setPDFFile:[fetch getFile]] )
                bOK = YES;
        }        
        
        
        [fetch removeTempFile];        
        
        if( bOK )
        {
            libraryIssue.nStatus = STATUS_READABLE;
            [self saveLibrary];            
            [[NSNotificationCenter defaultCenter] postNotificationName:kFetchSuccessNotification object:libraryIssue userInfo:nil];   
        }
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:kFetchFailNotification object:libraryIssue userInfo:nil];
        }        
    }
    
    [dicFetchURIs removeObjectForKey:fetch.userData];
}

- (void)fetchDidFailed:(FetchURI *)fetch
{
    LibraryIssue * libraryIssue = [self libraryIssueForId:fetch.userData];    
    if( libraryIssue == nil )
        return;
    libraryIssue.nStatus = STATUS_PAUSED;
    [self saveLibrary];    
    [[NSNotificationCenter defaultCenter] postNotificationName:kFetchFailNotification object:libraryIssue userInfo:nil];    
    [dicFetchURIs removeObjectForKey:fetch.userData];
}

- (void)fetchDid:(FetchURI *)fetch WithPercent:(float)fPercent
{
    LibraryIssue * libraryIssue = [self libraryIssueForId:fetch.userData];    
    if( libraryIssue == nil )
        return;
    [[NSNotificationCenter defaultCenter] postNotificationName:kFetchPercentNotification 
                                                        object:libraryIssue 
                                                      userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:fPercent] forKey:kPercentNotifictionUserInfoKey]];
}

@end
