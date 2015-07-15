//
//  LibraryViewController.h
//  Magazine
//
//  Created by Myongsok Kim on 8/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReaderViewController.h"

enum VIEW_TYPE
{
    LIST_VIEW           = 0,
    THUMB_VIEW
};

@class BookcaseViewController;
@class ListViewController;
@class LibraryIssue;
@interface LibraryViewController : UIViewController <ReaderViewControllerDelegate>
{
    
    IBOutlet UINavigationItem *libraryNavigationItem;
    IBOutlet UINavigationBar *libraryNavigationBar;
    IBOutlet UIView *containerView;

    UIBarButtonItem * editButton;
    UIBarButtonItem * viewTypeButton;
    UIBarButtonItem * storeButton;
    
    BookcaseViewController *    bookcaseViewController;
    ListViewController *        listViewController;
    
    UISegmentedControl * segmentViewType;
    
    BOOL            bAutoTransitionToReading;
    NSString *      sAutoTransitionIssueId;
    
    BOOL            bAutoDownload;
    NSString *      sAutoDownloadIssueId;
}

@property ( assign ) BOOL           bAutoTransitionToReading;
@property ( retain ) NSString *     sAutoTransitionIssueId;
@property ( assign ) BOOL           bAutoDownload;
@property ( retain ) NSString *     sAutoDownloadIssueId;
@property ( retain ) UISegmentedControl * segmentViewType;


+ (LibraryViewController *)sharedLibraryViewController;
+ (void)destroyLibraryViewController;
- (BOOL)isEditMode;

- (void)readBook:(LibraryIssue *)libraryIssue;
- (void)removeLibraryIssue:(LibraryIssue *)libraryIssue;

- (void)gotoStore:(id)sender;
- (void)onEdit:(id)sender;

- (void)changeViewType:(id)sender;

@end
