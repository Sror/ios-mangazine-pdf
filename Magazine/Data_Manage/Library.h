//
//  Library.h
//  Magazine
//
//  Created by Myongsok Kim on 8/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FetchURI.h"

#define kFetchSuccessNotification               @"fetchDidSuccess"
#define kFetchFailNotification                  @"fetchDidFail"
#define kFetchPercentNotification               @"fetchDidPercent"

#define kPercentNotifictionUserInfoKey          @"percent"

@class LibraryIssue;
@interface Library : NSObject <FetchDelegate>
{
    //  LibraryIssue array
    NSMutableArray * arrIssues;
    
    NSMutableDictionary * dicFetchURIs;    
    
}

@property ( retain ) NSMutableArray * arrIssues;

+ (Library *)sharedLibrary;
+ (void)destroyLibrary;
- (void)saveLibrary;

- (BOOL)addNewIssue:(LibraryIssue *)libraryIssue;
- (void)removeIssue:(LibraryIssue *)libraryIssue;
- (void)downloadLibraryIssue:(LibraryIssue *)libraryIssue;
- (void)pauseDownloadingLibraryIssue:(LibraryIssue *)libraryIssue;
- (LibraryIssue *)libraryIssueForId:(NSString *)sId;


@end
