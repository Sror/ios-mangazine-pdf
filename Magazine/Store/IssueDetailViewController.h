//
//  IssueDetailViewController.h
//  Magazine
//
//  Created by Myongsok Kim on 8/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FetchURI.h"
#import "RatingView.h"

@class Issue;
@class LibraryIssue;
@interface IssueDetailViewController : UITableViewController <FetchDelegate>
{
    
    IBOutlet UITableViewCell *infoCell;
    IBOutlet UITableViewCell *descCell;
    IBOutlet UITableViewCell *rateCell;
    
    //  Outlets on info cell
    IBOutlet UIImageView *imageViewThumb;
    IBOutlet UILabel *labelSeriesTitle;
    IBOutlet UILabel *labelIssueTitle;
    IBOutlet UILabel *labelReleased;
    IBOutlet UILabel *labelPublisher;
    IBOutlet UILabel *labelRatings;
    IBOutlet UILabel *labelDownloads;
    IBOutlet UILabel *labelPages;
    IBOutlet UILabel *labelStatus;
    IBOutlet UIButton *btnBuy;
    IBOutlet UIImageView *imageViewRating;
        
    //  Outlet on description cell
    IBOutlet UITextView *textViewDesc;
    
    
    //  Outlets on Rate Cell
    IBOutlet UILabel *labelRateText;
    IBOutlet RatingView *ratingView;
    
    UIImage * defaultImage;
    
    Issue *         issue;
    LibraryIssue *  libraryIssue;
    
    BOOL       bThumbOK;
    FetchURI * fetchURIForThumb;
}

@property ( retain ) Issue *    issue;

- (IBAction)onBuy:(id)sender;
- (IBAction)onThumbnail:(id)sender;
- (void)onRate:(id)sender;


- (void)displayIssueDetail;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           
- (void)paintButton:(UIButton *)btn withR:(float)r withG:(float)g withB:(float)b;

//  File Downloading
- (void)downloadDidSuccess:(NSNotification *)notification;
- (void)downloadDidFail:(NSNotification *)notification;
- (void)downloadWithPercent:(NSNotification *)notification;

@end
