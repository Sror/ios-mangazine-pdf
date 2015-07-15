//
//  IssueViewController.m
//  Magazine
//
//  Created by Myongsok Kim on 8/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "IssueViewController.h"
#import "IssueDetailViewController.h"
#import "IssueCell.h"
#import "Series.h"
#import "Issue.h"
#import "IssueFactory.h"
#import "AppConstants.h"
#import "ActivityIndicator.h"
#import "Utils.h"
#import "LibraryViewController.h"
#import "LibraryIssue.h"
#import "Library.h"
#import "Reachability.h"

#import "Element.h"
#import "ParserXML.h"

@implementation IssueViewController
@synthesize series, fetchURI;
@synthesize reachability;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if( self ) 
    {
        // Custom initialization
        
        arrIssues = [[NSMutableArray alloc] init];
        fetchURI = nil;
        series = nil;
        sortMode = SORT_DATE;
        bLoadAll = NO;
        reachability = nil;
    }
    return self;
}

- (void)dealloc 
{
    [arrIssues release];
    [fetchURI release];
    [series release];
    [reachability release];
    [segmentSort release];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //  Create Bar Button for going to Library    
    UIBarButtonItem * libraryButton = [[UIBarButtonItem alloc] initWithTitle:@"Library" style:UIBarButtonItemStyleBordered target:self action:@selector(gotoLibrary)];
    self.navigationItem.rightBarButtonItem = libraryButton;
    [libraryButton release];    
    
    //  Set TableView attribute    
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;    
    
    arrSortField = [[NSMutableArray alloc] initWithObjects: SORT_BY_DOWNLOAD_FIELD,
                    SORT_BY_TITLE_FIELD,
                    SORT_BY_DATE_FIELD, nil];    
    
    [self startPage];
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

- (void)startPage
{
    //  UISegmentControl for sorting
    segmentSort = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Download", @"Title", @"Date", nil]];
    [segmentSort setTintColor:[UIColor colorWithRed:153.0f/255.0f green:153.0f/255.0f blue:153.0f/255.0f alpha:1.0]];
    [segmentSort setSegmentedControlStyle:UISegmentedControlStyleBar];    
    [segmentSort addTarget:self action:@selector(onSort:) forControlEvents:UIControlEventValueChanged];
    [segmentSort setSelectedSegmentIndex:SORT_DATE];
    self.navigationItem.titleView = segmentSort;
    sortMode = SORT_DATE;

    if( series != nil )
    {
        bLoadAll = series.bLoadAll;
        [arrIssues addObjectsFromArray:series.arrIssues];
    }
    
    if( bLoadAll == NO )
    {
        if( [arrIssues count] == 0 )
            [self loadIssues:NUMBER_OF_ISSUES_LOAD_ONCE];
    }
    else
        [self sortWithCurrentMode];
}

- (void)loadIssues:(NSInteger)nNum
{
    if( series == nil )
        return;
        
    //  can not connect to internet and is in waiting to be constructed again
    if( reachability != nil )
        return;
    
    if( fetchURI != nil )
        return;
    
    if( bLoadAll == NO )
    {
        nLimit_Dur = nNum;
        NSString * sURL = [NSString stringWithFormat:STORE_URL_GET_ISSUES_OF_SERIES_ID, series.sSeriesId, [arrSortField objectAtIndex:sortMode], [arrIssues count], nLimit_Dur];
        self.fetchURI = [FetchURI fetchWithURL:sURL delegate:self];
        [[ActivityIndicator currentIndicator] displayActivity:@"Loading..."];
        [fetchURI startFetch];
    }
}

- (void)endPage
{
    [series.arrIssues removeAllObjects];
    if( series != nil )
    {
        [series.arrIssues addObjectsFromArray:arrIssues];
        series.bLoadAll = bLoadAll;        
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self endPage];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [segmentSort release];
    segmentSort = nil; 
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if( USER_DEVICE_IS_PAD )
        return YES;
    
    return UIInterfaceOrientationIsPortrait( interfaceOrientation );
}

#pragma mark - FetchDelegate
- (void)fetchDidFinished:(FetchURI *)fetch
{
    [[ActivityIndicator currentIndicator] hide];
    Element * rootElement = [ParserXML parse:[fetch getString]];
    NSLog(@"-------------Fetch getString------------");
    NSLog(@"%@", [fetch getString]);
    NSLog(@"--------Fetch end------------");
    if( rootElement == nil )
    {
        DLog(@"XML Parsing Error: %@", fetch.fetchURL);
    }
    else
    {
        Element * statusElement = [rootElement.chld objectAtIndex:0];
        if( [statusElement.val isEqualToString:@"OK"] )
        {
            /*
             
             0 : status
             1 : totalresultCount
             2 : resultCount
             3 : result
             4 : result...
             
             */
            
            
            for( NSUInteger i = 3 ; i < [rootElement.chld count] ; i++ )
            {
                Element * issueElement = [rootElement.chld objectAtIndex:i];
                NSString * sIssueId = [issueElement getValueOfTag:@"issue_id"];
                if( sIssueId == nil )
                    continue;
                Issue * issue = [[IssueFactory sharedFactory] issueFromId:sIssueId];
                if( issue == nil )
                {
                    issue = [[Issue alloc] initWithElement:issueElement];
                    [[IssueFactory sharedFactory] registerIssue:issue];
                    [issue release];
                }
                [arrIssues addObject:issue];
            }
            
            if( [rootElement.chld count] < 3 + nLimit_Dur )
                bLoadAll = YES;
            
            DLog(@"Success: %@", fetch.fetchURL);
            [self reloadIssues];
        }
        else
        {
            DLog(@"Status(%@): %@",statusElement.val, fetch.fetchURL);
        }
    }   
    self.fetchURI = nil;    
}

- (void)fetchDidFailed:(FetchURI *)fetch
{
    [[ActivityIndicator currentIndicator] hide];
    
    UIAlertView * alertView = [[[UIAlertView alloc] initWithTitle:@"Loading..." 
                                                          message:@"Fail to loading from store." 
                                                         delegate:@"nil" 
                                                cancelButtonTitle:nil 
                                                otherButtonTitles:@"OK", nil] autorelease];
    [alertView show];
    self.fetchURI = nil;
    
    if( reachability == nil )
    {
        self.reachability = [Reachability reachabilityForInternetConnection];
        if( [reachability currentReachabilityStatus] == NotReachable )
        {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:kReachabilityChangedNotification object:reachability];
            [reachability startNotifier];
        }        
    }
}

- (void)receiveNotification:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [reachability stopNotifier];
    self.reachability = nil;    
    [self loadIssues:NUMBER_OF_ISSUES_LOAD_ONCE];
}

- (void)reloadIssues
{
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark tableview delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{    
    NSInteger nCnt = [arrIssues count];
    
    if( ([arrIssues count] > 0) && (bLoadAll == NO) )
        nCnt++;
    
    return nCnt;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * newCell = nil;

    if( indexPath.row == [arrIssues count] )
    {
        static NSString * end_cell_id = @"next 12";
        newCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:end_cell_id] autorelease];
        newCell.textLabel.textAlignment = UITextAlignmentCenter;
        newCell.textLabel.text = @"12 Issues more...";
    }
    else
    {
        Issue * issue = [arrIssues objectAtIndex:indexPath.row];        
        NSString * strId = [NSString stringWithFormat:@"cell_identifier_%@", issue.sIssueId];
        newCell = [tableView dequeueReusableCellWithIdentifier:strId];
        
        if( newCell == nil )
        {
            newCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:strId] autorelease];
            newCell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            IssueCell * issueCell = [[IssueCell alloc] initWithNibName:@"IssueCell" bundle:nil];    
            issueCell.view.frame = CGRectMake(0, 0, [IssueCell sizeOfView].width, [IssueCell sizeOfView].height);
            [[newCell contentView] addSubview:issueCell.view];     
            [[newCell contentView] setFrame:issueCell.view.frame];
            [newCell setBackgroundColor:[UIColor clearColor]];        
            
            [issueCell.view setClipsToBounds:YES];                
            issueCell.view.layer.cornerRadius = 5;
            
            [newCell setNeedsLayout];        
            
            issueCell.sSeriesTitle  = issue.sSeriesName;
            issueCell.sIssueTitle   = issue.sTitle;
            issueCell.sThumbURL     = issue.sThumbURL;
            issueCell.nRating       = issue.nRatingCnt;
            issueCell.fAvgRating    = issue.fRatingAvg;
            issueCell.sSelectTitle  = @"Detail";
            issueCell.userData      = issue;
            
            issueCell.delegate      = self;
        }                        
    }
    
    return newCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( indexPath.row < [arrIssues count] )
         return [IssueCell sizeOfView].height + 5;
    
    return 40.0f;
}

#pragma mark tableview delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( indexPath.row == [arrIssues count] )
    {
        [self loadIssues:NUMBER_OF_ISSUES_LOAD_ONCE];
    }
}

#pragma mark - Event
- (void)onSort:(id)sender 
{
    sortMode = segmentSort.selectedSegmentIndex;
    
    if( bLoadAll )
        [self sortWithCurrentMode];
    else
    {
        [arrIssues removeAllObjects];
        [self reloadIssues];
        [self loadIssues:NUMBER_OF_ISSUES_LOAD_ONCE];
    }
}

- (void)sortWithCurrentMode
{
    switch( sortMode )
    {
        case SORT_DOWNLOAD:
            [self sortByDownload];
            break;
        case SORT_TITLE:
            [self sortByTitle];
            break;
        case SORT_DATE:
            [self sortByDate];
            break;
        default:
            break;             
    }
}

- (void)sortByDownload
{
    if( [arrIssues count] > 0 )
    {
        NSArray * arrSorted = [arrIssues sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) 
                               {
                                   Issue * issue1 = (Issue *)obj1;
                                   Issue * issue2 = (Issue *)obj2;
                                   
                                   NSNumber * downloadCnt1 = [NSNumber numberWithInt:issue1.nDownCnt];
                                   NSNumber * downloadCnt2 = [NSNumber numberWithInt:issue2.nDownCnt];
                                   
                                   return [downloadCnt2 compare:downloadCnt1];
                               }];
        
        [arrIssues removeAllObjects];
        
        [arrIssues addObjectsFromArray:arrSorted];
        
        [self reloadIssues];
    }    
}

- (void)sortByTitle
{
    if( [arrIssues count] > 0 )
    {
        NSArray * arrSorted = [arrIssues sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) 
                               {
                                   Issue * issue1 = (Issue *)obj1;
                                   Issue * issue2 = (Issue *)obj2;
                                   
                                   return [issue1.sTitle compare:issue2.sTitle];
                               }];
        
        [arrIssues removeAllObjects];
        
        [arrIssues addObjectsFromArray:arrSorted];
        
        [self reloadIssues];
    }
}

- (void)sortBySeries
{
    if( [arrIssues count] > 0 )
    {
        NSArray * arrSorted = [arrIssues sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) 
                               {
                                   Issue * issue1 = (Issue *)obj1;
                                   Issue * issue2 = (Issue *)obj2;
                                   
                                   return [issue1.sSeriesName compare:issue2.sSeriesName];
                               }];
        
        [arrIssues removeAllObjects];
        
        [arrIssues addObjectsFromArray:arrSorted];

        [self reloadIssues];
    }    
}

- (void)sortByDate
{
    if( [arrIssues count] > 0 )
    {
        NSArray * arrSorted = [arrIssues sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) 
                               {
                                   Issue * issue1 = (Issue *)obj1;
                                   Issue * issue2 = (Issue *)obj2;
                                   
                                   return [issue2.sReleaseDate compare:issue1.sReleaseDate];
                               }];
        
        [arrIssues removeAllObjects];
        
        [arrIssues addObjectsFromArray:arrSorted];
        
        [self reloadIssues];
    }    
}

#pragma mark - IssueCellDelegate
- (void)onSelect:(id)sender
{
    IssueCell * issueCell = (IssueCell *)sender;
    Issue * issue = (Issue *)issueCell.userData;
    
    IssueDetailViewController * issueDetailViewController = [[[IssueDetailViewController alloc] initWithNibName:@"IssueDetailView" bundle:nil] autorelease];        
    issueDetailViewController.issue = issue;
    [self.navigationController pushViewController:issueDetailViewController animated:YES];                
}

- (void)onThumbnail:(id)sender
{
    IssueCell * issueCell = (IssueCell *)sender;
    Issue * issue = (Issue *)issueCell.userData;
    
    LibraryIssue * libraryIssue = [[Library sharedLibrary] libraryIssueForId:issue.sIssueId];
    if( (libraryIssue != nil) && (libraryIssue.nStatus == STATUS_READABLE) )
    {
        LibraryViewController * libraryViewController = [LibraryViewController sharedLibraryViewController];
        libraryViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;            
        libraryViewController.bAutoTransitionToReading = YES;
        libraryViewController.sAutoTransitionIssueId = libraryIssue.sIssueId;
        
        if( [[Utils sharedUtils] getSystemVersionAsInteger] < __IPHONE_5_0 )
            [self presentModalViewController:libraryViewController animated:YES];
        else
            [self presentViewController:libraryViewController animated:YES completion:^(){}];
    }
    else
        [self onSelect:sender];
}

@end
