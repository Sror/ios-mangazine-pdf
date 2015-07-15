//
//  SearchViewController_iPad.m
//  Magazine
//
//  Created by Myongsok Kim on 9/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SearchViewController_iPad.h"
#import "ActivityIndicator.h"
#import "FetchURI.h"
#import "AppConstants.h"

@implementation SearchViewController_iPad

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
    [searchBar release];    
    searchBar = nil;    
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
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
        [self reloadIssues];
        return;
    }
    
    //  can not connect to internet and is in waiting to be constructed again
    if( self.reachability != nil )
        return;
        
    if( fetchURI != nil )
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


#pragma mark - UISearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)sb
{
    //  Disappear Keyboard
    [sb resignFirstResponder];
    
    //  Start Search
    [arrIssues removeAllObjects];
    [self reloadIssues];
    nTotalPage = -1;
    
    bLoadAll = NO;
    [self loadIssues:NUMBER_OF_ISSUES_LOAD_ONCE];
}

@end
