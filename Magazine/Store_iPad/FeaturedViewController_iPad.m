//
//  FeaturedViewController_iPad.m
//  Magazine
//
//  Created by Myongsok Kim on 9/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FeaturedViewController_iPad.h"
#import "IssueDetailViewController.h"
#import "Series.h"
#import "Issue.h"
#import "IssueCell.h"
#import "AppConstants.h"
#import "ActivityIndicator.h"
#import "ParserXML.h"
#import "IssueFactory.h"
#import <QuartzCore/QuartzCore.h>


#define ISSUE_LOADING_ID        @"issue_load_id"
#define IMAGE_LOADING_ID        @"image_load_id"
#define IMAGE_FETCHER_CHIN      10000

@interface FeaturedViewController_iPad ()
- (void)downloadTopImages;
- (NSString *)imageURL2x:(NSString *)url;
- (NSString *)imageURL3x:(NSString *)url;
- (void)animationTopImages;
- (void)animationFinished;
- (void)changeTopImages:(NSTimer *)theTimer;
- (void)receivePushNotification:(NSNotification *)notification;
@end


@implementation FeaturedViewController_iPad
@synthesize topCell_iPad;
@synthesize featuredScrollView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if( self )
    {
        // Custom initialization
        
        dicFetchURIs = [[NSMutableDictionary alloc] init];
        dicTopImages = [[NSMutableDictionary alloc] init];
        
        aniTimer = nil;
        nTotalPage = -1;
    }
    return self;
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivePushNotification:) name:kPushNotification object:nil];
    
    
//    self.tableView.backgroundView = nil;
//    self.tableView.backgroundColor = [UIColor blueColor];
}


- (void)viewDidUnload
{
    [self setTopCell_iPad:nil];
    [btnTop1 release];
    btnTop1 = nil;
    [btnTop2 release];
    btnTop2 = nil;
    [btnTop3 release];
    btnTop3 = nil;
    [btnTop4 release];
    btnTop4 = nil;
    [imageViewTop1 release];
    imageViewTop1 = nil;
    [imageViewTop2 release];
    imageViewTop2 = nil;
    [imageViewTop3 release];
    imageViewTop3 = nil;
    [imageViewTop4 release];
    imageViewTop4 = nil;
    [imageViewTop0 release];
    imageViewTop0 = nil;
    [containerView release];
    containerView = nil;
    [labelTitle release];
    labelTitle = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPushNotification object:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self reloadIssues];
    [self animationTopImages];    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if( aniTimer != nil )
    {        
        [aniTimer invalidate];
        aniTimer = nil;
    }
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

- (void)dealloc 
{
    [topCell_iPad release];
    [btnTop1 release];
    [btnTop2 release];
    [btnTop3 release];
    [btnTop4 release];
    [imageViewTop1 release];
    [imageViewTop2 release];
    [imageViewTop3 release];
    [imageViewTop4 release];
    
    [dicFetchURIs release];
    [dicTopImages release];
    [imageViewTop0 release];
    [containerView release];
    [labelTitle release];
    [super dealloc];
}

- (void)loadIssues:(NSInteger)nNum
{
    if( bLoadAll )
        return;
    
    //  can not connect to internet and is in waiting to be constructed again
    if( self.reachability != nil )
        return;
    
    //  fetching now
    if( [dicFetchURIs objectForKey:ISSUE_LOADING_ID] != nil )
        return;
        
    NSString * sLoadURL = [NSString stringWithFormat:STORE_URL_GET_FEATURED_ISSUES, [arrSortField objectAtIndex:sortMode], [arrIssues count], nNum];
    nLimit_Dur = nNum;
    
    FetchURI * fetchURIForLoadingPage = [FetchURI fetchWithURL:sLoadURL delegate:self];
    fetchURIForLoadingPage.userData = ISSUE_LOADING_ID;
    [dicFetchURIs setObject:fetchURIForLoadingPage forKey:ISSUE_LOADING_ID];
    [[ActivityIndicator currentIndicator] displayActivity:@"Loading..."];            
    [fetchURIForLoadingPage startFetch];    
}

- (void)reloadIssues
{
    [featuredScrollView reloadData];
    [self.tableView reloadData];
}

- (void)onSort:(id)sender 
{
    if( aniTimer != nil )
    {
        [aniTimer invalidate];
        aniTimer = nil;
    }
    bImageDown = NO;
    imageViewTop0.image = nil;
    imageViewTop1.image = nil;
    imageViewTop2.image = nil;
    imageViewTop3.image = nil;
    imageViewTop4.image = nil;
    [dicTopImages removeAllObjects];
    [dicFetchURIs removeAllObjects];
    [super onSort:sender];
}

#pragma mark - FetchDelegate
- (void)fetchDidFinished:(FetchURI *)fetch
{
    [[ActivityIndicator currentIndicator] hide];        
    
    NSString * sId = fetch.userData;
    if( [ISSUE_LOADING_ID isEqualToString:sId] )
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
                
                if( nTotalPage < 0 )
                {
                    Element * totalCnt = [rootElement.chld objectAtIndex:1];
                    nTotalPage = [totalCnt.val intValue] / NUMBER_OF_ITEMS_ONE_PAGE + ( [totalCnt.val intValue] % NUMBER_OF_ITEMS_ONE_PAGE ? 1 : 0 ) ;
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
                DLog(@"Received wrong XML: %@", fetch.fetchURL);                            
        }        
    }
    else
    {
        UIImage * image = [UIImage imageWithData:[fetch getData]];
        if( image == nil )
            image = [UIImage imageNamed:@"loading.png"];
        [dicTopImages setObject:image forKey:sId];
        
        switch (fetch.identifier)
        {
            case IMAGE_FETCHER_CHIN:
                imageViewTop0.image = image;
                break;
            case 0:
                imageViewTop1.image = image;
                break;
            case 1:
                imageViewTop2.image = image;
                break;
            case 2:
                imageViewTop3.image = image;
                break;
            case 3:
                imageViewTop4.image = image;
                break;
            default:
                break;
        }
        
        
        int nNum = ( [arrIssues count] > 4 ? 4 : [arrIssues count] ) * 2;
        if( nNum == [dicTopImages count] )
        {
            DLog(@"All top images are downloaded");
            [self animationTopImages];
        }
        
    }
    
    [dicFetchURIs removeObjectForKey:sId];
}

- (void)fetchDidFailed:(FetchURI *)fetch
{
    NSString * sId = fetch.userData;
    if( [ISSUE_LOADING_ID isEqualToString:sId] )
        [super fetchDidFailed:fetch];
    
    [dicFetchURIs removeObjectForKey:fetch.userData];
}

#pragma mark - tableview delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * sId;
    UITableViewCell * newCell = nil;
    switch( indexPath.section )
    {
    case 0:
        sId = @"TopCell_iPad";
        newCell = [tableView dequeueReusableCellWithIdentifier:sId];
        if( newCell == nil )
        {
            [[NSBundle mainBundle] loadNibNamed:@"FeaturedTopCell_iPad" owner:self options:nil];
            newCell = self.topCell_iPad;
            self.topCell_iPad = nil;
            
            containerView.layer.masksToBounds = YES;
            containerView.layer.cornerRadius = 10.0f;            

            [btnTop1 addTarget:self action:@selector(topImageClick:) forControlEvents:UIControlEventTouchUpInside];
            [btnTop2 addTarget:self action:@selector(topImageClick:) forControlEvents:UIControlEventTouchUpInside];
            [btnTop3 addTarget:self action:@selector(topImageClick:) forControlEvents:UIControlEventTouchUpInside];
            [btnTop4 addTarget:self action:@selector(topImageClick:) forControlEvents:UIControlEventTouchUpInside];            
        }
            
        if( bImageDown == NO )
            [self downloadTopImages];            
            
        break;
    case 1:
        sId = @"Featured_Cell_iPad";
        newCell = [tableView dequeueReusableCellWithIdentifier:sId];
        if( newCell == nil )
        {
            newCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:sId] autorelease];
            labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, IPAD_LABEL_WIDTH, IPAD_LABEL_HEIGHT)];
            labelTitle.font = [UIFont fontWithName:@"Courier New" size:22.0f];
            labelTitle.text = [NSString stringWithFormat:@"Page 1"];
            labelTitle.backgroundColor = [UIColor clearColor];
            [newCell addSubview:labelTitle];
            
            
            self.featuredScrollView = [[[MScrollView alloc] initWithFrame:CGRectZero] autorelease];
            self.featuredScrollView.dataSource = self;
            self.featuredScrollView.actionDelegate = self;
            self.featuredScrollView.pagingEnabled = YES;
            self.featuredScrollView.bPageFit = YES;
            
            pageControl = [[UIPageControl alloc] initWithFrame:CGRectZero];                
            pageControl.autoresizingMask |= UIViewAutoresizingFlexibleBottomMargin;
        
            
            UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
            CGRect scrollViewFrame;
            if( UIInterfaceOrientationIsLandscape(orientation) )
            {
                scrollViewFrame = CGRectMake(0, IPAD_LABEL_HEIGHT + 5, 1024, IPAD_ISSUE_HEIGHT * 2 + 2);
                self.featuredScrollView.frame = scrollViewFrame;                
            }
            else
            {
                scrollViewFrame = CGRectMake(0, IPAD_LABEL_HEIGHT + 5, 768, IPAD_ISSUE_HEIGHT * 3 + 3); 
                self.featuredScrollView.frame = scrollViewFrame;
            }                    
            pageControl.frame = CGRectMake( 160, scrollViewFrame.origin.y + scrollViewFrame.size.height, 0, 20);                

            [newCell addSubview:self.featuredScrollView];
            [newCell addSubview:pageControl];
            [newCell setBackgroundColor:[UIColor clearColor]];
            [newCell setSelectionStyle:UITableViewCellSelectionStyleNone];
            
            [self performSelector:@selector(reloadIssues) withObject:nil afterDelay:0.5];
        }
                
        break;
    default:
        break;
    }
    
    return newCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat fHeight = 44.0f;
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    switch( indexPath.section )
    {
        case 0:
            fHeight = 340;
            break;
        case 1:
            if( UIInterfaceOrientationIsLandscape(orientation) )
            {
                if( featuredScrollView != nil )
                    self.featuredScrollView.frame = CGRectMake(0, IPAD_LABEL_HEIGHT + 5, 1024, IPAD_ISSUE_HEIGHT * 2 + 2);
                fHeight = IPAD_ISSUE_HEIGHT * 2 + 2 + IPAD_LABEL_HEIGHT + 50;
            }
            else
            {
                if( featuredScrollView != nil )        
                    self.featuredScrollView.frame = CGRectMake(0, IPAD_LABEL_HEIGHT + 5, 768, IPAD_ISSUE_HEIGHT * 3 + 3);        
                fHeight = IPAD_ISSUE_HEIGHT * 3 + 3 + IPAD_LABEL_HEIGHT + 50;
            }            
                
            CGRect pageControlRect = pageControl.frame;
            pageControlRect.origin.y = featuredScrollView.frame.origin.y + featuredScrollView.frame.size.height;
            pageControl.frame = pageControlRect;
            break;
        default:
            break;
    }
        
    return fHeight;
}

#pragma mark - MScrollViewDataSource
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
    if( bLoadAll == NO )
    {
        NSInteger nItemsPerPage = [sv numberOfItemsPerOnePage];
        if( nItemsPerPage * nPageNm + NUMBER_OF_ITEMS_ONE_PAGE > [arrIssues count] )
        {
            [self loadIssues:NUMBER_OF_ITEMS_ONE_PAGE * 2];
        }
    }
    
    
    
    if( nPageNumber != nPageNm )
    {
        nPageNumber = nPageNm;
        labelTitle.text = [NSString stringWithFormat:@"Page %d", nPageNumber]; 
        
        pageControl.currentPage = nPageNumber - 1;
    }
}

#pragma mark - Private Methods
- (void)downloadTopImages
{
    if( [arrIssues count] == 0 )
        return;
    
    [dicTopImages removeAllObjects];
    [dicFetchURIs removeAllObjects];
    bImageDown = YES;
    
    for( NSInteger i = 0 ; (i < 4) && ([arrIssues count] > i) ; i++ )
    {
        Issue * issue = [arrIssues objectAtIndex:i];

        NSString * url2x = [self imageURL2x:issue.sThumbURL];
        DLog(@"image downloading: %@", url2x);
        FetchURI * fetch2x = [FetchURI fetchWithURL:url2x delegate:self];
        fetch2x.identifier = i;
        NSString * userData2x = [NSString stringWithFormat:@"%@_%d", IMAGE_LOADING_ID, i];
        fetch2x.userData = userData2x;
        [dicFetchURIs setObject:fetch2x forKey:userData2x];
        [fetch2x startFetch];
        
        NSString * url3x = [self imageURL3x:issue.sThumbURL];
        DLog(@"image downloading: %@", url3x);
        FetchURI * fetch3x = [FetchURI fetchWithURL:url3x delegate:self];
        fetch3x.identifier = IMAGE_FETCHER_CHIN + i;
        NSString * userData3x = [NSString stringWithFormat:@"%@_%d", IMAGE_LOADING_ID, IMAGE_FETCHER_CHIN + i]; 
        fetch3x.userData = userData3x;
        [dicFetchURIs setObject:fetch3x forKey:userData3x];
        [fetch3x startFetch];
    }
}

- (NSString *)imageURL2x:(NSString *)url
{
    if( url == nil )
        return nil;
    
    NSString * urlWithoutExtension = [url stringByDeletingPathExtension];
    NSString * url2x = [NSString stringWithFormat:@"%@@2.%@", urlWithoutExtension, [url pathExtension]];
        
    return url2x;
}

- (NSString *)imageURL3x:(NSString *)url
{
    if( url == nil )
        return nil;
    
    NSString * urlWithoutExtension = [url stringByDeletingPathExtension];
    NSString * url3x = [NSString stringWithFormat:@"%@@3.%@", urlWithoutExtension, [url pathExtension]];
    
    return url3x;    
}

- (void)animationTopImages
{    
    if( [arrIssues count] == 0 )
        return;
    
    NSInteger nNum = ( [arrIssues count] > 4 ? 4 : [arrIssues count] ) * 2;
    
    if( nNum == [dicTopImages count] )
    {
        
        nCurIndex = 0;
        
        NSString * id1 = [NSString stringWithFormat:@"%@_%d", IMAGE_LOADING_ID, IMAGE_FETCHER_CHIN + nCurIndex];
        UIImage * image1 = [dicTopImages objectForKey:id1];            
        imageViewTop0.image = image1;
        CGRect frame;
        frame = imageViewTop1.frame;
        frame.origin.y = -FEATURED_PAGE_TOP_IMAGE_HEIGHT;
        imageViewTop1.frame = frame;
        
        frame = imageViewTop2.frame;
        frame.origin.y = 0;
        imageViewTop2.frame = frame;
        
        frame = imageViewTop3.frame;
        frame.origin.y = FEATURED_PAGE_TOP_IMAGE_HEIGHT;
        imageViewTop3.frame = frame;
        
        frame = imageViewTop4.frame;
        frame.origin.y = FEATURED_PAGE_TOP_IMAGE_HEIGHT * 2;
        imageViewTop4.frame = frame;        

        
        if( aniTimer != nil )
            [aniTimer invalidate];
        
        aniTimer = [NSTimer scheduledTimerWithTimeInterval:FEATURED_PAGE_ANIMATION_DURATION 
                                                    target:self 
                                                  selector:@selector(changeTopImages:) 
                                                  userInfo:nil 
                                                   repeats:YES];
    }
}

- (void)changeTopImages:(NSTimer *)theTimer
{    
    nCurIndex = ( nCurIndex + 3 ) % 4; 
    
    NSString * id1 = [NSString stringWithFormat:@"%@_%d", IMAGE_LOADING_ID, IMAGE_FETCHER_CHIN + nCurIndex];
    UIImage * image1 = [dicTopImages objectForKey:id1];    
    imageViewTop0.image = image1;
    imageViewTop0.alpha = 0.0f;

    CGRect frame1 = imageViewTop1.frame;
    frame1.origin.y += FEATURED_PAGE_TOP_IMAGE_HEIGHT;

    CGRect frame2 = imageViewTop2.frame;
    frame2.origin.y += FEATURED_PAGE_TOP_IMAGE_HEIGHT;
    
    CGRect frame3 = imageViewTop3.frame;
    frame3.origin.y += FEATURED_PAGE_TOP_IMAGE_HEIGHT;
    
    CGRect frame4 = imageViewTop4.frame;
    frame4.origin.y += FEATURED_PAGE_TOP_IMAGE_HEIGHT;
    
    [UIView animateWithDuration:1.0f 
                     animations:^()
                        {
                            imageViewTop0.alpha = 1.0f;
                            imageViewTop1.frame = frame1;
                            imageViewTop2.frame = frame2;
                            imageViewTop3.frame = frame3;
                            imageViewTop4.frame = frame4;
                        } 
                     completion:^(BOOL finished)
                        {
                            [self animationFinished];
                            
                        }];
    
}

- (void)animationFinished
{
    CGRect frame1 = imageViewTop1.frame;
    if( frame1.origin.y >= FEATURED_PAGE_TOP_IMAGE_HEIGHT * 3 )
    {
        frame1.origin.y = -FEATURED_PAGE_TOP_IMAGE_HEIGHT;
        imageViewTop1.frame = frame1;
    }
    
    CGRect frame2 = imageViewTop2.frame;
    if( frame2.origin.y >= FEATURED_PAGE_TOP_IMAGE_HEIGHT * 3 )
    {
        frame2.origin.y = -FEATURED_PAGE_TOP_IMAGE_HEIGHT;
        imageViewTop2.frame = frame2;
    }
    
    CGRect frame3 = imageViewTop3.frame;
    if( frame3.origin.y >= FEATURED_PAGE_TOP_IMAGE_HEIGHT * 3 )
    {
        frame3.origin.y = -FEATURED_PAGE_TOP_IMAGE_HEIGHT;
        imageViewTop3.frame = frame3;
    }
    
    CGRect frame4 = imageViewTop4.frame;
    if( frame4.origin.y >= FEATURED_PAGE_TOP_IMAGE_HEIGHT * 3 )
    {
        frame4.origin.y = -FEATURED_PAGE_TOP_IMAGE_HEIGHT;
        imageViewTop4.frame = frame4;
    }    
}

- (void)topImageClick:(id)sender
{
    UIButton * btnTopImage = (UIButton *)sender;
    DLog(@"Current Index = %d Button Index = %d", nCurIndex, btnTopImage.tag);
    IssueDetailViewController * issueDetailViewController = [[[IssueDetailViewController alloc] initWithNibName:@"IssueDetailView" bundle:nil] autorelease];
    issueDetailViewController.issue = [arrIssues objectAtIndex:(nCurIndex + btnTopImage.tag) %4];
    [self.navigationController pushViewController:issueDetailViewController animated:YES];
}

#pragma mark - Push Notification
- (void)receivePushNotification:(NSNotification *)notification
{
    bLoadAll = NO;    
    [self loadIssues:NUMBER_OF_ISSUES_LOAD_ONCE];
}

@end
