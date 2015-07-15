//
//  Feedback.m
//  Magazine
//
//  Created by Myongsok Kim on 9/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Feedback.h"
#import "AppConstants.h"
#import "Utils.h"

static Feedback * singletonFeedback = nil;
@implementation Feedback

+ (Feedback *)sharedFeedback
{
    if( singletonFeedback == nil )
        singletonFeedback = [[Feedback alloc] init];
    return singletonFeedback;
}

+ (void)destroyFeedback
{
    if( singletonFeedback != nil )
    {
        [singletonFeedback release];
        singletonFeedback = nil;
    }
}

- (id)init
{
    self = [super init];
    if( self != nil )
    {
        dicFetchURIs = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (void)dealloc
{
    [dicFetchURIs release];
    [super dealloc];
}

- (void)downloadedIssue:(NSString *)sIssueId
{
    NSString * sId = [NSString stringWithFormat:@"%@_download", sIssueId];
    if( [dicFetchURIs objectForKey:sId] != nil )
        return;
    
    NSString * sURL = [NSString stringWithFormat:FEEDBACK_URL_DOWNLOADED_ISSUE, sIssueId, [[Utils sharedUtils] getDeviceId]];
    FetchURI * fetch = [FetchURI fetchWithURL:sURL delegate:self];
    fetch.userData = sId;
    [dicFetchURIs setObject:fetch forKey:sId];
    [fetch startFetch];
}

- (void)deletedIssue:(NSString *)sIssueId
{
    NSString * sId = [NSString stringWithFormat:@"%@_delete", sIssueId];
    if( [dicFetchURIs objectForKey:sId] != nil )
        return;
    
    NSString * sURL = [NSString stringWithFormat:FEEDBACK_URL_DELETED_ISSUE, sIssueId, [[Utils sharedUtils] getDeviceId]];
    FetchURI * fetch = [FetchURI fetchWithURL:sURL delegate:self];
    fetch.userData = sId;
    [dicFetchURIs setObject:fetch forKey:sId];
    [fetch startFetch];    
}

- (void)giveRatingIssue:(NSString *)sIssueId rating:(NSInteger)nNumberOfStar
{
    NSString * sId = [NSString stringWithFormat:@"%@_rating", sIssueId];
    if( [dicFetchURIs objectForKey:sId] != nil )
        return;
    
    NSString * sURL = [NSString stringWithFormat:FEEDBACK_URL_GIVE_RATING_ISSUE, sIssueId, [[Utils sharedUtils] getDeviceId], nNumberOfStar];
    FetchURI * fetch = [FetchURI fetchWithURL:sURL delegate:self];
    fetch.userData = sId;
    [dicFetchURIs setObject:fetch forKey:sId];
    [fetch startFetch];        
}

#pragma mark - FetchDelegate
- (void)fetchDidFinished:(FetchURI *)fetch
{
    [dicFetchURIs removeObjectForKey:fetch.userData];
}

- (void)fetchDidFailed:(FetchURI *)fetch
{
    [dicFetchURIs removeObjectForKey:fetch.userData];    
}

@end
