//
//  BookcaseViewController.m
//  Magazine
//
//  Created by Myongsok Kim on 8/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BookcaseViewController.h"
#import "AppConstants.h"
#import "BookView.h"
#import "Library.h"
#import "LibraryIssue.h"

#define BOOK_HORIZONTAL_MIN_SPACE           20
#define MINI_SHELF_ROW                      6

@implementation BookcaseViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if( self )
    {
        // Custom initialization
        dicBookViews = [[NSMutableDictionary alloc] init];
        
        if( USER_DEVICE_IS_PHONE )
        {
            colorPortrait  = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"background-tile-iPhone.png"]];
            imageShelfPortrait  = [[UIImage imageNamed:@"shelf-iPhone.png"] retain];
            
            
            CGSize screenSize = [[UIScreen mainScreen] bounds].size;
            if( screenSize.height > 480 )
            {
                colorLandscape = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"background-tile-landscape-iPhone-568.png"]];
                imageShelfLandscape = [[UIImage imageNamed:@"shelf-landscape-iPhone-568.png"] retain];
            }
            else
            {
                colorLandscape = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"background-tile-landscape-iPhone.png"]];
                imageShelfLandscape = [[UIImage imageNamed:@"shelf-landscape-iPhone.png"] retain];
            }
            
        }
        else
        {
            colorPortrait  = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"background-tile-iPad.png"]];
            colorLandscape = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"background-tile-landscape-iPad.png"]];

            imageShelfPortrait  = [[UIImage imageNamed:@"shelf-iPad.png"] retain];
            imageShelfLandscape = [[UIImage imageNamed:@"shelf-landscape-iPad.png"] retain];            
        }
        
        shelfImageViews = [[NSMutableArray alloc] init];
    }
    return self;
}

#pragma mark - View lifecycle
- (void)loadView
{
    [super loadView];
    
    scrollView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"wood.jpg"]];
    [self loadBooks];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadBooks)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];    
}

- (void)viewDidUnload
{
    [scrollView release];
    scrollView = nil;    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Public Methods
- (void)loadBooks
{
    UIColor * color;
    UIImage * image;
    if( UIInterfaceOrientationIsPortrait( [UIApplication sharedApplication].statusBarOrientation ) ) 
    {
        color = colorPortrait;
        image = imageShelfPortrait;
    }
    else
    {
        color = colorLandscape;
        image = imageShelfLandscape;
    }
    
    scrollView.backgroundColor = color;
    
    
    
    //  Reset Content size of scrollview    
    NSMutableDictionary * dicTemp = [[NSMutableDictionary alloc] init];    
    NSInteger   numberOfBook      = [[Library sharedLibrary].arrIssues count];    
    if( numberOfBook > 0 )
    {

        CGSize      sizeOfBook        = [BookView sizeOfView];
        CGSize      sizeOfScrollView  = scrollView.frame.size;
        
        CGFloat fHorizSpace = BOOK_HORIZONTAL_MIN_SPACE;
        if( USER_DEVICE_IS_PAD )
            fHorizSpace *= 2;
        NSInteger   numberOfColumn    = sizeOfScrollView.width / ( sizeOfBook.width + fHorizSpace );        
        NSInteger   numberOfRow       = numberOfBook / numberOfColumn + ( (numberOfBook % numberOfColumn) == 0 ? 0 : 1 );            
        
        CGFloat     fRowHeight        = sizeOfBook.height + 40.0f;
        
//----------------------------------------------------------------------        
        
        CGRect rectShelf = CGRectMake(0, 0, sizeOfScrollView.width, image.size.height);        
        UIImageView * imageView;
        NSInteger nShelf;
        NSInteger currentNumberOfImageView = [shelfImageViews count];
        for( nShelf = 0 ; nShelf < numberOfRow + MINI_SHELF_ROW; nShelf++ )
        {
            rectShelf.origin.y = (nShelf + 1) * fRowHeight - rectShelf.size.height * 0.35;
            if( nShelf >= currentNumberOfImageView )
            {
                imageView = [[UIImageView alloc] initWithImage:image];
                imageView.frame = rectShelf;
                imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
                [scrollView addSubview:imageView];
                [shelfImageViews addObject:imageView];
                [imageView release];
                
            }
            else
            {
                imageView = [shelfImageViews objectAtIndex:nShelf];
                imageView.frame = rectShelf;
                imageView.image = image;
            }
        }
        
        NSInteger nRemove = [shelfImageViews count] - nShelf;
        for( NSInteger i = 0 ; i < nRemove ; i++ )
        {
            imageView = [shelfImageViews lastObject];
            [imageView removeFromSuperview];
            [shelfImageViews removeLastObject];
        }
        
//----------------------------------------------------------------------        
        
        CGSize      newSizeOfScrollView  = CGSizeMake(sizeOfScrollView.width, numberOfRow * fRowHeight < sizeOfScrollView.height ? sizeOfScrollView.height : numberOfRow * fRowHeight);
        //  For vertical scroller
        newSizeOfScrollView.height += 2.0f;
        
        scrollView.contentSize  = newSizeOfScrollView;
        
        CGFloat     fHSpace = ( sizeOfScrollView.width - sizeOfBook.width * numberOfColumn ) / ( numberOfColumn + 1 );
        CGFloat     fHeightOfChin = 20.0f;
//        if( USER_DEVICE_IS_PAD )
//            fHeightOfChin *= 2;
        
        NSInteger   nRow = 0;
        NSInteger   nCol = 0;
        

        for( NSInteger i = 0 ; i < numberOfBook ; i++ )
        {
            LibraryIssue * libraryIssue = [[Library sharedLibrary].arrIssues objectAtIndex:i];
            //  Create Book View
            BookView * bookView = [dicBookViews objectForKey:libraryIssue.sIssueId];
            if( bookView == nil )
            {
                bookView = [[[BookView alloc] initWithNibName:@"BookView" bundle:nil] autorelease];        
                bookView.libraryIssue = libraryIssue;
                [scrollView addSubview:bookView.view];
            }
            else
            {
                if( libraryIssue.nReadCnt > 0 )
                    [bookView makeAsNew:NO];
            }
            
            [dicTemp setObject:bookView forKey:libraryIssue.sIssueId];            
            
            //  Place book at calculated position
            CGPoint pos = CGPointMake( fHSpace + nCol * (sizeOfBook.width + fHSpace), nRow * fRowHeight + fHeightOfChin );
            CGRect  frameOfBookView;
            frameOfBookView.origin = pos;
            frameOfBookView.size   = sizeOfBook;
            bookView.view.frame = frameOfBookView;

            
            
            nCol++;
            if( nCol == numberOfColumn )
            {
                nCol = 0;
                nRow++;
            }
            
        }
    
    }
    
    
    NSString * sIssueId = nil;
    NSEnumerator * enumer = [dicBookViews keyEnumerator];
    while( (sIssueId = [enumer nextObject]) )
    {
        if( [dicTemp objectForKey:sIssueId] == nil )
        {
            BookView * book = [dicBookViews objectForKey:sIssueId];
            [book.view removeFromSuperview];
        }
    }
    [dicBookViews release];
    dicBookViews = dicTemp;
}

- (void)editBooks:(BOOL)enable
{
    NSEnumerator * enumer = [dicBookViews objectEnumerator];
    BookView * bookView   = nil;
    
    while( (bookView = [enumer nextObject]) )
    {
        [bookView showDeleteButton:enable];
    }
}

- (void)clickBook:(NSString *)sIssueId
{
    BookView * bookView = [dicBookViews objectForKey:sIssueId];
    if( bookView == nil )
        return;    
    [bookView onRead:self];
}

- (void)dealloc 
{
    [scrollView release];
    [dicBookViews release];    
    [colorPortrait release];
    [colorLandscape release];
    [imageShelfPortrait release];
    [imageShelfLandscape release];
    [shelfImageViews release];
    [super dealloc];
}
@end
