//
//  FeaturedViewController.h
//  Magazine
//
//  Created by Myongsok Kim on 8/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "IssueViewController.h"

@interface FeaturedViewController : IssueViewController <UIScrollViewDelegate>
{
    NSMutableDictionary * dicFetchURIs;
    NSMutableDictionary * dicTopImages;
    NSMutableArray * arrTopButtons;    
    
    
    IBOutlet UIScrollView *  scrollView;
    IBOutlet UIPageControl * pageControl;
}

@property (retain, nonatomic) IBOutlet UITableViewCell *topCell;

- (void)pageChangeValue:(id)sender;
- (void)topImageClick:(id)sender;

@end
