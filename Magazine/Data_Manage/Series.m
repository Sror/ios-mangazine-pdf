//
//  Serie.m
//  Magazine
//
//  Created by Myongsok Kim on 8/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Series.h"
#import "AppConstants.h"

#import "Issue.h"
#import "Element.h"
#import "ParserXML.h"

@implementation Series

@synthesize sSeriesId;
@synthesize sTitle, sDesc, sPublisher, sThumbURL;
@synthesize nDownCnt, nRatingCnt, fRatingAvg;
@synthesize arrIssues;
@synthesize bLoadAll;

#pragma mark -
#pragma mark Life Cycle
- (id)init
{
    self = [super init];
    
    if( self )
    {
        sSeriesId   = nil;
        
        sTitle      = nil;
        sDesc       = nil;
        sPublisher  = nil;
        sThumbURL   = nil;
        
        nDownCnt    = 0;
        nRatingCnt  = 0;
        fRatingAvg  = 0.0;
                
        arrIssues = [[NSMutableArray alloc] init];
        bLoadAll = NO;
    }
    
    return self;
}

- (id)initWithElement:(Element *)element
{
    self = [super init];
    
    if( self )
    {
        self.sSeriesId        = [element getValueOfTag:@"series_id"];
        self.sTitle           = [element getValueOfTag:@"title"];
        self.sDesc            = [element getValueOfTag:@"description"];
        self.sThumbURL        = [element getValueOfTag:@"thumbnail"];
        self.sPublisher       = [element getValueOfTag:@"publisher"];
        
        NSString * sDownCnt     = [element getValueOfTag:@"download_cnt"];
        
        if( (sDownCnt != nil) && ([sDownCnt length] > 0) )
        {
            self.nDownCnt = [sDownCnt intValue];
        }
        
        NSString * sRatingCnt   = [element getValueOfTag:@"rating_cnt"];
        
        if( (sRatingCnt != nil) && ([sRatingCnt length] > 0) )
        {
            self.nRatingCnt = [sRatingCnt intValue];
        }
        
        NSString * sRatingAvg   = [element getValueOfTag:@"rating_avg"];
        
        if( (sRatingAvg != nil) && ([sRatingAvg length]) )
        {
            self.fRatingAvg = [sRatingAvg floatValue];
        }        
                
        arrIssues = [[NSMutableArray alloc] init];        
        bLoadAll = NO;
    }
    
    return self;
}

- (void)dealloc
{
    [sSeriesId release];
    [sTitle release];
    [sDesc release];
    [sPublisher release];
    [sThumbURL release];    
    [arrIssues release];
    
    [super dealloc];
}

@end
