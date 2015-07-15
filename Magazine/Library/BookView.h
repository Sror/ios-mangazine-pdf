//
//  IssueView.h
//  Magazine
//
//  Created by Myongsok Kim on 8/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LibraryIssue;
@interface BookView : UIViewController
{    
    
    
    IBOutlet UIButton *btnImage;
    IBOutlet UIButton *btnDelete;
    IBOutlet UIImageView *imageBadgeView;
    IBOutlet UIImageView *imageAlarmView;
    IBOutlet UIProgressView *progressDownload;
    
    LibraryIssue * libraryIssue;
    
}

@property ( retain ) LibraryIssue * libraryIssue;

+ (CGSize)sizeOfView;
- (void)showDeleteButton:(BOOL)bShow;
- (void)resume;
- (void)pause;

- (IBAction)onRead:(id)sender;
- (IBAction)onDelete:(id)sender;

- (void)makeAsNew:(BOOL)bNew;

//  file downloading
- (void)downloadDidSuccess:(NSNotification *)notification;
- (void)downloadDidFail:(NSNotification *)notification;
- (void)downloadWithPercent:(NSNotification *)notification;

@end
