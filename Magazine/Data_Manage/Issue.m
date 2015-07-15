//
//  Issue.m
//  Magazine
//
//  Created by Myongsok Kim on 8/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Issue.h"
#import "Element.h"

@implementation Issue

@synthesize sIssueId, sSeriesId;
@synthesize sTitle, sSeriesName, sDesc, sPublisher;
@synthesize sThumbURL, sFileURL;
@synthesize sReleaseDate, sTag, sSize;
@synthesize nPageCnt, nDownCnt, nRatingCnt, fPrice, fRatingAvg, bFeatured;
@synthesize imageThumb;

- (id)init
{
    self = [super init];
    
    if( self )
    {
        sIssueId        = nil;;
        sSeriesId       = nil;
        
        sTitle          = nil;
        sSeriesName     = nil;
        sDesc           = nil;
        sPublisher      = nil;
        
        sThumbURL       = nil;
        sFileURL        = nil;
        
        sReleaseDate    = nil;
        sTag            = nil;
        sSize           = nil;
        
        nPageCnt        = 0;
        nDownCnt        = 0;
        nRatingCnt      = 0;
        fPrice          = 0.0;
        fRatingAvg      = 0.0;
        
        bFeatured       = NO;
        
    }
    
    return self;
}

- (id)initWithElement:(Element *)element
{
    self = [super init];
    
    if( self )
    {
        self.sIssueId          = [element getValueOfTag:@"issue_id"];
        self.sSeriesId         = [element getValueOfTag:@"series_id"];
        self.sReleaseDate      = [element getValueOfTag:@"release_dt"];
        self.sSize             = [element getValueOfTag:@"size"];
        self.sTitle            = [element getValueOfTag:@"title"];
        self.sDesc             = [element getValueOfTag:@"description"];
        self.sThumbURL         = [element getValueOfTag:@"thumbnail"];
        self.sPublisher        = [element getValueOfTag:@"publisher"];
        self.sFileURL          = [element getValueOfTag:@"filename"];
        self.sSeriesName       = [element getValueOfTag:@"series_nm"];
        self.sTag              = [element getValueOfTag:@"tag"];
        
        NSString * strPageCnt   = [element getValueOfTag:@"page_cnt"];
        self.nPageCnt          = [strPageCnt intValue];
        
        NSString * strPrice     = [element getValueOfTag:@"price"];
        self.fPrice            = [strPrice floatValue];
        
        NSString * strDownCnt   = [element getValueOfTag:@"download_cnt"];
        self.nDownCnt          = [strDownCnt intValue];
        
        NSString * strRatingCnt = [element getValueOfTag:@"rating_cnt"];
        self.nRatingCnt        = [strRatingCnt intValue];
        
        NSString * strRatingAvg = [element getValueOfTag:@"rating_avg"];
        self.fRatingAvg        = [strRatingAvg floatValue];
        
        NSString * strFeatured  = [element getValueOfTag:@"featured_flg"];
        self.bFeatured         = [strFeatured hasPrefix:@"Y"] ? YES : NO;        
    }
    
    return self;
}

- (void)dealloc
{
    [sIssueId release];
    [sSereisId release];
    
    [sTitle release];
    [sSeriesName release];
    [sDesc release];
    [sPublisher release];
    
    [sThumbURL release];
    [sFileURL release];
    
    [sReleaseDate release];
    [sTag release];
    [sSize release];
    
    [super dealloc];
}


@end
