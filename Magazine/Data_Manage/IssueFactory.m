//
//  IssueFactory.m
//  Magazine
//
//  Created by Myongsok Kim on 9/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "IssueFactory.h"
#import "Issue.h"


static IssueFactory * singletonFactory = nil;

@implementation IssueFactory

+ (IssueFactory *)sharedFactory
{
    if( singletonFactory == nil )
        singletonFactory = [[IssueFactory alloc] init];
    return singletonFactory;
}

+ (void)destroyFactory
{
    if( singletonFactory != nil )
    {
        [singletonFactory release];
        singletonFactory = nil;
    }
}

- (id)init
{
    self = [super init];
    if( self != nil )
    {
        dicFactory = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (void)dealloc
{
    [dicFactory release];
    [super dealloc];
}

#pragma mark - Public Methods;
- (Issue *)issueFromId:(NSString *)sIssueId
{
    if( sIssueId == nil )
        return nil;
    
    return [dicFactory objectForKey:sIssueId];
}

- (void)registerIssue:(Issue *)issue
{
    if( (issue != nil) && (issue.sIssueId != nil) )
        [dicFactory setObject:issue forKey:issue.sIssueId];
}
    
@end
