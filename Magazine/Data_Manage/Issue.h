//
//  Issue.h
//  Magazine
//
//  Created by Myongsok Kim on 8/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Element;
@interface Issue : NSObject
{    
    
    NSString *   sIssueId;
    NSString *   sSereisId;
    
    NSString *  sTitle;
    NSString *  sSeriesName;   
    NSString *  sDesc;
    NSString *  sPublisher;
    

    NSString *  sThumbURL;
    NSString *  sFileURL;
    
    
    NSString *  sReleaseDate;
    NSString *  sTag;
    NSString *  sSize;
    
    int         nPageCnt;
    float       fPrice;
    BOOL        bFeatured;
    int         nDownCnt;
    int         nRatingCnt;
    float       fRatingAvg;
    
    UIImage *   imageThumb;
}

@property ( retain ) NSString *     sIssueId;
@property ( retain ) NSString *     sSeriesId;

@property ( retain ) NSString * sTitle;
@property ( retain ) NSString * sSeriesName;
@property ( retain ) NSString * sDesc;
@property ( retain ) NSString * sPublisher;
@property ( retain ) NSString * sThumbURL;
@property ( retain ) NSString * sFileURL;

@property ( retain ) NSString * sReleaseDate;
@property ( retain ) NSString * sTag;
@property ( retain ) NSString * sSize;

@property ( assign ) int    nPageCnt;
@property ( assign ) float  fPrice;
@property ( assign ) BOOL   bFeatured;
@property ( assign ) int    nDownCnt;
@property ( assign ) int    nRatingCnt;
@property ( assign ) float  fRatingAvg;

@property ( retain ) UIImage * imageThumb;

- (id)initWithElement:(Element *)element;

@end
