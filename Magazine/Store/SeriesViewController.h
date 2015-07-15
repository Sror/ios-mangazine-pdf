//
//  SeriesViewController.h
//  Magazine
//
//  Created by Myongsok Kim on 8/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "FetchURI.h"
#import "IssueCell.h"
#import "Reachability.h"

@interface SeriesViewController : UITableViewController <FetchDelegate, IssueCellDelegate>
{    
    NSMutableArray *    arrSeries;    
    FetchURI *          fetchURI;
    Reachability *      reachability;
}
@property ( retain ) FetchURI *     fetchURI;
@property ( retain ) Reachability * reachability;

- (void)gotoLibrary;
- (void)loadingSeries;
- (void)receiveNotification:(NSNotification *)notification;

@end
