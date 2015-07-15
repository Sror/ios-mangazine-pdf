//
//  IssueViewController.h
//  Magazine
//
//  Created by Myongsok Kim on 8/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "IssueCell.h"
#import "FetchURI.h"

enum SORT_MODE
{
    SORT_DOWNLOAD   = 0,
    SORT_TITLE,
    SORT_DATE,
    SORT_SERIES,    
};

@class Series;
@class Reachability;
@interface IssueViewController : UITableViewController <IssueCellDelegate, FetchDelegate>
{
    UISegmentedControl *    segmentSort;
    Series *                series;
    BOOL                    bLoadAll;
    
    enum
    SORT_MODE           sortMode;
    NSMutableArray *    arrSortField;    
    NSMutableArray *    arrIssues;
    
    FetchURI *          fetchURI;
    NSInteger           nLimit_Dur;
    
    Reachability *      reachability;
}

@property ( retain ) Series *   series;
@property ( retain ) FetchURI * fetchURI;
@property ( retain ) Reachability * reachability;

- (void)startPage;
- (void)loadIssues:(NSInteger)nNum;
- (void)endPage;
- (void)receiveNotification:(NSNotification *)notification;
- (void)reloadIssues;

- (void)onSort:(id)sender;
- (void)sortWithCurrentMode;
- (void)sortByDownload;
- (void)sortByTitle;
- (void)sortByDate;
- (void)sortBySeries;

- (void)gotoLibrary;

@end
