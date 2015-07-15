//
//  IssueView.m
//  Magazine
//
//  Created by Myongsok Kim on 8/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>

#import "BookView.h"
#import "Library.h"
#import "LibraryIssue.h"
#import "Utils.h"
#import "LibraryViewController.h"
#import "AppConstants.h"

@implementation BookView
@synthesize libraryIssue;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if( self )
    {
        // Custom initialization
    }
    return self;
}

+ (CGSize)sizeOfView
{
    CGSize size;
    if( USER_DEVICE_IS_PHONE )
        size = CGSizeMake(80, 100);
    else
        size = CGSizeMake(120, 150);
    
    return size;
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if( libraryIssue == nil )
        return;

    //  Badge for New
    if( libraryIssue.nReadCnt > 0 )
        imageBadgeView.hidden = YES;
    else
        imageBadgeView.hidden = NO;
    
    //  Thumbnail
    NSString * sTempFolder = [[Utils sharedUtils] pathForThumbFolder];
    NSString * sThumbPath  = [sTempFolder stringByAppendingPathComponent:libraryIssue.sIssueId];
    sThumbPath = [sThumbPath stringByAppendingPathExtension:@"PNG"];
    
    UIImage * imageThumb   = [UIImage imageWithContentsOfFile:sThumbPath];    
    if( imageThumb == nil )
        [btnImage setImage:[UIImage imageNamed:@"loading"] forState:UIControlStateNormal];
    else
        [btnImage setImage:imageThumb forState:UIControlStateNormal];
    
    
    //  Drop a shadow to the button
    btnImage.layer.cornerRadius = 5.0f;
    btnImage.layer.masksToBounds = NO;
    btnImage.layer.borderWidth = 0.0f;
    btnImage.layer.shadowColor = [UIColor blackColor].CGColor;
    btnImage.layer.shadowOpacity = 0.8;
    btnImage.layer.shadowRadius = 12;
    btnImage.layer.shadowOffset = CGSizeMake(2.0f, 2.0f);
    
    
    switch( libraryIssue.nStatus )
    {
        case STATUS_DOWNLOADING:
            imageAlarmView.image = [UIImage imageNamed:@"pause"];
            progressDownload.hidden = NO;
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadDidSuccess:) name:kFetchSuccessNotification object:libraryIssue];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadDidFail:) name:kFetchFailNotification object:libraryIssue];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadWithPercent:) name:kFetchPercentNotification object:libraryIssue];                        
            break;
        case STATUS_NOTYET:
        case STATUS_PAUSED:
            imageAlarmView.image = [UIImage imageNamed:@"down"];
            progressDownload.hidden = YES;
            break;
        case STATUS_READABLE:
            imageAlarmView.image = nil;
        default:
            break;
    }
    
    if( [[LibraryViewController sharedLibraryViewController] isEditMode] )
        btnDelete.hidden = NO;
}

- (void)viewDidUnload
{
    [imageBadgeView release];
    imageBadgeView = nil;
    [progressDownload release];
    progressDownload = nil;
    [btnImage release];
    btnImage = nil;
    [btnDelete release];
    btnDelete = nil;
    [imageAlarmView release];
    imageAlarmView = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc 
{
    [imageBadgeView release];
    [progressDownload release];
    [libraryIssue release];
    [btnImage release];
    [btnDelete release];
    [imageAlarmView release];
    [super dealloc];
}

- (void)showDeleteButton:(BOOL)bShow
{
    btnDelete.hidden = !bShow;
}

- (void)resume
{
    if( libraryIssue.nStatus == STATUS_READABLE )
    {
        imageAlarmView.image = nil;
        return;
    }
    
    imageAlarmView.image = [UIImage imageNamed:@"pause"];
    progressDownload.hidden = NO;
    [[Library sharedLibrary] downloadLibraryIssue:libraryIssue];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadDidSuccess:) name:kFetchSuccessNotification object:libraryIssue];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadDidFail:) name:kFetchFailNotification object:libraryIssue];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadWithPercent:) name:kFetchPercentNotification object:libraryIssue];            
}

- (void)pause
{
    if( libraryIssue.nStatus == STATUS_DOWNLOADING )
    {
        imageAlarmView.image = [UIImage imageNamed:@"down"];
        //progressDownload.hidden = YES;
        [[Library sharedLibrary] pauseDownloadingLibraryIssue:libraryIssue];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

- (void)makeAsNew:(BOOL)bNew
{
    imageBadgeView.hidden = !bNew;
}

#pragma mark - Event
- (IBAction)onRead:(id)sender 
{
    switch( libraryIssue.nStatus )
    {
        case STATUS_DOWNLOADING:
            [self pause];
            break;
        case STATUS_NOTYET:
        case STATUS_PAUSED:
            [self resume];
            break;
        case STATUS_READABLE:
            [[LibraryViewController sharedLibraryViewController] readBook:libraryIssue];                        
            break;
        default:
            break;
    }
}

-(IBAction)onDelete:(id)sender 
{
    [[LibraryViewController sharedLibraryViewController] removeLibraryIssue:libraryIssue];
}

#pragma mark - file downloading notification
- (void)downloadDidSuccess:(NSNotification *)notification
{
    DLog(@"File Download Success");
    progressDownload.hidden = YES;
    imageAlarmView.image = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)downloadDidFail:(NSNotification *)notification
{
    DLog(@"File Download Fail");
    //progressDownload.hidden = YES;
    imageAlarmView.image = [UIImage imageNamed:@"down"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)downloadWithPercent:(NSNotification *)notification
{
    NSNumber * numberOfPercent = [notification.userInfo objectForKey:kPercentNotifictionUserInfoKey];
    progressDownload.progress = [numberOfPercent floatValue];
}

@end
