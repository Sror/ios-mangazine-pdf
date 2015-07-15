//
//  IssueDetailViewController.m
//  Magazine
//
//  Created by Myongsok Kim on 8/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "IssueDetailViewController.h"
#import "ActivityIndicator.h"
#import "AppConstants.h"
#import "Issue.h"
#import "Utils.h"
#import "Feedback.h"
#import "LibraryIssue.h"
#import "Library.h"
#import "LibraryViewController.h"

#import <QuartzCore/QuartzCore.h>

@implementation IssueDetailViewController
@synthesize issue;

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if( issue == nil )
        return;
 
    
    defaultImage = [UIImage imageNamed:@"loading"];
    imageViewThumb.image = defaultImage;
        
    //  Fetch Thumb
    if( issue.sThumbURL != nil )
    {
        bThumbOK = NO;
        fetchURIForThumb = [[FetchURI alloc] initWithURL:issue.sThumbURL delegate:self];
        [fetchURIForThumb startFetch];
        
        [[ActivityIndicator currentIndicator] displayActivity:@"Loading"];
    }
    
    //  Buy Button
    [self paintButton:btnBuy withR:174.0f withG:214.0f withB:254.0f];            
        
    self.navigationItem.title   = issue.sTitle;
        
    
    ratingView.target = self;
    ratingView.action = @selector(onRate:);    
    NSNumber * curRate = [[NSUserDefaults standardUserDefaults] objectForKey:issue.sIssueId];
    if( curRate != nil )
    {
        ratingView.nRate = [curRate intValue];
    }
    
    
    DLog(@"%@", issue.sFileURL);
}

- (void)viewDidUnload
{
    [infoCell release];
    infoCell = nil;
    [descCell release];
    descCell = nil;
    [imageViewThumb release];
    imageViewThumb = nil;
    [labelSeriesTitle release];
    labelSeriesTitle = nil;
    [labelIssueTitle release];
    labelIssueTitle = nil;
    [labelReleased release];
    labelReleased = nil;
    [labelPublisher release];
    labelPublisher = nil;
    [labelRatings release];
    labelRatings = nil;
    [labelPages release];
    labelPages = nil;
    [textViewDesc release];
    textViewDesc = nil;
    [btnBuy release];
    btnBuy = nil;
    [imageViewRating release];
    imageViewRating = nil;
    [labelStatus release];
    labelStatus = nil;
    [labelDownloads release];
    labelDownloads = nil;
    [rateCell release];
    rateCell = nil;
    [labelRateText release];
    labelRateText = nil;
    
    [ratingView release];
    ratingView = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self displayIssueDetail];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];    
    
    if( ratingView.nRate > 0 )
    {
        NSNumber * curRate = [[NSUserDefaults standardUserDefaults] objectForKey:issue.sIssueId];
        if( curRate == nil || [curRate intValue] != ratingView.nRate )
        {
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:ratingView.nRate] forKey:issue.sIssueId];
            [[Feedback sharedFeedback] giveRatingIssue:issue.sIssueId rating:ratingView.nRate];
        }
    }    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)dealloc 
{
    [infoCell release];
    [descCell release];
    [imageViewThumb release];
    [labelSeriesTitle release];
    [labelIssueTitle release];
    [labelReleased release];
    [labelPublisher release];
    [labelRatings release];
    [labelPages release];
    [textViewDesc release];
    
    [issue release];
    [btnBuy release];
    [imageViewRating release];
    [labelStatus release];
    [labelDownloads release];
    [rateCell release];
    [labelRateText release];
    [ratingView release];
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
#ifdef USER_RATE_ALLOW    
    return 3;
#else
    return 2;
#endif
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * newCell = nil;
    
    switch( indexPath.section ) 
    {
        case 0:
            newCell = infoCell;
            break;
        case 1:
            newCell = descCell;
            break;
        case 2:
            newCell = rateCell;
            break;
        default:
            break;
    }
    
    [newCell setNeedsLayout];
    
    return newCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 44;
    
    CGFloat textHeight;
    CGRect  rectFrame;
    
    switch( indexPath.section )
    {
        case 0:
            height = infoCell.frame.size.height;
            break;
        case 1:
            textHeight = [[Utils sharedUtils] heightOfText:issue.sDesc font:[textViewDesc font] width:textViewDesc.frame.size.height];
            rectFrame  = textViewDesc.frame;
            rectFrame.size.height = textHeight + 10;
            textViewDesc.frame = rectFrame;
            
            height = textHeight + 10 + 30;
            break;
        case 2:
            height = rateCell.frame.size.height;
            break;
        default:
            break;
    }
    
    return height;
}

#pragma mark - FetchDelegate
- (void)fetchDidFinished:(FetchURI *)fetch
{
    UIImage * downloadedImage = [UIImage imageWithData:[fetch getData]];
    
    if( downloadedImage != nil )
    {
        imageViewThumb.image = downloadedImage;    
        bThumbOK = YES;
    }
    
    [[ActivityIndicator currentIndicator] hide];
    [fetchURIForThumb release];
    fetchURIForThumb = nil;
}

//- (void)fetchDid:(FetchURI *)fetch WithPercent:(float)fPercent
//{
//    progressIndicator.progress = fPercent;
//    labelPercent.text = [NSString stringWithFormat:@"%0.2f%%", fPercent * 100.0];
//    
//}

- (void)fetchDidFailed:(FetchURI *)fetch
{
    [[ActivityIndicator currentIndicator] hide];
    [fetchURIForThumb release];
    fetchURIForThumb = nil;    
}

#pragma mark - Button Event
- (IBAction)onBuy:(id)sender 
{
    if( (fetchURIForThumb != nil ) && (fetchURIForThumb.status == FETCH_STATUS_FETCHING) )
        return;
    
    
    if( libraryIssue == nil )
    {
        libraryIssue = [[LibraryIssue alloc] init];
        libraryIssue.sIssueId       = issue.sIssueId;
        libraryIssue.sIssueTitle    = issue.sTitle;
        libraryIssue.sSeriesId      = issue.sSeriesId;
        libraryIssue.sSeriesTitle   = issue.sSeriesName;
        libraryIssue.sPublishedDate = issue.sReleaseDate;
        libraryIssue.nReadCnt       = 0;
        libraryIssue.nStatus        = STATUS_NOTYET;
        libraryIssue.sFileURL       = issue.sFileURL;
        
        NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];    
        NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        [dateFormatter setLocale:usLocale];
        libraryIssue.sDate          = [dateFormatter stringFromDate:[NSDate date]];
        [dateFormatter release];
        
        if( bThumbOK )
            [libraryIssue setThumbImage:imageViewThumb.image];

        if( [[Library sharedLibrary] addNewIssue:libraryIssue] )
        {
            LibraryViewController * libraryViewController = [LibraryViewController sharedLibraryViewController];
            libraryViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
            libraryViewController.bAutoDownload = YES;
            libraryViewController.sAutoDownloadIssueId = libraryIssue.sIssueId;
            if( [[Utils sharedUtils] getSystemVersionAsInteger] < __IPHONE_5_0 )
                [self presentModalViewController:libraryViewController animated:YES];
            else
                [self presentViewController:libraryViewController animated:YES completion:^(){}];
        }
        
        [libraryIssue release];
        libraryIssue = [[Library sharedLibrary] libraryIssueForId:issue.sIssueId];
    }
    else
    {
        LibraryViewController * libraryViewController = [LibraryViewController sharedLibraryViewController];
        libraryViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        
        if( libraryIssue.nStatus == STATUS_READABLE )
        {

            libraryViewController.bAutoTransitionToReading = YES;
            libraryViewController.sAutoTransitionIssueId = libraryIssue.sIssueId;            

        }
        else if( libraryIssue.nStatus == STATUS_PAUSED || 
                 libraryIssue.nStatus == STATUS_NOTYET )
        {
            libraryViewController.bAutoDownload = YES;
            libraryViewController.sAutoDownloadIssueId = libraryIssue.sIssueId;
            
        }        
        
        if( [[Utils sharedUtils] getSystemVersionAsInteger] < __IPHONE_5_0 )
            [self presentModalViewController:libraryViewController animated:YES];
        else
            [self presentViewController:libraryViewController animated:YES completion:^(){}];
        
    }

}

- (IBAction)onThumbnail:(id)sender 
{
    if( libraryIssue == nil )
        return;
    
    if( libraryIssue.nStatus == STATUS_READABLE )
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
}

- (void)onRate:(id)sender
{    
    switch (ratingView.nRate) 
    {
        case 1:
            labelRateText.text = @"hate it";
            break;
        case 2:
            labelRateText.text = @"don`t like it";
            break;
        case 3:
            labelRateText.text = @"it`s ok";
            break;
        case 4:
            labelRateText.text = @"it`s good";
            break;
        case 5:
            labelRateText.text = @"it`s great";
            break;
        default:
            labelRateText.text = @"";
            break;
    }
}


#pragma mark - Paint Button
- (void)displayIssueDetail
{
    if( issue == nil )
        return;
    
    labelSeriesTitle.text   = issue.sSeriesName;
    labelIssueTitle.text    = issue.sTitle;
    labelPublisher.text     = [NSString stringWithFormat:@"Publisher: %@", issue.sPublisher];
    labelRatings.text       = [NSString stringWithFormat:@"%d Ratings", issue.nRatingCnt];
    labelDownloads.text     = [NSString stringWithFormat:@"Downloads: %d", issue.nDownCnt];            
    labelPages.text         = [NSString stringWithFormat:@"Pages: %d", issue.nPageCnt];
    labelStatus.text        = nil;
    
    NSString * strReleasedDate = issue.sReleaseDate;
    NSDateFormatter * dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat:@"yyyyMMdd"];
    NSDate * releaseDate = [dateFormatter dateFromString:strReleasedDate];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    labelReleased.text      = [NSString stringWithFormat:@"Released: %@", [dateFormatter stringFromDate:releaseDate]];
    textViewDesc.text       = issue.sDesc;
    
    
    float fAvgRating = issue.fRatingAvg;
    if( fAvgRating < 0.0f )
        fAvgRating = 0.0f;
    if( fAvgRating > 5.0f )
        fAvgRating = 5.0f;
    int nNum = (int)( fAvgRating * 2.0f );
    NSString * sImageName = [NSString stringWithFormat:@"rating_%d", nNum];
    imageViewRating.image = [UIImage imageNamed:sImageName];
    
    
    libraryIssue = [[Library sharedLibrary] libraryIssueForId:issue.sIssueId];
    if( libraryIssue == nil )
    {        
        static NSString * strFree = @"Free";
        NSString * strBtnTitle = issue.fPrice == 0.0 ? strFree : [NSString stringWithFormat:@"$%0.2f", issue.fPrice];
        [btnBuy setTitle:strBtnTitle forState:UIControlStateNormal];
    }
    else
    {
        switch( libraryIssue.nStatus )
        {
            case STATUS_READABLE:
                [btnBuy setTitle:@"Read Now" forState:UIControlStateNormal];
                break;
            case STATUS_PAUSED:
                [btnBuy setTitle:@"Download" forState:UIControlStateNormal];
                labelStatus.text = @"Paused";
                break;
            case STATUS_NOTYET:
                [btnBuy setTitle:@"Download" forState:UIControlStateNormal];
                break;
            case STATUS_DOWNLOADING:
                [btnBuy setTitle:@"Downloading" forState:UIControlStateNormal];
                
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadDidSuccess:) name:kFetchSuccessNotification object:libraryIssue];
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadDidFail:) name:kFetchFailNotification object:libraryIssue];
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadWithPercent:) name:kFetchPercentNotification object:libraryIssue];
                
                break;
            default:
                break;
        }
        
    }    
}

- (void)paintButton:(UIButton *)btn withR:(float)r withG:(float)g withB:(float)b
{
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    [btn setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    [btn setBackgroundColor:[UIColor blackColor]];
    
    CAGradientLayer * btnGradient = [CAGradientLayer layer];
    btnGradient.frame = btn.bounds;
    btnGradient.colors = [NSArray arrayWithObjects: (id)[[UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:1.0f] CGColor],
                                                    (id)[[UIColor colorWithRed:r/511.0f green:g/511.0f blue:b/511.0f alpha:1.0f] CGColor],
                          nil];
    [btn.layer insertSublayer:btnGradient atIndex:0];
    
    [btn.layer setMasksToBounds:YES];
    [btn.layer setCornerRadius:5.0f];
    
    [btn.layer setBorderWidth:1.0f];
    [btn.layer setBorderColor:[[UIColor blackColor] CGColor]];
}

#pragma mark - Download Delegate
- (void)downloadDidSuccess:(NSNotification *)notification
{
    issue.nDownCnt++;
    [self displayIssueDetail];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)downloadDidFail:(NSNotification *)notification
{
    [self displayIssueDetail];
    [[NSNotificationCenter defaultCenter] removeObserver:self];    
}

- (void)downloadWithPercent:(NSNotification *)notification
{
    NSNumber * numberOfPercent = [notification.userInfo objectForKey:kPercentNotifictionUserInfoKey];
    labelStatus.text = [NSString stringWithFormat:@"%d%%", (int)([numberOfPercent floatValue] * 100.0f)];
}

@end
