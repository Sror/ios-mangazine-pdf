//
//  SeriesViewController.m
//  Magazine
//
//  Created by Myongsok Kim on 8/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SeriesViewController.h"
#import "IssueViewController.h"
#import "LibraryViewController.h"

#import "AppConstants.h"
#import "ActivityIndicator.h"
#import "Utils.h"

#import "Element.h"
#import "ParserXML.h"

#import "Series.h"
#import "Issue.h"

@implementation SeriesViewController
@synthesize fetchURI;
@synthesize reachability;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    
    if (self) 
    {
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
    
    //  Set TableView attribute
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if( USER_DEVICE_IS_PAD )
        return YES;
    
    return UIInterfaceOrientationIsPortrait( interfaceOrientation );
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
            [self.tableView reloadData];            
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [arrSeries count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * strCellIdentifier = [NSString stringWithFormat:@"seriesview%d_%d", indexPath.section, indexPath.row];
    UITableViewCell * newCell = [tableView dequeueReusableCellWithIdentifier:strCellIdentifier];
    Series * series = [arrSeries objectAtIndex:indexPath.row];
    
    if( newCell == nil )
    {
        newCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:strCellIdentifier] autorelease];
        newCell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        IssueCell * issueCell = [[IssueCell alloc] initWithNibName:@"IssueCell" bundle:nil];
        issueCell.view.frame = CGRectMake(0, 0, [IssueCell sizeOfView].width, [IssueCell sizeOfView].height);
        [[newCell contentView] addSubview:issueCell.view];
        [[newCell contentView] setFrame:issueCell.view.frame];
        [newCell setBackgroundColor:[UIColor clearColor]];
        [issueCell.view sizeToFit];
        [issueCell.view setClipsToBounds:YES];
        issueCell.view.layer.cornerRadius = 5;

        [newCell setNeedsLayout];        

        issueCell.sSeriesTitle  = series.sTitle;
        issueCell.sThumbURL     = series.sThumbURL;
        issueCell.nRating       = series.nRatingCnt;
        issueCell.fAvgRating    = series.fRatingAvg;
        issueCell.sSelectTitle  = @"Browse";
        issueCell.userData      = series;
        issueCell.delegate      = self;
        
    }
    
    return newCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [IssueCell sizeOfView].height + 5;
}

#pragma mark - IssueCellDelegate
- (void)onSelect:(id)sender
{
    IssueCell * issueCell = (IssueCell *)sender;
    IssueViewController * issueViewController = [[IssueViewController alloc] initWithStyle:UITableViewStyleGrouped];
    issueViewController.series = issueCell.userData;
    [self.navigationController pushViewController:issueViewController animated:YES];
    [issueViewController release];
}

- (void)onThumbnail:(id)sender
{
    [self onSelect:sender];
}

@end
