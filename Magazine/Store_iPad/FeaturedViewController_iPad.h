//
//  FeaturedViewController_iPad.h
//  Magazine
//
//  Created by Myongsok Kim on 9/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FeaturedViewController.h"
#import "MScrollView.h"

@interface FeaturedViewController_iPad : IssueViewController <MScrollViewDataSource, MScrollViewDelegate>
{
    UILabel * labelTitle;
    UIPageControl * pageControl;
    MScrollView * featuredScrollView;
    
    IBOutlet UIButton *btnTop1;
    IBOutlet UIButton *btnTop2;
    IBOutlet UIButton *btnTop3;
    IBOutlet UIButton *btnTop4;
    
    IBOutlet UIImageView *imageViewTop0;
    IBOutlet UIImageView *imageViewTop1;
    IBOutlet UIImageView *imageViewTop2;
    IBOutlet UIImageView *imageViewTop3;
    IBOutlet UIImageView *imageViewTop4;
    
    IBOutlet UIView *containerView;
    
    NSInteger nPageNumber;
    NSInteger nTotalPage;
    
    NSMutableDictionary * dicFetchURIs;
    NSMutableDictionary * dicTopImages;
    BOOL                  bImageDown;
    NSInteger             nCurIndex;
    NSTimer *             aniTimer;
}

@property ( retain ) MScrollView * featuredScrollView;
@property ( retain, nonatomic ) IBOutlet UITableViewCell *topCell_iPad;


@end
