//
//  FeaturedViewController.m
//  Magazine
//
//  Created by Myongsok Kim on 8/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FeaturedViewController.h"
#import "IssueDetailViewController.h"
#import "FetchURI.h"
#import "AppConstants.h"
#import "Issue.h"
#import "IssueFactory.h"
#import "ParserXML.h"
#import "Element.h"
#import "ActivityIndicator.h"
#import "Reachability.h"

#define sFetchLoadingPageId         @"fetch_loading_page_id"
#define sFetchImageId               @"fetch_image_%@"

@interface FeaturedViewController ()
- (void)receivePushNotification:(NSNotification *)notification;
@end

@implementation FeaturedViewController
@synthesize topCell;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    
    if( self )
    {
        dicFetchURIs = [[NSMutableDictionary alloc] init];
        dicTopImages = [[NSMutableDictionary alloc] init];
        arrTopButtons = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)dealloc
{
    [dicFetchURIs release];
    [dicTopImages release];
    [arrTopButtons release];
    
    [topCell release];
    [scrollView release];
    [pageControl release];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivePushNotification:) name:kPushNotification object:nil];    
}

- (void)viewDidUnload
{
    [self setTopCell:nil];
    [scrollView release];
    scrollView = nil;
    [pageControl release];
    pageControl = nil;
    [super viewDidUnload];

    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;    
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
    
    arrSortField = [[NSMutableArray alloc] initWithObjects: SORT_BY_DOWNLOAD_FIELD,
                    SORT_BY_TITLE_FIELD,
                    SORT_BY_DATE_FIELD, nil];
    
    bLoadAll = NO;
    [self loadIssues:NUMBER_OF_ISSUES_LOAD_ONCE];
}

- (void)loadIssues:(NSInteger)nNum
{
    if( bLoadAll )
        return;
    
    //  can not connect to internet and is in waiting to be constructed again
    if( self.reachability != nil )
        return;    
    
    if( [dicFetchURIs objectForKey:sFetchLoadingPageId] != nil )
        return;
    
    NSString * sLoadURL = [NSString stringWithFormat:STORE_URL_GET_FEATURED_ISSUES, [arrSortField objectAtIndex:sortMode], [arrIssues count], nNum];
    nLimit_Dur = nNum;
    
    FetchURI * fetchURIForLoadingPage = [FetchURI fetchWithURL:sLoadURL delegate:self];
    fetchURIForLoadingPage.userData = sFetchLoadingPageId;
    [dicFetchURIs setObject:fetchURIForLoadingPage forKey:sFetchLoadingPageId];
    [[ActivityIndicator currentIndicator] displayActivity:@"Loading..."];            
    [fetchURIForLoadingPage startFetch];    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsPortrait( interfaceOrientation );
}

#pragma mark - FetchDelegate
- (void)fetchDidFinished:(FetchURI *)fetch
{
    [[ActivityIndicator currentIndicator] hide];    
    NSString * sId = fetch.userData;
    if( [sId isEqualToString:sFetchLoadingPageId] )
    {
        //  Fetched Featured Issues Info
        Element * rootElement = [ParserXML parse:[fetch getString]];
        if( rootElement == nil )
        {
            DLog(@"Fetched wrong data: %@", fetch.fetchURL);        
        }
        else
        {
            Element * statusElement = [rootElement.chld objectAtIndex:0];
            if( [statusElement.val isEqualToString:@"OK"] )
            {
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
                DLog(@"Received wrong XML: %@", fetch.fetchURL);                            
        }
    }
    else
    {
        //  Fetch Top Images;
        UIImage * image = [UIImage imageWithData:[fetch getData]];
        if( image != nil )
            [dicTopImages setObject:image forKey:fetch.userData];
        else
            [dicTopImages setObject:[UIImage imageNamed:@"loading"] forKey:fetch.userData];

        [self.tableView reloadData];
    }
    [dicFetchURIs removeObjectForKey:fetch.userData];
}

- (void)fetchDidFailed:(FetchURI *)fetch
{
    NSString * sId = fetch.userData;
    if( [sId isEqualToString:sFetchLoadingPageId] )
    {
        [super fetchDidFailed:fetch];
    }
    
    [dicFetchURIs removeObjectForKey:sId];
}



- (void)receiveNotification:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [reachability stopNotifier];
    self.reachability = nil;
    //  restart failed connections
    FetchURI * fetch = nil;
    NSEnumerator * enumer = [dicFetchURIs objectEnumerator];
    while( (fetch = [enumer nextObject]) )
    {
        [fetch startFetch];
    }
}

#pragma mark - tableview datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if( section == 0 )
        return 1;
        
    NSInteger nCnt = [arrIssues count];
    
    if( ([arrIssues count] > 0) && (bLoadAll == NO) )
        nCnt++;
    
    return nCnt;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * newCell = nil;
    NSString * sId = nil;
    if( indexPath.section == 0 )
    {
        sId = @"TopImageCell";
        newCell = [tableView dequeueReusableCellWithIdentifier:sId];
        if( newCell == nil )
        {
            [[NSBundle mainBundle] loadNibNamed:@"FeaturedTopCell" owner:self options:nil];
            
            newCell = topCell;
            self.topCell = nil;
            
            //  Scroll View Setting
            scrollView.showsVerticalScrollIndicator = NO;
            scrollView.showsHorizontalScrollIndicator = NO;
            scrollView.alwaysBounceVertical = NO;
            scrollView.alwaysBounceHorizontal = NO;
            scrollView.pagingEnabled = YES;
            scrollView.delegate = self;
            
            //  Adding Buttons for top images
            [arrTopButtons removeAllObjects];
            for( NSInteger i = 0 ; i < 4 ; i++ )
            {   
                UIButton * topButton = [UIButton buttonWithType:UIButtonTypeCustom];
                topButton.tag = i;
                topButton.frame = CGRectMake( i * scrollView.frame.size.width, 0, scrollView.frame.size.width, scrollView.frame.size.height);
                [[topButton imageView] setContentMode:UIViewContentModeScaleAspectFill];
                [topButton addTarget:self action:@selector(topImageClick:) forControlEvents:UIControlEventTouchUpInside];
                
                [scrollView addSubview:topButton];
                [arrTopButtons addObject:topButton];
            }
            
            //  Page Control Setting
            pageControl.numberOfPages = 4;
            pageControl.currentPage = 0;
            [pageControl addTarget:self action:@selector(pageChangeValue:) forControlEvents:UIControlEventValueChanged];//  When tapping a dot on UIPageControl
        }
        
        NSInteger nTopCnt = [arrIssues count] > 3 ? 4 : [arrIssues count];                
        scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * nTopCnt, scrollView.frame.size.height);
        pageControl.numberOfPages = nTopCnt;        
        [pageControl updateCurrentPageDisplay];    
        
        for(NSInteger i = 0 ; i < nTopCnt ; i++ )
        {
            UIButton * button = [arrTopButtons objectAtIndex:i];
            Issue * issue = [arrIssues objectAtIndex:i];
            UIImage * image = [dicTopImages objectForKey:issue.sIssueId];
            if( image == nil )
            {
                if( [dicFetchURIs objectForKey:issue.sIssueId] != nil )
                    continue;

                [button setImage:[UIImage imageNamed:@"loading"] forState:UIControlStateNormal];
                
                if( issue.sThumbURL != nil )
                {
                    NSString * sFileName = [issue.sThumbURL lastPathComponent];
                    NSArray * arr = [sFileName componentsSeparatedByString:@"."];
                    if( [arr count] > 0 )
                    {
                        sFileName = [NSString stringWithFormat:@"%@@2.%@", [arr objectAtIndex:0], [issue.sThumbURL pathExtension]];
                        NSString * baseURL = [issue.sThumbURL stringByDeletingLastPathComponent];
                        NSString * sThumbURL = [baseURL stringByAppendingPathComponent:sFileName];
                        DLog(@"Featured Top Image %d: %@", i, sThumbURL);
                        
                        FetchURI * fetch = [FetchURI fetchWithURL:sThumbURL delegate:self];
                        fetch.userData = issue.sIssueId;
                        fetch.identifier = i;
                        [dicFetchURIs setObject:fetch forKey:issue.sIssueId];
                        [fetch startFetch];
                    }
                }
            }
            else
                [button setImage:image forState:UIControlStateNormal];            
        }
        
    }
    else
    {
        if( indexPath.row == [arrIssues count] )
        {
            static NSString * end_cell_id = @"next 10";
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
    }
    
    return newCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( indexPath.section == 0 )
        return 170;

    if( indexPath.row < [arrIssues count] )
        return [IssueCell sizeOfView].height + 5;
    
    return 40.0f;
}

#pragma mark - tableview delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( bLoadAll == NO )
    {
        if( indexPath.row == [arrIssues count] )
            [self loadIssues:NUMBER_OF_ISSUES_LOAD_ONCE];
    }
}

#pragma mark - scrollview delegate
- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    NSInteger nCount = [arrIssues count] > 3 ? 4 : [arrIssues count];
    CGFloat pageWidth = ((UIScrollView *)sender).frame.size.width;
    pageControl.currentPage = floor( ( scrollView.contentOffset.x - pageWidth / (float)nCount) / pageWidth ) + 1;
}

#pragma mark - Sort
- (void)onSort:(id)sender
{
    NSInteger nCnt = [arrIssues count] > 3 ? 4 : [arrIssues count];
    for( NSInteger i = 0 ; i < nCnt ; i++ )
    {
        UIButton * topButtons = [arrTopButtons objectAtIndex:i];
        [topButtons setImage:nil forState:UIControlStateNormal];
    }
        
    [dicTopImages removeAllObjects];
    [dicFetchURIs removeAllObjects];
    [super onSort:sender];
}

#pragma mark - Top Image Button Click
- (void)pageChangeValue:(id)sender  
{
    CGFloat pageWidth = scrollView.frame.size.width;
    CGPoint pOffset = CGPointMake(pageControl.currentPage * pageWidth, 0);
    [scrollView setContentOffset:pOffset animated:YES];
}

- (void)topImageClick:(id)sender
{
    UIButton * btnTopImage = (UIButton *)sender;
    IssueDetailViewController * issueDetailViewController = [[[IssueDetailViewController alloc] initWithNibName:@"IssueDetailView" bundle:nil] autorelease];
    issueDetailViewController.issue = [arrIssues objectAtIndex:btnTopImage.tag];
    [self.navigationController pushViewController:issueDetailViewController animated:YES];
}

#pragma mark - Push Notification
- (void)receivePushNotification:(NSNotification *)notification
{
    bLoadAll = NO;    
    [self loadIssues:NUMBER_OF_ISSUES_LOAD_ONCE];
}
@end
