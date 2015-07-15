//
//  IssueViewController_iPad.h
//  Magazine
//
//  Created by Myongsok Kim on 9/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "IssueViewController.h"
#import "MScrollView.h"

@interface IssueViewController_iPad : IssueViewController <MScrollViewDelegate, MScrollViewDataSource>
{
    UILabel * labelTitle;
    MScrollView * scrollView;
    UIPageControl * pageControl;    
    NSInteger nPageNumber;
    NSInteger nTotalPage;
}
@property ( retain ) MScrollView * scrollView;

@end
