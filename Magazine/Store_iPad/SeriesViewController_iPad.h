//
//  SeriesViewController_iPad.h
//  Magazine
//
//  Created by Myongsok Kim on 9/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MScrollView.h"

#import "FetchURI.h"
#import "IssueCell.h"
#import "Reachability.h"


@interface SeriesViewController_iPad : UIViewController <MScrollViewDataSource, FetchDelegate, IssueCellDelegate>
{
    NSMutableArray *    arrSeries;    
    FetchURI *          fetchURI;
    Reachability *      reachability;    
}

@property (retain, nonatomic) IBOutlet MScrollView *scrollView;
@property ( retain ) FetchURI *     fetchURI;
@property ( retain ) Reachability * reachability;

- (void)gotoLibrary;
- (void)loadingSeries;
- (void)receiveNotification:(NSNotification *)notification;

@end
