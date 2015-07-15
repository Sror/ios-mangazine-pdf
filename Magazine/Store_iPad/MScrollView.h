//
//  MScrollView.h
//  Magazine
//
//  Created by Myongsok Kim on 9/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MScrollViewDataSource;
@protocol MScrollViewDelegate;


@interface MScrollViewItem : NSObject
{
    UIView *   view;
    NSString * reuseIdentifier;
}
@property ( retain ) UIView * view;
@property ( retain ) NSString * reuseIdentifier;
@end

@interface MScrollView : UIScrollView <UIScrollViewDelegate>
{
    id<MScrollViewDataSource>       dataSource;
    id<MScrollViewDelegate>         actionDelegate;
    NSMutableDictionary *           dicItems;
    NSMutableDictionary *           dicVisibleItems;
    BOOL                            bPageFit;

    NSInteger                       currentPage;
}

@property ( retain ) id<MScrollViewDataSource>      dataSource;
@property ( retain ) id<MScrollViewDelegate>        actionDelegate;
@property ( assign ) NSInteger                      currentPage;
@property ( assign ) BOOL                           bPageFit;

- (void)reloadData;
- (MScrollViewItem *)dequeueReusableItemWithIdentifier:(NSString *)identifier;
- (NSInteger)numberOfItemsPerOnePage;
@end


@protocol MScrollViewDataSource <NSObject>
- (NSInteger)numberOfItemsInMScrollView:(MScrollView *)scrollView;
- (MScrollViewItem *)MScrollView:(MScrollView *)scrollView itemAtIndex:(NSInteger)index;
- (CGSize)MScrollView:(MScrollView *)scrollView sizeForItemsOrientation:(UIInterfaceOrientation)orientation;
@end

@protocol MScrollViewDelegate <NSObject>
@optional
/*  nPageNm start from one. */
- (void)MScrollView:(MScrollView *)scrollView scrolledToNthPage:(NSInteger)nPageNm;
@end