//
//  BrowseViewController.m
//  Magazine
//
//  Created by Myongsok Kim on 9/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BrowseViewController.h"
#import "AppConstants.h"
#import "ActivityIndicator.h"

@implementation BrowseViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if( self )
    {
        
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    arrSortField = [[NSMutableArray alloc] initWithObjects: SORT_BY_DOWNLOAD_FIELD,
                    SORT_BY_TITLE_FIELD,
                    SORT_BY_DATE_FIELD, nil];
    
    [super viewDidLoad];    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
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
    //  can not connect to internet and is in waiting to be constructed again
    if( self.reachability != nil )
        return;
    
    if( fetchURI != nil )
        return;
    
    if( bLoadAll == NO )
    {
        nLimit_Dur = nNum;
        NSString * sURL = [NSString stringWithFormat:STORE_URL_GET_SORTED_ISSUES, [arrSortField objectAtIndex:sortMode], [arrIssues count], nLimit_Dur];
        self.fetchURI = [FetchURI fetchWithURL:sURL delegate:self];
        [[ActivityIndicator currentIndicator] displayActivity:@"Loading..."];
        [fetchURI startFetch];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if( USER_DEVICE_IS_PAD )
        return YES;
    
    return UIInterfaceOrientationIsPortrait( interfaceOrientation );
}

@end
