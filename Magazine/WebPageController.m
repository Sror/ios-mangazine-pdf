//
//  WebPageController.m
//  Magazine
//
//  Created by Myongsok Kim on 9/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WebPageController.h"
#import "AppConstants.h"
#import "Utils.h"

@implementation WebPageController
@synthesize sPageTitle;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    shownActionSheet = nil;
    // Do any additional setup after loading the view from its nib.
//    UIBarButtonItem * doneButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(onDone:)];
//    titleBar.rightBarButtonItem = doneButtonItem;
//    [doneButtonItem release];
 
    titleBar.title = @"About";
    [self loadPage:ABOUT_URL];    
}

- (void)viewDidUnload
{
    [webView release];
    webView = nil;
    [titleBar release];
    titleBar = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)dealloc 
{
    [webView release];
    [titleBar release];
    [super dealloc];
}

- (void)showAbout:(id)sender
{
    if( shownActionSheet != nil )
        return;
    
    shownActionSheet = [[UIActionSheet alloc] initWithTitle:@"About" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles: nil];
    [shownActionSheet addButtonWithTitle:@"About"];
    [shownActionSheet addButtonWithTitle:@"Announcement"];
    [shownActionSheet addButtonWithTitle:@"Price and Distribution"];
    [shownActionSheet addButtonWithTitle:@"Cancel"];
    [shownActionSheet showFromBarButtonItem:sender animated:YES];
}

- (void)dismissAbout:(id)sender
{
    if( shownActionSheet == nil )
        return;
    [shownActionSheet dismissWithClickedButtonIndex:3 animated:YES];
    [shownActionSheet release];
    shownActionSheet = nil;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch( buttonIndex )
    {
        case 0:
            titleBar.title = @"About";
            [self loadPage:ABOUT_URL];
            break;
        case 1:
            titleBar.title = @"Announcement";
            [self loadPage:ANNOUNCE_URL];
            break;
        case 2:
            titleBar.title = @"Price and Distribution";
            [self loadPage:PRICE_URL];
            break;
        default:
            break;
    }
    
    [shownActionSheet release];
    shownActionSheet = nil;
}

- (void)onDone:(id)sender
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

#pragma mark - Public Methods

- (void)loadPage:(NSString *)sURL
{
    NSURL * url = [NSURL URLWithString:sURL];
    NSURLRequest * request = [NSURLRequest requestWithURL:url];
    [webView loadRequest:request];
}

@end
