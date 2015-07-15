//
//  SeriesViewController_iPad.m
//  Magazine
//
//  Created by Myongsok Kim on 9/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SeriesViewController_iPad.h"
#import "IssueViewController_iPad.h"
#import "LibraryViewController.h"

#import "AppConstants.h"
#import "ActivityIndicator.h"
#import "Utils.h"

#import "Element.h"
#import "ParserXML.h"

#import "Series.h"
#import "Issue.h"

@implementation SeriesViewController_iPad
@synthesize scrollView;
@synthesize fetchURI;
@synthesize reachability;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if( self )
    {
        // Custom initialization
        arrSeries = [[NSMutableArray alloc] init];        
        fetchURI = nil;
        reachability = nil;        
    }
    return self;
}

- (void)dealloc 
{
    [arrSeries release];
    [fetchURI release];
    [reachability release];    
    [scrollView release];
    [super dealloc];
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //  Create Bar Button for going to Library    
    self.navigationItem.title = @"Series";
    UIBarButtonItem * libraryButton = [[UIBarButtonItem alloc] initWithTitle:@"Library" style:UIBarButtonItemStyleBordered target:self action:@selector(gotoLibrary)];
    self.navigationItem.rightBarButtonItem = libraryButton;
    [libraryButton release];    
    

    self.scrollView.dataSource = self;    
    self.scrollView.pagingEnabled = NO;
    self.scrollView.bPageFit = YES;
    
    //  Loading series info from server.
    [self loadingSeries];    
    
    

}

- (void)loadingSeries
{
    self.fetchURI = [FetchURI fetchWithURL:STORE_URL_GET_SERIES delegate:self];
    [[ActivityIndicator currentIndicator] displayActivity:@"Loading..."];
    [fetchURI startFetch];
}

- (void)gotoLibrary
{
    LibraryViewController * libraryViewController = [LibraryViewController sharedLibraryViewController];
    libraryViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    
    if( [[Utils sharedUtils] getSystemVersionAsInteger] < __IPHONE_5_0 )
        [self presentModalViewController:libraryViewController animated:YES];
    else
        [self presentViewController:libraryViewController animated:YES completion:^(){}];
}

- (void)viewDidUnload
{
    [self setScrollView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //  When back from Issue View
    [self.scrollView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //  When back from other tab
    [self.scrollView reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

#pragma mark -
#pragma mark FetchDelegate

- (void)fetchDidFinished:(FetchURI *)fetch
{
    Element * rootElement = [ParserXML parse:[fetch getString]];
    if( rootElement == nil )
    {
        DLog(@"XML Parse Error: %@", fetch.fetchURL);
        [self fetchDidFailed:fetch];
    }
    else
    {
        Element * successElement = [rootElement.chld objectAtIndex:0];
        if( [successElement.val isEqualToString:@"OK"] )
        {
            Element * resultCountElement = [rootElement.chld objectAtIndex:1];
            int seriesCnt = [resultCountElement.val intValue];
            [arrSeries removeAllObjects];
            for( int i = 0 ; i < seriesCnt ; i++ )
            {
                Element * theSeriesElement = [rootElement.chld objectAtIndex:i+2];
                Series * series = [[Series alloc] initWithElement:theSeriesElement];
                [arrSeries addObject:series];
                [series release];
            }
            
            [[ActivityIndicator currentIndicator] hide];
            DLog(@"Success: %@", fetch.fetchURL);
            [self.scrollView reloadData];            
            self.fetchURI = nil;
            
        }
        else
        {
            DLog(@"Received wrong XML: %@", fetch.fetchURL)
            
            [self fetchDidFailed:fetch];
        }
    } 
}

- (void)fetchDidFailed:(FetchURI *)fetch
{
    [[ActivityIndicator currentIndicator] hide];
    
    UIAlertView * alertView = [[[UIAlertView alloc] initWithTitle:@"Loading series..." 
                                                          message:@"Fail to loading from store." 
                                                         delegate:@"nil" 
                                                cancelButtonTitle:nil 
                                                otherButtonTitles:@"OK", nil] autorelease];
    [alertView show];
    self.fetchURI = nil;
    
    self.reachability = [Reachability reachabilityForInternetConnection];
    if( [reachability currentReachabilityStatus] == NotReachable )
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:kReachabilityChangedNotification object:reachability];
        [reachability startNotifier];
    }
}

- (void)receiveNotification:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [reachability stopNotifier];
    self.reachability = nil;    
    [self loadingSeries];
}

#pragma mark - MScrollViewDataSource
- (NSInteger)numberOfItemsInMScrollView:(MScrollView *)sv
{
    return [arrSeries count];
}

- (MScrollViewItem *)MScrollView:(MScrollView *)sv itemAtIndex:(NSInteger)index
{
    NSString * strCellIdentifier = [NSString stringWithFormat:@"seriesview_%d", index];
    MScrollViewItem * newCell = [sv dequeueReusableItemWithIdentifier:strCellIdentifier];
    Series * series = [arrSeries objectAtIndex:index];
    
    if( newCell == nil )
    {        
        IssueCell * issueCell = [[IssueCell alloc] initWithNibName:@"IssueCell" bundle:nil];        
        issueCell.view.frame = CGRectMake(0, 0, [IssueCell sizeOfView].width, [IssueCell sizeOfView].height);
        [issueCell.view sizeToFit];
        //issueCell.view.layer.borderWidth = 1.0f;
        //issueCell.view.layer.borderColor = [UIColor blackColor].CGColor;
        
        issueCell.sSeriesTitle  = series.sTitle;
        issueCell.sThumbURL     = series.sThumbURL;
        issueCell.nRating       = series.nRatingCnt;
        issueCell.fAvgRating    = series.fRatingAvg;
        issueCell.sSelectTitle  = @"Browse";
        issueCell.userData      = series;
        issueCell.delegate      = self;
            
        newCell = [[[MScrollViewItem alloc] init] autorelease];
        newCell.view = issueCell.view;
        newCell.reuseIdentifier = strCellIdentifier;
    }
    
    return newCell;
}

- (CGSize)MScrollView:(MScrollView *)scrollView sizeForItemsOrientation:(UIInterfaceOrientation)orientation
{
    return CGSizeMake(340, IPAD_ISSUE_HEIGHT);    
}

#pragma mark - IssueCellDelegate
- (void)onSelect:(id)sender
{
    IssueCell * issueCell = (IssueCell *)sender;
    IssueViewController_iPad * issueViewController = [[IssueViewController_iPad alloc] initWithStyle:UITableViewStyleGrouped];
    issueViewController.series = issueCell.userData;
    [self.navigationController pushViewController:issueViewController animated:YES];
    [issueViewController release];
}

- (void)onThumbnail:(id)sender
{
    [self onSelect:sender];
}
@end
