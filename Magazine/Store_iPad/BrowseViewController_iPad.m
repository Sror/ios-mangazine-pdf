//
//  BrowseViewController_iPad.m
//  Magazine
//
//  Created by Myongsok Kim on 9/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BrowseViewController_iPad.h"
#import "ActivityIndicator.h"
#import "AppConstants.h"

@implementation BrowseViewController_iPad

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if( self )
    {
        // Custom initialization
    }
    return self;
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
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
@end
