//
//  ListViewController.m
//  Magazine
//
//  Created by Myongsok Kim on 9/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ListViewController.h"
#import "Library.h"
#import "LibraryIssue.h"
#import "Utils.h"
#import "LibraryViewController.h"

@interface ListViewController ()
- (void)sortBooks;
- (void)downloadNotification:(NSNotification *)notification;
@end

@implementation ListViewController
@synthesize tableView;
@synthesize segmentSort;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if( self )
    {
        // Custom initialization
        arrBooks = [[NSMutableArray alloc] init];
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadNotification:) name:kFetchSuccessNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
}

- (void)downloadNotification:(NSNotification *)notification
{
    [self.tableView reloadData];
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [self setSegmentSort:nil];
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
    [tableView release];
    [arrBooks release];
    [segmentSort release];
    [super dealloc];
}

- (IBAction)onSort:(id)sender 
{
    [self sortBooks];
    [tableView reloadData];
}

- (void)sortBooks
{
    [arrBooks removeAllObjects];
    
    NSInteger nSelected = segmentSort.selectedSegmentIndex;
    if( nSelected == 0 )
    {
        //  Sort by Title
        NSMutableArray * arrLibraryIssues = [Library sharedLibrary].arrIssues;
        NSArray * arrSorted = [arrLibraryIssues sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2)
                                                                    {
                                                                        LibraryIssue * issue1 = (LibraryIssue *)obj1;
                                                                        LibraryIssue * issue2 = (LibraryIssue *)obj2;
                                                                                
                                                                        return [issue1.sIssueTitle compare:issue2.sIssueTitle];
                                                                    }]; 
        [arrBooks addObjectsFromArray:arrSorted];
    }
    else if( nSelected == 1 )
    {
        //  Sort by Series
        NSMutableArray * arrLibraryIssues = [Library sharedLibrary].arrIssues;
        NSArray * arrSorted = [arrLibraryIssues sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2)
                               {
                                   LibraryIssue * issue1 = (LibraryIssue *)obj1;
                                   LibraryIssue * issue2 = (LibraryIssue *)obj2;
                                   
                                   return [issue1.sSeriesTitle compare:issue2.sSeriesTitle];
                               }]; 
        [arrBooks addObjectsFromArray:arrSorted];        
    }
}

#pragma mark tableview datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    [self sortBooks];    
    NSInteger   numberOfBook      = [arrBooks count];
    
    return numberOfBook;
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LibraryIssue * libraryIssue = [arrBooks objectAtIndex:indexPath.row];
    NSString * strId = libraryIssue.sIssueId;
    UITableViewCell * newCell = [tv dequeueReusableCellWithIdentifier:strId];
    if( newCell == nil )
    {
        newCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:strId] autorelease];
        newCell.textLabel.text = libraryIssue.sIssueTitle;
        newCell.detailTextLabel.text = libraryIssue.sSeriesTitle;
        
        NSString * sTempFolder = [[Utils sharedUtils] pathForThumbFolder];
        NSString * sThumbPath  = [sTempFolder stringByAppendingPathComponent:libraryIssue.sIssueId];
        sThumbPath = [sThumbPath stringByAppendingPathExtension:@"PNG"];
        UIImage * imageThumb   = [UIImage imageWithContentsOfFile:sThumbPath];     
        newCell.imageView.image = imageThumb;    
        
    }
    
    if( libraryIssue.nStatus == STATUS_READABLE )
        newCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    else
    {
        newCell.accessoryType  = UITableViewCellAccessoryNone;
        newCell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return newCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80.0f;
}

#pragma mark tableview delegate
- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tv deselectRowAtIndexPath:indexPath animated:YES];
    LibraryIssue * selectedLibraryIssue = [arrBooks objectAtIndex:indexPath.row];
    if( selectedLibraryIssue.nStatus == STATUS_READABLE )
    {
        [[LibraryViewController sharedLibraryViewController] readBook:selectedLibraryIssue];                                
    }
}


@end
