//
//  Serie.h
//  Magazine
//
//  Created by Myongsok Kim on 8/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Element;
@interface Series : NSObject
{
    NSString *      sSeriesId;
    NSString *      sTitle;
    NSString *      sDesc;
    NSString *      sPublisher;
    NSString *      sThumbURL;
    
    int     nDownCnt;
    int     nRatingCnt;
    float   fRatingAvg;
    
    BOOL        bLoadAll;    
    NSMutableArray * arrIssues;    
}

@property ( retain ) NSString *     sSeriesId;
@property ( retain ) NSString *     sTitle;
@property ( retain ) NSString *     sDesc;
@property ( retain ) NSString *     sPublisher;
@property ( retain ) NSString *     sThumbURL;

@property ( assign ) int    nDownCnt;
@property ( assign ) int    nRatingCnt;
@property ( assign ) float  fRatingAvg;

@property ( retain ) NSMutableArray *   arrIssues;
@property ( assign ) BOOL               bLoadAll;

- (id)initWithElement:(Element *)element;

@end
