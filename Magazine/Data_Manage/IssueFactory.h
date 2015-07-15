//
//  IssueFactory.h
//  Magazine
//
//  Created by Myongsok Kim on 9/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Issue;
@interface IssueFactory : NSObject
{
    NSMutableDictionary * dicFactory;
}

+ (IssueFactory *)sharedFactory;
+ (void)destroyFactory;

#pragma mark - Public Methods;
- (Issue *)issueFromId:(NSString *)sIssueId;
- (void)registerIssue:(Issue *)issue;

@end
