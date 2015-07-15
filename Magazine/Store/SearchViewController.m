//
//  SearchViewController.m
//  Magazine
//
//  Created by Myongsok Kim on 9/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SearchViewController.h"
#import "AppConstants.h"
#import "Utils.h"
#import "ActivityIndicator.h"

@implementation SearchViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if( self )
    {
        
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)startPage
{
    // Search Bar
    searchBar = [[UISearchBar alloc] initWithFrame:CGRectZero];
    searchBar.placeholder = @"Search";
    searchBar.delegate = self;
    searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [searchBar sizeToFit];    
    self.navigationItem.titleView = searchBar;    
}

- (void)loadIssues:(NSInteger)nNum
{
    if( searchBar.text == nil || [searchBar.text length] == 0 )
    {
        [arrIssues removeAllObjects];
        [self.tableView reloadData];
        return;
    }
    
    //  can not connect to internet and is in waiting to be constructed again
    if( self.reachability != nil )
        return;
    
    if( bLoadAll == NO )
    {
        nLimit_Dur = nNum;
        NSString * sURL = [NSString stringWithFormat:STORE_URL_GET_SEARCHED_ISSUES, searchBar.text, [arrIssues count], nLimit_Dur];
        self.fetchURI = [FetchURI fetchWithURL:sURL delegate:self];
        [[ActivityIndicator currentIndicator] displayActivity:@"Loading..."];
        [fetchURI startFetch];
    }    
}

- (void)viewDidUnload
{
    [searchBar release];    
    searchBar = nil;
    
    [super viewDidUnload];    
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if( USER_DEVICE_IS_PAD )
        return YES;
    
    return UIInterfaceOrientationIsPortrait( interfaceOrientation );
}

#pragma mark - UISearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)sb
{
    //  Disappear Keyboard
    [sb resignFirstResponder];
    
    //  Start Search
    [arrIssues removeAllObjects];
    bLoadAll = NO;

    [self loadIssues:NUMBER_OF_ISSUES_LOAD_ONCE];
}

@end
