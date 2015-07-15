//
//  LibraryViewController.m
//  Magazine
//
//  Created by Myongsok Kim on 8/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LibraryViewController.h"
#import "BookcaseViewController.h"
#import "ListViewController.h"

#import "ReaderDocument.h"

#import "AppConstants.h"
#import "Library.h"
#import "LibraryIssue.h"
#import "Utils.h"
#import "Feedback.h"

static LibraryViewController * singletonLibraryViewController = nil;

@implementation LibraryViewController
@synthesize bAutoTransitionToReading, sAutoTransitionIssueId;
@synthesize bAutoDownload, sAutoDownloadIssueId;
@synthesize segmentViewType;

+ (LibraryViewController *)sharedLibraryViewController
{
    if( singletonLibraryViewController == nil )
    {
        singletonLibraryViewController = [[LibraryViewController alloc] initWithNibName:@"LibraryView" bundle:nil];        
    }
    
    return singletonLibraryViewController;
}

+ (void)destroyLibraryViewController
{
    if( singletonLibraryViewController != nil )
    {
        [singletonLibraryViewController release];
        singletonLibraryViewController = nil;
    }
}

- (void)gotoStore:(id)sender
{
    if( [[Utils sharedUtils] getSystemVersionAsInteger] < __IPHONE_5_0 )
    {
        [self dismissModalViewControllerAnimated:YES];
    }
    else
    {
        [self dismissViewControllerAnimated:YES completion:^(){}];
    }
}

- (void)onEdit:(id)sender 
{
    if( editButton.style == UIBarButtonItemStylePlain )
    {
        editButton.style = UIBarButtonItemStyleDone;
        editButton.title = @"Done";
        [bookcaseViewController editBooks:YES];
    }
    else
    {
        editButton.style = UIBarButtonItemStylePlain;
        editButton.title = @"Edit";
        [bookcaseViewController editBooks:NO];
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if( self )
    {
        bookcaseViewController = [[BookcaseViewController alloc] initWithNibName:@"BookcaseView" bundle:nil];
        listViewController     = [[ListViewController alloc] initWithNibName:@"ListView" bundle:nil];
    }
    return self;
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];

    UIImage * imageList  = [UIImage imageNamed:@"list"];
    UIImage * imageThumb = [UIImage imageNamed:@"thumb"];
    segmentViewType = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:imageList, imageThumb, nil]];
    segmentViewType.segmentedControlStyle = UISegmentedControlStyleBar;
    segmentViewType.tintColor = libraryNavigationBar.tintColor;
    [segmentViewType addTarget:self action:@selector(changeViewType:) forControlEvents:UIControlEventValueChanged];
    
    //  Create Store button
    storeButton = [[UIBarButtonItem alloc] initWithTitle:@"Store" style:UIBarButtonItemStyleBordered target:self action:@selector(gotoStore:)];
    viewTypeButton = [[UIBarButtonItem alloc] initWithCustomView:segmentViewType];    
    editButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(onEdit:)];
    
    //  Set View Type to Thumb mode
    [segmentViewType setSelectedSegmentIndex:THUMB_VIEW];
    [self changeViewType:self];
}

- (void)viewDidUnload
{
    [libraryNavigationItem release];
    libraryNavigationItem = nil;
    [containerView release];
    containerView = nil;
    [libraryNavigationBar release];
    libraryNavigationBar = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [bookcaseViewController loadBooks];
    
    
    if( bAutoTransitionToReading )
    {
        bAutoTransitionToReading = NO;
        if( sAutoTransitionIssueId != nil )
        {
            LibraryIssue * libraryIssue = [[Library sharedLibrary] libraryIssueForId:sAutoTransitionIssueId];
            if( libraryIssue != nil )
                [self readBook:libraryIssue];
            
            self.sAutoTransitionIssueId = nil;
        }
    }
    
    
    if( bAutoDownload )
    {
        bAutoDownload = NO;
        if( sAutoDownloadIssueId != nil )
        {
            [bookcaseViewController clickBook:sAutoDownloadIssueId];
            self.sAutoDownloadIssueId = nil;
        }
        
    }
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)dealloc 
{
    [bookcaseViewController release];
    [listViewController release];
    
    [libraryNavigationItem release];
    [containerView release];
    [segmentViewType release];
    
    [storeButton release];
    [editButton release];    
    [viewTypeButton release];

    
    [libraryNavigationBar release];
    [super dealloc];
}

#pragma mark - Public Methods
- (BOOL)isEditMode
{
    if( editButton.style == UIBarButtonItemStylePlain )
        return NO;
    
    return YES;
}

- (void)readBook:(LibraryIssue *)libraryIssue
{
    if( libraryIssue.nStatus == STATUS_READABLE )
    {
        libraryIssue.nReadCnt++;
        [[Library sharedLibrary] saveLibrary];        
        
        NSString * sPDFFolder = [[Utils sharedUtils] pathForPDFFolder];
        NSString * sPDFPath   = [sPDFFolder stringByAppendingPathComponent:libraryIssue.sIssueId];
        sPDFPath = [sPDFPath stringByAppendingPathExtension:@"PDF"];
        DLog(@"PDF path for reading: %@", sPDFPath);
        
        
        NSString *phrase = nil; // Document password (for unlocking most encrypted PDF files)
        ReaderDocument *document = [ReaderDocument withDocumentFilePath:sPDFPath password:phrase];  
        if (document != nil) // Must have a valid ReaderDocument object in order to proceed with things
        {
            ReaderViewController *readerViewController = [[ReaderViewController alloc] initWithReaderDocument:document];
            
            readerViewController.delegate = self; // Set the ReaderViewController delegate to self
            

            readerViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            readerViewController.modalPresentationStyle = UIModalPresentationFullScreen;
            
            if( [[Utils sharedUtils] getSystemVersionAsInteger] < __IPHONE_5_0 )
            {
                [self presentModalViewController:readerViewController animated:YES];                
            }
            else
            {
                [self presentViewController:readerViewController animated:YES completion:^(){}];
            }

            [readerViewController release]; // Release the ReaderViewController
        }            
        
    }
    else
    {
        [[Utils sharedUtils] alertMessage:@"You can not read this document"];
    }
}

- (void)removeLibraryIssue:(LibraryIssue *)libraryIssue
{
    //  Increase deleted count of issue on server database
    [[Feedback sharedFeedback] deletedIssue:libraryIssue.sIssueId];
    
    
    [[Library sharedLibrary] removeIssue:libraryIssue];
    [bookcaseViewController loadBooks];
}

- (void)dismissReaderViewController:(ReaderViewController *)viewController
{
    if( [[Utils sharedUtils] getSystemVersionAsInteger] < __IPHONE_5_0 )
    {
        [self dismissModalViewControllerAnimated:YES];
    }
    else
    {
        [self dismissViewControllerAnimated:YES completion:^(){}];
    }
}

- (void)changeViewType:(id)sender
{
    CGRect frame;
    frame.origin = CGPointZero;
    frame.size = containerView.frame.size;

    NSInteger nSelectedView = segmentViewType.selectedSegmentIndex;
    if( nSelectedView == LIST_VIEW )
    {
        if( [bookcaseViewController.view superview] != nil )
            [bookcaseViewController.view removeFromSuperview];
        
        listViewController.view.frame = frame;
        [containerView addSubview:listViewController.view];
        
        libraryNavigationItem.rightBarButtonItem = storeButton;    
        libraryNavigationItem.leftBarButtonItem = viewTypeButton;
    }
    else if( nSelectedView == THUMB_VIEW )
    {
        if( [listViewController.view superview] != nil )
            [listViewController.view removeFromSuperview];
        
        bookcaseViewController.view.frame = frame;
        [containerView addSubview:bookcaseViewController.view];            

        libraryNavigationItem.rightBarButtonItem = nil;
        libraryNavigationItem.leftBarButtonItem = nil;
        
        UIToolbar * toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 125, 44)];
        toolBar.tintColor = libraryNavigationBar.tintColor;
        [toolBar setItems:[NSArray arrayWithObjects:viewTypeButton, storeButton, nil]];
        toolBar.barStyle = -1;        
        UIBarButtonItem * barButton = [[UIBarButtonItem alloc] initWithCustomView:toolBar];
        libraryNavigationItem.rightBarButtonItem = barButton;
        [barButton release];
        [toolBar release];
        
        // Support iOS5+
        //libraryNavigationItem.rightBarButtonItems = [NSArray arrayWithObjects:storeButton, viewTypeButton, nil];
        
        libraryNavigationItem.leftBarButtonItem = editButton;
        
        [bookcaseViewController loadBooks];
    }
}

@end
