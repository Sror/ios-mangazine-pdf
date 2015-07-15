//
//  IssueCell.h
//  Magazine
//
//  Created by Myongsok Kim on 8/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FetchURI.h"

@protocol IssueCellDelegate <NSObject>
@optional
- (void)onSelect:(id)sender;
- (void)onThumbnail:(id)sender;
@end


@interface IssueCell : UIViewController <FetchDelegate>
{

    IBOutlet UIButton *btnThumb;
    IBOutlet UILabel *labelSeriesTitle;
    IBOutlet UILabel *labelIssueTitle;
    IBOutlet UILabel *labelRating;
    IBOutlet UIButton *btnSelect;
    IBOutlet UIImageView *imageRating;
        
    NSString * sThumbURL;
    NSString * sThumbPath;
    NSString * sSeriesTitle;
    NSString * sIssueTitle;
    NSInteger  nRating;
    float      fAvgRating;
    NSString * sSelectTitle;
    id          userData;
    
    FetchURI *  fetchURI;
    
    id<IssueCellDelegate>   delegate;
    
    
    UIImage * defaultImage;
}

@property ( nonatomic, retain ) NSString *         sThumbURL;
@property ( nonatomic, retain ) NSString *         sThumbPath;
@property ( nonatomic, retain ) NSString *         sSeriesTitle;
@property ( nonatomic, retain ) NSString *         sIssueTitle;
@property ( nonatomic, assign ) NSInteger          nRating;
@property ( nonatomic, assign ) float              fAvgRating;
@property ( nonatomic, retain ) NSString *         sSelectTitle;

@property ( assign ) id<IssueCellDelegate>         delegate;

@property ( retain ) id                 userData;


+ (CGSize)sizeOfView;

- (IBAction)onSelect:(id)sender;
- (IBAction)onThumbnail:(id)sender;



@end
