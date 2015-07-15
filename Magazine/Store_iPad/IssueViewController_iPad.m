//
//  IssueViewController_iPad.m
//  Magazine
//
//  Created by Myongsok Kim on 9/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "IssueViewController_iPad.h"
#import "Series.h"
#import "Issue.h"
#import "IssueCell.h"
#import "AppConstants.h"
#import "ActivityIndicator.h"
#import "ParserXML.h"
#import "IssueFactory.h"

@implementation IssueViewController_iPad
@synthesize scrollView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if( self )
    {
        scrollView = nil;
        nTotalPage = -1;
    }
    return self;
}

- (void)dealloc
{
    
    [scrollView release];
    [super dealloc];
}

#pragma mark - View lifecycle
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.scrollView reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)reloadIssues
{
    [scrollView reloadData];
}

#pragma mark - FetchDelegate
- (void)fetchDidFinished:(FetchURI *)fetch
{
    [[ActivityIndicator currentIndicator] hide];    
    Element * rootElement = [ParserXML parse:[fetch getString]];
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
            
            if( nTotalPage < 0 )
            {
                Element * totalCnt = [rootElement.chld objectAtIndex:1];
                nTotalPage = [totalCnt.val intValue] / NUMBER_OF_ITEMS_ONE_PAGE + ( [totalCnt.val intValue] % NUMBER_OF_ITEMS_ONE_PAGE ? 1 : 0 );
                if( nTotalPage < 10 )
                {
                    pageControl.hidden = NO;
                    pageControl.numberOfPages = nTotalPage;                
                }
                else
                {
                    pageControl.numberOfPages = 0;
                    pageControl.hidden = YES;
                }                                            
            }

            
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

#pragma mark tableview delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * strIdentifier = [NSString stringWithFormat:@"cell_%d_%d", indexPath.section, indexPath.row];
    UITableViewCell * newCell = [tableView dequeueReusableCellWithIdentifier:strIdentifier];
    if( newCell == nil )
    {
        newCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:strIdentifier] autorelease];
        if( (indexPath.section == 0 ) && (indexPath.row == 0) )
        {
            labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, IPAD_LABEL_WIDTH, IPAD_LABEL_HEIGHT)];
            labelTitle.font = [UIFont fontWithName:@"Courier New" size:22.0f];
            if( series != nil )
                labelTitle.text = [NSString stringWithFormat:@"%@:  Page 1", series.sTitle];
            else
                labelTitle.text = @"Page 1";
            labelTitle.backgroundColor = [UIColor clearColor];
            [newCell addSubview:labelTitle];
            
            
            self.scrollView = [[[MScrollView alloc] initWithFrame:CGRectZero] autorelease];
            self.scrollView.dataSource = self;
            self.scrollView.actionDelegate = self;
            self.scrollView.pagingEnabled = YES;
            self.scrollView.bPageFit = YES;
            
            pageControl = [[UIPageControl alloc] initWithFrame:CGRectZero];                
            pageControl.autoresizingMask |= UIViewAutoresizingFlexibleBottomMargin;
            
            UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
            CGRect scrollViewRect;
            if( UIInterfaceOrientationIsLandscape(orientation) )
            {
                scrollViewRect = CGRectMake(0, IPAD_LABEL_HEIGHT + 5, 1024, IPAD_ISSUE_HEIGHT * 2 + 2);
                self.scrollView.frame = scrollViewRect;
            }
            else
            {
                scrollViewRect = CGRectMake(0, IPAD_LABEL_HEIGHT + 5, 768, IPAD_ISSUE_HEIGHT * 3 + 3); 
                self.scrollView.frame = scrollViewRect;
            } 
            pageControl.frame = CGRectMake( 160, scrollViewRect.origin.y + scrollViewRect.size.height, 0, 20);            
            
            [newCell addSubview:pageControl];                        
            [newCell addSubview:self.scrollView];
            [newCell setBackgroundColor:[UIColor clearColor]];
            [newCell setSelectionStyle:UITableViewCellSelectionStyleNone];
            
            
            [self performSelector:@selector(reloadIssues) withObject:nil afterDelay:0.5];
        }        
    }
    

    return newCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat fHeight;
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if( UIInterfaceOrientationIsLandscape(orientation) )
    {
        if( scrollView != nil )
            self.scrollView.frame = CGRectMake(0, IPAD_LABEL_HEIGHT + 5, 1024, IPAD_ISSUE_HEIGHT * 2 + 2);
        fHeight = IPAD_ISSUE_HEIGHT * 2 + 2 + IPAD_LABEL_HEIGHT;
    }
    else
    {
        if( scrollView != nil )        
            self.scrollView.frame = CGRectMake(0, IPAD_LABEL_HEIGHT + 5, 768, IPAD_ISSUE_HEIGHT * 3 + 3);        
        fHeight = IPAD_ISSUE_HEIGHT * 3 + 3 + IPAD_LABEL_HEIGHT;
    }
    
    CGRect pageControlRect = pageControl.frame;
    pageControlRect.origin.y = scrollView.frame.origin.y + scrollView.frame.size.height;
    pageControl.frame = pageControlRect;
    
    
    return fHeight;
}

#pragma mark - MScrollView DataSource
- (NSInteger)numberOfItemsInMScrollView:(MScrollView *)sv
{
    return [arrIssues count];
}

- (MScrollViewItem *)MScrollView:(MScrollView *)sv itemAtIndex:(NSInteger)index
{
    Issue * issue = [arrIssues objectAtIndex:index];                    
    NSString * strCellIdentifier = [NSString stringWithFormat:@"seriesview_%@", issue.sIssueId];
    MScrollViewItem * newCell = [sv dequeueReusableItemWithIdentifier:strCellIdentifier];
    
    if( newCell == nil )
    {
        IssueCell * issueCell = [[IssueCell alloc] initWithNibName:@"IssueCell" bundle:nil];    
        issueCell.view.frame = CGRectMake(0, 0, [IssueCell sizeOfView].width, [IssueCell sizeOfView].height);
        [issueCell.view sizeToFit];
        //issueCell.view.layer.borderWidth = 1.0f;
        //issueCell.view.layer.borderColor = [UIColor blackColor].CGColor;

        issueCell.sSeriesTitle  = issue.sSeriesName;
        issueCell.sIssueTitle   = issue.sTitle;
        issueCell.sThumbURL     = issue.sThumbURL;
        issueCell.nRating       = issue.nRatingCnt;
        issueCell.fAvgRating    = issue.fRatingAvg;
        issueCell.sSelectTitle  = @"Detail";
        issueCell.userData      = issue;
        
        issueCell.delegate      = self;
        
        newCell = [[[MScrollViewItem alloc] init] autorelease];
        newCell.view = issueCell.view;
        newCell.reuseIdentifier = strCellIdentifier;
    }
    
    return newCell;
}

- (CGSize)MScrollView:(MScrollView *)sv sizeForItemsOrientation:(UIInterfaceOrientation)orientation
{
    return CGSizeMake(340, IPAD_ISSUE_HEIGHT);
}

#pragma mark - MScrollView Delegate
- (void)MScrollView:(MScrollView *)sv scrolledToNthPage:(NSInteger)nPageNm
{
    DLog(@"Page %d", nPageNm);
    
    if( bLoadAll == NO )
    {
        NSInteger nItemsPerPage = [sv numberOfItemsPerOnePage];
        if( nItemsPerPage * nPageNm + NUMBER_OF_ITEMS_ONE_PAGE > [arrIssues count] )
        {
            if( fetchURI == nil || fetchURI.status != FETCH_STATUS_FETCHING )
                [self loadIssues:NUMBER_OF_ITEMS_ONE_PAGE * 2];
        }
    }
    
    if( nPageNumber != nPageNm )
    {
        nPageNumber = nPageNm;
        if( series != nil )
            labelTitle.text = [NSString stringWithFormat:@"%@:  Page %d", series.sTitle, nPageNumber]; 
        else
            labelTitle.text = [NSString stringWithFormat:@"Page %d", nPageNumber];
        
        pageControl.currentPage = nPageNumber - 1;
    }
}

@end
