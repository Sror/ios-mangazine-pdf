//
//  IssueCell.m
//  Magazine
//
//  Created by Myongsok Kim on 8/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "IssueCell.h"
#import <QuartzCore/QuartzCore.h>
#import "AppConstants.h"

@implementation IssueCell
@synthesize sThumbPath, sThumbURL, sSeriesTitle, sIssueTitle, nRating, fAvgRating, sSelectTitle,userData;
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if( self ) 
    {
        // Custom initialization
        fetchURI = [[FetchURI alloc] init];
        fetchURI.delegate = self;
        
        defaultImage = [[UIImage imageNamed:@"loading"] retain];
    }
    return self;
}

#pragma mark - 
#pragma mark View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];

    
    [btnSelect setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnSelect setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    [btnSelect setBackgroundColor:[UIColor blackColor]];
    
    
    CAGradientLayer * btnGradient = [CAGradientLayer layer];
    btnGradient.frame = btnSelect.bounds;
    btnGradient.colors = [NSArray arrayWithObjects: (id)[[UIColor colorWithRed:102.0f/255.0f green:102.0f/255.0f blue:102.0f/255.0f alpha:1.0f] CGColor],
                                                    (id)[[UIColor colorWithRed:051.0f/255.0f green:051.0f/255.0f blue:051.0f/255.0f alpha:1.0f] CGColor],
                          nil];
    [btnSelect.layer insertSublayer:btnGradient atIndex:0];
    
    [btnSelect.layer setMasksToBounds:YES];
    [btnSelect.layer setCornerRadius:5.0f];
    
    [btnSelect.layer setBorderWidth:1.0f];
    [btnSelect.layer setBorderColor:[[UIColor blackColor] CGColor]];
    
    
#if !defined (USER_RATE_ALLOW) 
    labelRating.hidden = YES;
    imageRating.hidden = YES;
#endif
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [labelSeriesTitle release];
    labelSeriesTitle = nil;
    [labelIssueTitle release];
    labelIssueTitle = nil;
    [btnSelect release];
    btnSelect = nil;
    [labelRating release];
    labelRating = nil;
    [imageRating release];
    imageRating = nil;
    [btnThumb release];
    btnThumb = nil;
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
    [labelSeriesTitle release];
    [labelIssueTitle release];
    [btnSelect release];
    [fetchURI release];
    [defaultImage release];
    [labelRating release];
    [imageRating release];
    [userData release];
    [btnThumb release];
    [super dealloc];
}

#pragma mark - 
#pragma mark Setter
- (void)setSSeriesTitle:(NSString *)s
{
    if( sSeriesTitle != nil )
        [sSeriesTitle release];
    
    if( s == nil )
    {
        sSeriesTitle = nil;
        return;
    }
    
    sSeriesTitle = [s retain];
    
    labelSeriesTitle.text = s;
}

- (void)setSIssueTitle:(NSString *)s
{
    if( sIssueTitle != nil )
        [sIssueTitle release];

    if( s == nil )
    {
        sIssueTitle = nil;
        return;
    } 
    
    sIssueTitle = [s retain];
    
    labelIssueTitle.text = s;
}

- (void)setNRating:(NSInteger)n
{
    nRating = n;    
    
    labelRating.text = [NSString stringWithFormat:@"%d %@", n, n < 2 ? @"Rating" : @"Ratings"];
}

- (void)setFAvgRating:(float)f
{
    if( f > 5.0f )
        f = 5.0f;
    
    if( f < 0 )
        f = 0;
    
    int nNum = (int)(f * 2.0f);
    
    NSString * sImageName = [NSString stringWithFormat:@"rating_%d", nNum];
    imageRating.image = [UIImage imageNamed:sImageName];
}

- (void)setSSelectTitle:(NSString *)s
{
    if( sSelectTitle != nil )
        [sSelectTitle release];
    
    if( s == nil )
    {
        sSelectTitle = nil;
        return;
    }
    
    sSelectTitle = [s retain];
    
    [btnSelect setTitle:s forState:UIControlStateNormal];
}

- (void)setSThumbURL:(NSString *)s
{
    if( sThumbURL != nil )
        [sThumbURL release];
    
    if( s == nil )
    {
        sThumbURL = nil;
        return;
    }
    
    sThumbURL = [[s stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] retain];
    DLog(@"%@", s);

    [btnThumb setImage:defaultImage forState:UIControlStateNormal];
    
    //  Fetching URL
    if( fetchURI.status == FETCH_STATUS_FETCHING )
        [fetchURI stopFetch];
    
    fetchURI.fetchURL = s;
    [fetchURI startFetch];
    
    [btnSelect setTitle:@"Loading" forState:UIControlStateDisabled];
    [btnSelect setEnabled:NO];
}

- (void)setSThumbPath:(NSString *)s
{
    if( fetchURI.status == FETCH_STATUS_FETCHING )
        [fetchURI stopFetch];

    if( sThumbPath != nil )
        [sThumbPath release];

    if( s == nil )
        return;
    
    sThumbPath = [s retain];
    
    UIImage * thumbImageFromPath = [UIImage imageWithContentsOfFile:s];
    
    if( thumbImageFromPath != nil )
        [btnThumb setImage:thumbImageFromPath forState:UIControlStateNormal];
    else
        [btnThumb setImage:defaultImage forState:UIControlStateNormal];
}

#pragma mark -
#pragma mark FetchDelegate
- (void)fetchDidFinished:(FetchURI *)fetch
{
    UIImage * imageFromURL = [UIImage imageWithData:[fetch getData]];

    if( imageFromURL != nil )
        [btnThumb setImage:imageFromURL forState:UIControlStateNormal];
    else
        [btnThumb setImage:defaultImage forState:UIControlStateNormal];
    
    [btnSelect setEnabled:YES];
}

- (void)fetchDidFailed:(FetchURI *)fetch
{
    [btnSelect setEnabled:YES];
}

#pragma mark - 
#pragma mark Event;
- (IBAction)onSelect:(id)sender 
{
    if( delegate != nil )
    {
        if( [delegate respondsToSelector:@selector(onSelect:)] )
            [delegate onSelect:self];
    }
}

- (IBAction)onThumbnail:(id)sender 
{
    if( delegate != nil )
    {
        if( [delegate respondsToSelector:@selector(onThumbnail:)] )
            [delegate onThumbnail:self];
    }    
}

#pragma mark -
#pragma mark Class Method
+ (CGSize)sizeOfView
{
    return CGSizeMake(300, 120);
}

@end
