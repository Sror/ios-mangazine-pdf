//
//  MScrollView.m
//  Magazine
//
//  Created by Myongsok Kim on 9/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MScrollView.h"
#import "AppConstants.h"

#define NUMBER_OF_REUSABLE_IDENTIFIERS         200


@implementation MScrollViewItem
@synthesize view;
@synthesize reuseIdentifier;
- (void)dealloc
{
    [view release];
    [reuseIdentifier release];
    [super dealloc];
}
@end

@interface MScrollView()
- (void)initMembers;
- (void)didRotated;
@end

@implementation MScrollView
@synthesize dataSource;
@synthesize actionDelegate;
@synthesize currentPage;
@synthesize bPageFit;

- (id)init
{
    self = [super init];
    if( self != nil )
    {
        [self initMembers];
    }        
        
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if( self != nil )
    {
        [self initMembers];        
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if( self != nil )
    {
        [self initMembers];        
    }
    
    return self;
}

- (void)initMembers
{
    dataSource = nil;
    actionDelegate = nil;
    dicItems = [[NSMutableDictionary alloc] init];
    dicVisibleItems = [[NSMutableDictionary alloc] init];
    currentPage = 1;
    bPageFit = YES;
    self.delegate = self;
    self.showsHorizontalScrollIndicator = NO;
    self.backgroundColor = [UIColor clearColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didRotated)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];    
    
}

- (void)didRotated
{
    [self reloadData];
    
    //  Correct current page offset
    self.contentOffset = CGPointMake((currentPage - 1) * self.frame.size.width, 0);
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    
    [dataSource release];
    [actionDelegate release];
    [dicItems release];
    [dicVisibleItems release];
    [super dealloc];
}

#pragma mark - Public Methods
- (void)reloadData
{    
    if( self.dataSource == nil )
        return;    
    
    //  Current Size
    CGSize size = self.frame.size;    
    
    //  Current Orientation
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    
    //  Item Size 
    CGSize itemSize = [self.dataSource MScrollView:self sizeForItemsOrientation:orientation];
    
    //  Number of items in Horizontal and calculate item`s width to fit
    NSInteger nItemCntInHorizontal = size.width / itemSize.width;
    if( nItemCntInHorizontal == 0 )
        nItemCntInHorizontal = 1;
    
    NSInteger nItemCntInVertical = size.height / itemSize.height;
    if( nItemCntInVertical == 0 )
        nItemCntInVertical = 1;

    //  Offset
    CGPoint offset = CGPointMake(0, 0);
    if( self.bPageFit )
    {
        itemSize.width  = size.width  / (float)nItemCntInHorizontal;
        itemSize.height = size.height / (float)nItemCntInVertical;
    }
    else
    {
        if( self.pagingEnabled )
        {
            offset.x = (size.width  - itemSize.width  * nItemCntInHorizontal ) / 2.0f;
            offset.y = (size.height - itemSize.height * nItemCntInVertical   ) / 2.0f;            
        }
    }
    
    
    //  Total number of items
    NSInteger nItemCntInTotal = [self.dataSource numberOfItemsInMScrollView:self];
    NSInteger nPageCnt = nItemCntInTotal / ( nItemCntInHorizontal * nItemCntInVertical );    
    NSInteger nRest = nItemCntInTotal % ( nItemCntInHorizontal * nItemCntInVertical);
    
    //  Set Content Size
    if( self.pagingEnabled )
    {
        //self.contentSize = CGSizeMake( size.width * nPageCnt + itemSize.width * ( nRest / nItemCntInVertical + (nRest % nItemCntInVertical ? 1 : 0) ) + 2 , size.height );
        self.contentSize = CGSizeMake( size.width * ( nPageCnt + ( nRest > 0 ? 1 : 0 ) ) + 2, size.height);
        if( self.contentSize.width < size.width )
            self.contentSize = CGSizeMake(size.width + 2, self.contentSize.height);
    }
    else
    {
        self.contentSize = CGSizeMake( size.width, size.height * nPageCnt + itemSize.height * ( nRest / nItemCntInHorizontal + (nRest % nItemCntInHorizontal) ) );
        if( self.contentSize.height < size.height )
            self.contentSize = CGSizeMake(self.contentSize.height, size.height + 2);
    } 
    
    CGRect itemFrame;
    itemFrame.size.width = itemSize.width - 1;
    itemFrame.size.height = itemSize.height - 1;
    itemFrame.origin = CGPointMake(1, 1);
    if( self.pagingEnabled )
    {
        itemFrame.origin.x += offset.x;
        itemFrame.origin.y += offset.y;
    }

    
    NSMutableArray * arrTmp = [NSMutableArray array];    
    
    for( NSInteger i = 0 ; i < nItemCntInTotal ; i++ )
    {
        MScrollViewItem * itemView = [self.dataSource MScrollView:self itemAtIndex:i];
        if( itemView == nil || itemView.view == nil )
            continue;
         
        itemView.view.frame = itemFrame;
        
        if( self.pagingEnabled )
        {
            if( (i + 1) % nItemCntInVertical == 0 )
            {
                itemFrame.origin.x += itemSize.width;
                itemFrame.origin.y = 1 + offset.y;
                
            }
            else
                itemFrame.origin.y += itemSize.height;
            
            
            if( (i + 1 ) % (nItemCntInHorizontal * nItemCntInVertical ) == 0 )
                itemFrame.origin.x += offset.x * 2;
            
        }
        else
        {
            if( (i + 1) % nItemCntInHorizontal == 0 )
            {
                itemFrame.origin.x = 1;
                itemFrame.origin.y += itemSize.height;
            }
            else
                itemFrame.origin.x += itemSize.width;
        }
        
        [self addSubview:itemView.view];
        if( [dicItems count] > NUMBER_OF_REUSABLE_IDENTIFIERS )
            [dicItems removeAllObjects];
        [dicItems setObject:itemView forKey:itemView.reuseIdentifier];
        [dicVisibleItems removeObjectForKey:itemView.reuseIdentifier];
        [arrTmp addObject:itemView];
    }
    
    //  Remove items which is not visible
    NSEnumerator * enumer = [dicVisibleItems objectEnumerator];
    MScrollViewItem * item = nil;
    while( (item = [enumer nextObject]) )
        [item.view removeFromSuperview];
    [dicVisibleItems removeAllObjects];
    
    //  Charge items which is visible
    for( item in arrTmp )
        [dicVisibleItems setObject:item forKey:item.reuseIdentifier];
}

- (MScrollViewItem *)dequeueReusableItemWithIdentifier:(NSString *)identifier
{
    return [dicItems objectForKey:identifier];
}

- (NSInteger)numberOfItemsPerOnePage
{
    //  Current Orientation
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    
    //  Current Size
    CGSize size = self.frame.size;
    
    //  Item Size 
    CGSize itemSize = [self.dataSource MScrollView:self sizeForItemsOrientation:orientation];
    
    //  Number of items in Horizontal and calculate item`s width to fit
    NSInteger nItemCntInHorizontal = size.width / itemSize.width;
    if( nItemCntInHorizontal == 0 )
        nItemCntInHorizontal = 1;
    
    NSInteger nItemCntInVertical = size.height / itemSize.height;
    if( nItemCntInVertical == 0 )
        nItemCntInVertical = 1;
    
    return nItemCntInHorizontal * nItemCntInVertical;
}

#pragma mark - UIScrollViewDelegate
//- (void)scrollViewDidScroll:(UIScrollView *)sender
//{    
//    NSInteger nCurrentPage = floor( (self.contentOffset.x + 20) / self.frame.size.width ) + 1; 
//    nCurrentPage = nCurrentPage < 1 ? 1 : nCurrentPage;    
//
//    if( currentPage != nCurrentPage )
//    {
//        previousPage = currentPage;
//        currentPage = nCurrentPage;
//        
//        if( self.actionDelegate != nil )
//        {
//            if( [self.actionDelegate respondsToSelector:@selector(MScrollView:scrolledToNthPage:)] )
//                [self.actionDelegate MScrollView:self scrolledToNthPage:nCurrentPage];
//        }        
//    }
//}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)sender
{
    
    DLog(@"%f", self.contentOffset.x);
    
    NSInteger nCurrentPage = floor( (self.contentOffset.x + 20) / self.frame.size.width ) + 1; 
    nCurrentPage = nCurrentPage < 1 ? 1 : nCurrentPage;    
    
    if( currentPage != nCurrentPage )
    {
        currentPage = nCurrentPage;
        
        if( self.actionDelegate != nil )
        {
            if( [self.actionDelegate respondsToSelector:@selector(MScrollView:scrolledToNthPage:)] )
                [self.actionDelegate MScrollView:self scrolledToNthPage:nCurrentPage];
        }        
    }
}

@end
