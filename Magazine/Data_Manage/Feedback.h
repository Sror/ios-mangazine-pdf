//
//  Feedback.h
//  Magazine
//
//  Created by Myongsok Kim on 9/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FetchURI.h"

@interface Feedback : NSObject <FetchDelegate>
{
    NSMutableDictionary * dicFetchURIs;
}

+ (Feedback *)sharedFeedback;
+ (void)destroyFeedback;


- (void)downloadedIssue:(NSString *)sIssueId;
- (void)deletedIssue:(NSString *)sIssueId;
- (void)giveRatingIssue:(NSString *)sIssueId rating:(NSInteger)nNumberOfStar;

@end
